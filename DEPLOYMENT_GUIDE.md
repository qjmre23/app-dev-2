# Smart Toy Store - Supabase Deployment Guide

## System Overview

The Smart Toy Store system now uses Supabase as the backend, replacing the Dart server. This provides:
- Real-time database updates
- Built-in authentication
- RESTful API
- Realtime subscriptions
- Cloud-hosted infrastructure

## Components

1. **Supabase Backend** - Cloud database and API
2. **React/TypeScript Dashboards** - Admin and employee dashboards
3. **Flutter Mobile App** - Customer ordering interface
4. **Arduino RFID System** - Physical order tracking

---

## 1. Supabase Setup

### Database Tables Created
- `users` - User accounts
- `toys` - Product catalog
- `orders` - Order tracking
- `employees` - Employee assignments

### Storage Buckets
- `toy-images` - Product images

### Access Details
- URL: `https://qcczvwfccyslhfjtnpnl.supabase.co`
- Anon Key: (See `.env` files)

---

## 2. React Dashboards Deployment

### Installation
```bash
cd dashboard
npm install
```

### Development
```bash
npm run dev
```
Opens on `http://localhost:3000`

### Build for Production
```bash
npm run build
```

### Dashboard Routes
- `/` - Dashboard selector
- `/admin` - Admin dashboard (all orders)
- `/employee/john-marwin` - John Marwin (Toy Guns)
- `/employee/jannalyn-cruz` - Jannalyn Cruz (Action Figures)
- `/employee/marl-prince` - Prince Marl (Dolls)
- `/employee/renz-christiane` - Renz Christiane (Puzzles)

### Features
- Real-time order updates via Supabase realtime
- Audio alerts for new orders
- Category-specific filtering
- Live connection status
- Order history management

---

## 3. Flutter Mobile App Setup

### Prerequisites
- Flutter SDK installed
- Android Studio or Xcode

### Installation
```bash
flutter pub get
```

### Run on Device/Emulator
```bash
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

### Features
- Supabase authentication (email/password)
- Browse toy catalog
- Place orders
- View order history
- Real-time order status updates

---

## 4. Arduino RFID System Setup

### Hardware Requirements
- ESP8266 or ESP32
- MFRC522 RFID Reader
- RGB LED or 3 separate LEDs (Red, Green, Blue)
- RFID tags/cards

### Wiring (ESP8266)
```
MFRC522 -> ESP8266
RST     -> D3
SDA(SS) -> D4
MOSI    -> D7
MISO    -> D6
SCK     -> D5
3.3V    -> 3.3V
GND     -> GND

LEDs:
Red   -> D1
Green -> D2
Blue  -> D8
```

### Software Setup

1. **Install Arduino IDE**
2. **Install Libraries**:
   - ESP8266WiFi (built-in)
   - ArduinoJson (by Benoit Blanchon)
   - MFRC522 (by GithubCommunity)

3. **Configure WiFi and Supabase**

Open `arduino/supabase_rfid_system.ino` and update:
```cpp
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
```

The Supabase URL and keys are already configured.

4. **Find Your RFID Tag UIDs**

Upload `arduino/rfid_uid_scanner.ino` to scan your RFID tags and get their UIDs.

5. **Update RFID Mappings**

In `supabase_rfid_system.ino`, update the `rfidMappings` array with your actual tag UIDs:

```cpp
RFIDMapping rfidMappings[] = {
  {"A1B2C3D4", "Toy Guns", LED_RED},
  {"E5F6G7H8", "Action Figures", LED_GREEN},
  {"11223344", "Dolls", LED_BLUE},
  {"55667788", "Puzzles", LED_RED},
  // Add more mappings as needed
};
```

6. **Upload Main Code**

Upload `supabase_rfid_system.ino` to your Arduino.

### LED Behavior
- **Pending**: LEDs off
- **Processing/On The Way**: LED blinks
- **Delivered**: LED stays on
- **Puzzles**: Red + Blue LEDs (purple)

---

## 5. System Workflow

### 1. Customer Orders (Flutter App)
1. User signs up/logs in with email
2. Browses toy catalog
3. Places order
4. Order stored in Supabase

### 2. Order Assignment
- Backend automatically assigns employee based on toy category:
  - Toy Guns → John Marwin Ebona
  - Action Figures → Jannalyn Cruz
  - Dolls → Prince Marl Mirasol
  - Puzzles → Renz Christiane Ming

### 3. Dashboard Notifications
- Admin dashboard shows all orders
- Employee dashboards filter by category
- Audio alert plays when new order arrives
- Real-time status updates

### 4. Physical Processing (Arduino)
- Arduino polls Supabase for pending orders
- LED lights up for matching category
- Employee scans RFID tag to update status:
  - First scan: PENDING → PROCESSING
  - Second scan: PROCESSING → ON_THE_WAY
  - Third scan: ON_THE_WAY → DELIVERED
- LED turns off after delivery

### 5. Real-time Sync
- All changes sync instantly via Supabase realtime
- Flutter app shows updated status
- Dashboards reflect current state

---

## 6. Testing the System

### Test User Account
Create a test account in the Flutter app:
- Email: `test@smarttoy.com`
- Password: `password123`

### Test Order Flow
1. Login to Flutter app
2. Order a "Laser Ray Gun" (Toy Guns category)
3. Check Admin dashboard - order appears
4. Check John Marwin dashboard - order appears
5. Scan RFID tag on Arduino
6. Watch status change in real-time

---

## 7. Production Deployment

### React Dashboards
Deploy to:
- Vercel (recommended)
- Netlify
- AWS Amplify
- Firebase Hosting

Example with Vercel:
```bash
cd dashboard
npx vercel deploy --prod
```

### Flutter App
Publish to:
- Google Play Store (Android)
- Apple App Store (iOS)

Follow platform-specific guidelines for app submission.

### Arduino
- Flash firmware to all factory floor devices
- Configure each with correct WiFi credentials
- Test connectivity and LED behavior

---

## 8. Troubleshooting

### Arduino Not Connecting
- Check WiFi credentials
- Verify Supabase URL and keys
- Check serial monitor for error messages

### Dashboard Not Updating
- Check browser console for errors
- Verify Supabase credentials in `.env`
- Check realtime subscription status

### Flutter App Crashes
- Run `flutter clean && flutter pub get`
- Check Supabase credentials
- Verify internet connection

### Orders Not Appearing
- Check RLS policies in Supabase
- Verify user authentication
- Check database tables for data

---

## 9. Security Notes

- Never commit `.env` files to version control
- Rotate Supabase keys periodically
- Use Row Level Security (RLS) policies
- Implement rate limiting for production
- Use HTTPS for all web traffic
- Secure Arduino WiFi credentials

---

## 10. Support

For issues or questions:
1. Check Supabase dashboard logs
2. Review Arduino serial monitor output
3. Check browser console (dashboards)
4. Review Flutter debug logs

---

## System Architecture Diagram

```
┌─────────────────┐
│  Flutter App    │
│  (Customer)     │
└────────┬────────┘
         │
         ↓
┌─────────────────┐      ┌──────────────────┐
│   Supabase      │◄────►│ React Dashboards │
│   - Database    │      │  - Admin         │
│   - Auth        │      │  - Employees     │
│   - Realtime    │      └──────────────────┘
│   - Storage     │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Arduino RFID   │
│  - ESP8266      │
│  - MFRC522      │
│  - LEDs         │
└─────────────────┘
```

System is now fully online and connected via Supabase!
