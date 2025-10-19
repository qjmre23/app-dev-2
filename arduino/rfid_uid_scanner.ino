/*
 * RFID UID Scanner Utility
 *
 * This utility helps you find the UID of your RFID tags/cards.
 * Upload this code to your Arduino/ESP8266 to scan and display
 * the UID of any RFID tag you place near the reader.
 *
 * Use these UIDs to map your physical RFID tags to:
 * - Employee badges
 * - Toy product tags
 *
 * Hardware:
 * - ESP8266 or ESP32
 * - MFRC522 RFID Reader
 *
 * Wiring for ESP8266:
 * RST -> D3
 * SDA(SS) -> D4
 * MOSI -> D7
 * MISO -> D6
 * SCK -> D5
 * 3.3V -> 3.3V
 * GND -> GND
 */

#include <SPI.h>
#include <MFRC522.h>

#define RST_PIN D3
#define SS_PIN D4

MFRC522 rfid(SS_PIN, RST_PIN);

void setup() {
  Serial.begin(115200);
  delay(100);

  SPI.begin();
  rfid.PCD_Init();

  Serial.println("\n\n=== RFID UID Scanner Utility ===");
  Serial.println("Place an RFID card/tag near the reader to scan its UID");
  Serial.println("=========================================\n");
}

void loop() {
  if (!rfid.PICC_IsNewCardPresent()) {
    return;
  }

  if (!rfid.PICC_ReadCardSerial()) {
    return;
  }

  Serial.println("\n=== RFID Card Detected ===");

  String uid = "";
  String uidFormatted = "";

  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) {
      uid += "0";
      uidFormatted += "0";
    }
    uid += String(rfid.uid.uidByte[i], HEX);
    uidFormatted += String(rfid.uid.uidByte[i], HEX);

    if (i < rfid.uid.size - 1) {
      uidFormatted += ":";
    }
  }

  uid.toUpperCase();
  uidFormatted.toUpperCase();

  Serial.println("UID (Plain):     " + uid);
  Serial.println("UID (Formatted): " + uidFormatted);

  Serial.print("Card Type: ");
  MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);
  Serial.println(rfid.PICC_GetTypeName(piccType));

  Serial.println("\nUse this mapping in your Arduino code:");
  Serial.println("Example for Toy Tag:");
  Serial.println("  {\"" + uid + "\", \"Toy Guns\", LED_RED},");
  Serial.println("\nExample for Employee Badge:");
  Serial.println("  {\"" + uid + "\", \"John Marwin Ebona\", \"Toy Guns\"},");
  Serial.println("=========================================\n");

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();

  delay(2000);
}
