/*
 * Smart Toy Store - Supabase RFID System
 *
 * This Arduino code connects to Supabase to:
 * 1. Listen for new orders via REST API polling
 * 2. Control LEDs based on order categories
 * 3. Read RFID tags to update order status
 * 4. Send status updates back to Supabase
 *
 * Hardware:
 * - ESP8266 or ESP32
 * - MFRC522 RFID Reader
 * - RGB LED or separate Red, Green, Blue LEDs
 *
 * Replace placeholders:
 * - YOUR_WIFI_SSID
 * - YOUR_WIFI_PASSWORD
 * - YOUR_SUPABASE_URL
 * - YOUR_SUPABASE_ANON_KEY
 */

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <MFRC522.h>
#include <SPI.h>

const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

const char* SUPABASE_URL = "https://qcczvwfccyslhfjtnpnl.supabase.co";
const char* SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjY3p2d2ZjY3lzbGhmanRucG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4ODkyNjMsImV4cCI6MjA3NjQ2NTI2M30.uKSoy6RvasLbGL41hXuqGgGM0ro6pQBJYQaNftToCyg";

#define RST_PIN D3
#define SS_PIN D4
#define LED_RED D1
#define LED_GREEN D2
#define LED_BLUE D8

MFRC522 rfid(SS_PIN, RST_PIN);

struct RFIDMapping {
  String uid;
  String category;
  int ledPin;
};

RFIDMapping rfidMappings[] = {
  {"TG01_UID", "Toy Guns", LED_RED},
  {"TG02_UID", "Toy Guns", LED_RED},
  {"TG03_UID", "Toy Guns", LED_RED},
  {"AF01_UID", "Action Figures", LED_GREEN},
  {"AF02_UID", "Action Figures", LED_GREEN},
  {"AF03_UID", "Action Figures", LED_GREEN},
  {"DL01_UID", "Dolls", LED_BLUE},
  {"DL02_UID", "Dolls", LED_BLUE},
  {"DL03_UID", "Dolls", LED_BLUE},
  {"PZ01_UID", "Puzzles", LED_RED},
  {"PZ02_UID", "Puzzles", LED_RED},
  {"PZ03_UID", "Puzzles", LED_RED},
};

const int numMappings = sizeof(rfidMappings) / sizeof(RFIDMapping);

String currentOrderId = "";
String currentRFID = "";
String currentCategory = "";
String currentStatus = "PENDING";
int currentLedPin = -1;

unsigned long lastOrderCheck = 0;
const unsigned long ORDER_CHECK_INTERVAL = 5000;

void setup() {
  Serial.begin(115200);
  delay(100);

  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);

  digitalWrite(LED_RED, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_BLUE, LOW);

  SPI.begin();
  rfid.PCD_Init();

  Serial.println("\n\n=== Smart Toy Store - Supabase RFID System ===");
  Serial.println("Connecting to WiFi...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

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
    blinkAll(3);
  } else {
    Serial.println("\nWiFi Connection Failed!");
    Serial.println("Please check your WiFi credentials and restart.");
  }

  Serial.println("\nSystem Ready!");
  Serial.println("Waiting for orders and RFID scans...");
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Reconnecting...");
    WiFi.reconnect();
    delay(5000);
    return;
  }

  if (millis() - lastOrderCheck >= ORDER_CHECK_INTERVAL) {
    checkForNewOrders();
    lastOrderCheck = millis();
  }

  if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
    String scannedUID = getCardUID();
    Serial.println("\n=== RFID Card Detected ===");
    Serial.print("UID: ");
    Serial.println(scannedUID);

    processRFIDScan(scannedUID);

    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
  }

  updateLEDStatus();
}

String getCardUID() {
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  return uid;
}

void checkForNewOrders() {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  String url = String(SUPABASE_URL) + "/rest/v1/orders?status=eq.PENDING&order=created_at.desc&limit=10";

  http.begin(client, url);
  http.addHeader("apikey", SUPABASE_ANON_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);

  int httpCode = http.GET();

  if (httpCode == 200) {
    String payload = http.getString();
    DynamicJsonDocument doc(4096);
    deserializeJson(doc, payload);

    if (doc.is<JsonArray>() && doc.as<JsonArray>().size() > 0) {
      JsonObject order = doc[0];
      String orderId = order["id"].as<String>();

      if (orderId != currentOrderId && currentStatus == "PENDING") {
        currentOrderId = orderId;
        currentRFID = order["rfid_uid"].as<String>();
        currentCategory = order["category"].as<String>();
        currentStatus = "PENDING";

        for (int i = 0; i < numMappings; i++) {
          if (currentRFID == rfidMappings[i].uid) {
            currentLedPin = rfidMappings[i].ledPin;
            Serial.println("\n=== New Order Received ===");
            Serial.print("Order ID: ");
            Serial.println(currentOrderId);
            Serial.print("Category: ");
            Serial.println(currentCategory);
            Serial.print("RFID: ");
            Serial.println(currentRFID);
            break;
          }
        }
      }
    }
  }

  http.end();
}

void processRFIDScan(String scannedUID) {
  for (int i = 0; i < numMappings; i++) {
    if (scannedUID == rfidMappings[i].uid || scannedUID == currentRFID) {
      if (currentStatus == "PENDING") {
        currentStatus = "PROCESSING";
      } else if (currentStatus == "PROCESSING") {
        currentStatus = "ON_THE_WAY";
      } else if (currentStatus == "ON_THE_WAY") {
        currentStatus = "DELIVERED";
      } else {
        Serial.println("Order already completed.");
        return;
      }

      Serial.print("Status Updated: ");
      Serial.println(currentStatus);

      updateOrderStatus();
      return;
    }
  }

  Serial.println("Unknown RFID tag or no active order for this tag.");
}

void updateOrderStatus() {
  if (WiFi.status() != WL_CONNECTED || currentOrderId == "") return;

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  String url = String(SUPABASE_URL) + "/rest/v1/orders?id=eq." + currentOrderId;

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_ANON_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);
  http.addHeader("Prefer", "return=minimal");

  StaticJsonDocument<256> doc;
  doc["status"] = currentStatus;

  String payload;
  serializeJson(doc, payload);

  int httpCode = http.PATCH(payload);

  if (httpCode == 200 || httpCode == 204) {
    Serial.println("Status update successful!");

    if (currentStatus == "DELIVERED") {
      delay(5000);
      resetCurrentOrder();
    }
  } else {
    Serial.print("Status update failed. HTTP Code: ");
    Serial.println(httpCode);
    Serial.println(http.getString());
  }

  http.end();
}

void resetCurrentOrder() {
  currentOrderId = "";
  currentRFID = "";
  currentCategory = "";
  currentLedPin = -1;
  currentStatus = "PENDING";
  turnOffAllLEDs();
  Serial.println("Order completed. System reset.");
}

void updateLEDStatus() {
  if (currentLedPin == -1) {
    return;
  }

  if (currentCategory == "Puzzles") {
    if (currentStatus == "PROCESSING" || currentStatus == "ON_THE_WAY") {
      digitalWrite(LED_RED, HIGH);
      digitalWrite(LED_BLUE, HIGH);
    } else if (currentStatus == "DELIVERED") {
      digitalWrite(LED_RED, HIGH);
      digitalWrite(LED_BLUE, HIGH);
    }
  } else {
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
