#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>

const char* ssid = "db";
const char* password = "123456789";
const char* serverIP = "192.168.137.1";
const int serverPort = 8080;

const int LED_RED = D1;
const int LED_GREEN = D2;
const int LED_BLUE = D3;

struct RFIDMapping {
  const char* uid;
  const char* category;
  int ledPin;
};

// --- NEW RFID MAPPING ---
RFIDMapping rfidMappings[] = {
  // Toy Guns (Red LED)
  {"TG01_UID", "Toy Guns", LED_RED},
  {"TG02_UID", "Toy Guns", LED_RED},
  {"TG03_UID", "Toy Guns", LED_RED},
  // Action Figures (Green LED)
  {"AF01_UID", "Action Figures", LED_GREEN},
  {"AF02_UID", "Action Figures", LED_GREEN},
  {"AF03_UID", "Action Figures", LED_GREEN},
  // Dolls (Blue LED)
  {"DL01_UID", "Dolls", LED_BLUE},
  {"DL02_UID", "Dolls", LED_BLUE},
  {"DL03_UID", "Dolls", LED_BLUE},
  // Puzzles (Red + Blue -> Purple LED)
  {"PZ01_UID", "Puzzles", LED_RED},
  {"PZ02_UID", "Puzzles", LED_RED},
  {"PZ03_UID", "Puzzles", LED_RED},
};

const int numMappings = sizeof(rfidMappings) / sizeof(RFIDMapping);

String currentRFID = "";
String currentCategory = "";
String currentStatus = "PENDING";
int currentLedPin = -1;

void setup() {
  Serial.begin(115200);
  delay(100);

  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);

  digitalWrite(LED_RED, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_BLUE, LOW);

  Serial.println("\n\nSmart Toy Store - RFID System");
  Serial.println("Connecting to WiFi...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Connected to: ");
    Serial.println(ssid);

    blinkAll(3);
  } else {
    Serial.println("\nWiFi Connection Failed!");
  }

  Serial.println("\nSystem Ready - Waiting for RFID scans...");
  Serial.println("Enter RFID UID in Serial Monitor to simulate scan");
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Reconnecting...");
    WiFi.reconnect();
    delay(5000);
    return;
  }

  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    input.trim();

    if (input.length() > 0) {
      processRFIDScan(input);
    }
  }
  
  updateLEDStatus();
}

void processRFIDScan(String rfidUID) {
  Serial.println("\n=== RFID Scan Detected ===");
  Serial.print("UID: ");
  Serial.println(rfidUID);

  for (int i = 0; i < numMappings; i++) {
    if (rfidUID.equals(rfidMappings[i].uid)) {
      currentRFID = rfidUID;
      currentCategory = rfidMappings[i].category;
      currentLedPin = rfidMappings[i].ledPin;
      
      if (currentStatus == "PENDING") {
        currentStatus = "PROCESSING";
      } else if (currentStatus == "PROCESSING") {
        currentStatus = "ON_THE_WAY";
      } else if (currentStatus == "ON_THE_WAY") {
        currentStatus = "DELIVERED";
      } else {
        return; 
      }

      Serial.print("Category: ");
      Serial.println(currentCategory);
      Serial.print("Status: ");
      Serial.println(currentStatus);

      sendStatusUpdate();
      return;
    }
  }

  Serial.println("RFID UID not found in mapping!");
}

void sendStatusUpdate() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected. Cannot send update.");
    return;
  }

  WiFiClient client;
  HTTPClient http;

  String url = "http://" + String(serverIP) + ":" + String(serverPort) + "/updateStatus";

  Serial.print("\nSending update to: ");
  Serial.println(url);

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<256> doc;
  doc["rfid_uid"] = currentRFID;
  doc["category"] = currentCategory;
  doc["status"] = currentStatus;

  String payload;
  serializeJson(doc, payload);

  Serial.print("Payload: ");
  Serial.println(payload);

  int httpCode = http.POST(payload);

  if (httpCode > 0) {
    Serial.print("HTTP Response Code: ");
    Serial.println(httpCode);

    if (httpCode == 200 || httpCode == 201) {
      String response = http.getString();
      Serial.print("Response: ");
      Serial.println(response);
      Serial.println("Status update successful!");
      
      if (currentStatus == "DELIVERED") {
        delay(5000); 
        currentRFID = "";
        currentCategory = "";
        currentLedPin = -1;
        currentStatus = "PENDING";
        turnOffAllLEDs();
      }
    } else {
      Serial.println("Server returned error code");
    }
  } else {
    Serial.print("HTTP Request failed: ");
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
}


void updateLEDStatus() {
  if (currentLedPin == -1) {
    return;
  }

  if (currentCategory == "Puzzles") { // Special case for Puzzles (Purple LED)
    if (currentStatus == "PROCESSING" || currentStatus == "ON_THE_WAY") {
        digitalWrite(LED_RED, HIGH);
        digitalWrite(LED_BLUE, HIGH);
    } else if (currentStatus == "DELIVERED") {
        digitalWrite(LED_RED, HIGH);
        digitalWrite(LED_BLUE, HIGH);
    }
  } else { // For other categories
    if (currentStatus == "PROCESSING" || currentStatus == "ON_THE_WAY") {
      static unsigned long lastBlink = 0;
      static bool ledState = false;

      if (millis() - lastBlink >= 250) {
        ledState = !ledState;
        digitalWrite(currentLedPin, ledState ? HIGH : LOW);
        lastBlink = millis();
      }
    } else if (currentStatus == "DELIVERED") {
      digitalWrite(currentLedPin, HIGH);
    }
  }
}

void turnOffAllLEDs() {
  digitalWrite(LED_RED, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_BLUE, LOW);
}

void blinkAll(int times) {
  for (int i = 0; i < times; i++) {
    digitalWrite(LED_RED, HIGH);
    digitalWrite(LED_GREEN, HIGH);
    digitalWrite(LED_BLUE, HIGH);
    delay(200);
    turnOffAllLEDs();
    delay(200);
  }
}
