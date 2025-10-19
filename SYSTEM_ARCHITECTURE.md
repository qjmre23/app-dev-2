# Smart Toy Store System - Architecture Documentation

## System Overview

The Smart Toy Store System is a distributed real-time application designed to manage and track toy orders across multiple platforms. The system operates entirely on a local area network (LAN) using a WiFi hotspot.

## Architecture Diagram

```
                    ┌─────────────────────────────────────┐
                    │         WiFi Hotspot (db)           │
                    │      10.40.190.0/24 Network         │
                    └─────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐          ┌────────────────┐         ┌─────────────────┐
│  Flutter App  │          │ Dart Shelf     │         │  Arduino ESP    │
│  (Mobile)     │◀────────▶│  Backend       │◀────────│  (IoT Device)   │
│               │          │                │         │                 │
│  - Auth UI    │   HTTP   │ - REST API     │  HTTP   │ - RFID Reader   │
│  - Orders     │   JWT    │ - WebSocket    │  POST   │ - LED Control   │
│  - Real-time  │   WS     │ - Database     │         │ - WiFi Client   │
└───────────────┘          └────────────────┘         └─────────────────┘
        │                           │
        │                           │
        │                    WebSocket
        │                           │
        │                           ▼
        │                  ┌─────────────────┐
        └─────────────────▶│  HTML Dashboard │
                           │  (Web Browser)  │
                           │                 │
                           │ - Live Monitor  │
                           │ - Statistics    │
                           │ - Real-time UI  │
                           └─────────────────┘
```

## Component Details

### 1. Network Layer

**WiFi Hotspot Configuration:**
- SSID: `db`
- Password: `123456789`
- Network: `10.40.190.0/24`
- Gateway: `10.40.190.130`

**Protocol Stack:**
- Application: HTTP/HTTPS, WebSocket
- Transport: TCP
- Network: IPv4
- Data Link: WiFi 802.11 (2.4 GHz)

### 2. Backend Server (Dart Shelf)

**Host:** 10.40.190.130:8080

**Components:**

```
backend/
├── bin/
│   └── server.dart          # Main server entry point
├── lib/
│   ├── models.dart          # Data models (User, Order)
│   ├── database.dart        # File-based storage
│   └── auth.dart            # JWT authentication
└── data/
    ├── users.json           # User storage
    └── orders.json          # Order storage
```

**Key Features:**
- RESTful API endpoints
- WebSocket server for pub/sub
- JWT token generation/validation
- CORS middleware
- Request logging
- Broadcast mechanism for real-time updates

**API Endpoints:**

| Method | Endpoint       | Description                | Auth Required |
|--------|---------------|----------------------------|---------------|
| POST   | /login        | User authentication        | No            |
| POST   | /signup       | User registration          | No            |
| GET    | /orders       | Get all orders             | Yes           |
| POST   | /orders       | Create new order           | Yes           |
| POST   | /updateStatus | Update order status        | No            |
| GET    | /ws           | WebSocket connection       | No            |

**Data Flow:**

```
Client Request
      ↓
CORS Middleware
      ↓
Logging Middleware
      ↓
Router
      ↓
Handler Function
      ↓
Database Operation
      ↓
WebSocket Broadcast
      ↓
Response
```

### 3. Flutter Mobile App

**Platform:** Android (Embedding v2)

**Architecture Pattern:** Provider (State Management)

**Layers:**

```
Presentation Layer (UI)
    ├── Screens (login, signup, home)
    ├── Widgets (order_card)
    └── Theme (Material Design 3)
          ↓
Business Logic Layer
    └── Providers (app_provider)
          ↓
Service Layer
    ├── auth_service (JWT)
    ├── websocket_service (Real-time)
    └── order_service (API)
          ↓
Data Layer
    ├── Models (user, toy, order)
    └── Local Storage (Hive)
```

**Key Features:**
- Reactive UI with Provider
- Persistent authentication with SharedPreferences
- Offline-first with Hive caching
- Real-time updates via WebSocket
- JWT token management
- Auto-reconnect on disconnect

**State Management Flow:**

```
User Action
    ↓
Provider Method Call
    ↓
Service Layer Operation
    ↓
HTTP/WebSocket Request
    ↓
Update Local State
    ↓
notifyListeners()
    ↓
UI Rebuild
```

### 4. Arduino ESP8266/ESP32

**Hardware:**
- ESP8266 or ESP32 microcontroller
- 3 LEDs (Red, Green, Blue)
- RFID reader (simulated via Serial)

**Firmware Architecture:**

```
Main Loop
    ├── WiFi Connection Management
    │   └── Auto-reconnect on disconnect
    ├── Serial Input Processing
    │   └── RFID UID parsing
    ├── Status Update Timer
    │   └── 10-second intervals
    └── LED Control
        └── Blinking animations
```

**State Machine:**

```
IDLE
  │ (RFID Scan)
  ↓
PROCESSING (Blink LED)
  │ (10 seconds)
  ↓
ON_THE_WAY (Blink LED)
  │ (10 seconds)
  ↓
DELIVERED (Solid LED)
  │ (10 seconds)
  ↓
IDLE (LED Off)
```

**Network Communication:**

```cpp
WiFiClient → HTTPClient → POST Request → Backend Server
```

### 5. HTML/JavaScript Dashboard

**Technology Stack:**
- Pure HTML5
- Vanilla JavaScript
- WebSocket API
- CSS3 with animations

**Architecture:**

```
index.html
    ├── Structure (HTML)
    ├── Styling (CSS)
    │   ├── Responsive grid
    │   ├── Card layouts
    │   └── Animations
    └── Logic (JavaScript)
        ├── WebSocket client
        ├── Data management
        └── DOM manipulation
```

**Real-time Update Flow:**

```
WebSocket Message Received
        ↓
Parse JSON Data
        ↓
Update orders array
        ↓
renderOrders()
        ↓
Update DOM
        ↓
updateStats()
```

## Data Models

### User Model

```json
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "password_hash": "string",
  "department": "string",
  "created_at": "ISO 8601"
}
```

### Order Model

```json
{
  "id": "uuid",
  "toy_id": "uuid",
  "toy_name": "string",
  "category": "string",
  "rfid_uid": "string",
  "assigned_person": "string",
  "status": "PENDING|PROCESSING|ON_THE_WAY|DELIVERED",
  "created_at": "ISO 8601",
  "updated_at": "ISO 8601",
  "department": "string",
  "total_amount": "number"
}
```

## Communication Protocols

### HTTP REST API

**Request Format:**
```http
POST /orders HTTP/1.1
Host: 10.40.190.130:8080
Content-Type: application/json
Authorization: Bearer <jwt_token>

{
  "toy_id": "...",
  "toy_name": "...",
  ...
}
```

**Response Format:**
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "...",
  "status": "PENDING",
  ...
}
```

### WebSocket Protocol

**Connection:**
```javascript
ws://10.40.190.130:8080/ws
```

**Message Format:**
```json
{
  "id": "order-uuid",
  "status": "PROCESSING",
  "updated_at": "2024-01-01T12:00:00Z",
  ...
}
```

### Arduino HTTP POST

**Update Status Request:**
```http
POST /updateStatus HTTP/1.1
Host: 10.40.190.130:8080
Content-Type: application/json

{
  "rfid_uid": "A12B3C",
  "category": "Toy Guns",
  "status": "PROCESSING"
}
```

## Security Architecture

### Authentication Flow

```
1. User enters credentials
        ↓
2. POST /login
        ↓
3. Backend verifies password hash
        ↓
4. Generate JWT token
        ↓
5. Return token to client
        ↓
6. Client stores token (SharedPreferences)
        ↓
7. Subsequent requests include token in Authorization header
        ↓
8. Backend verifies token on each request
```

### JWT Token Structure

```
Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "user_id": "uuid",
  "username": "string",
  "department": "string",
  "iat": timestamp,
  "exp": timestamp
}

Signature:
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret_key
)
```

### Security Measures

1. **Password Hashing:** SHA-256
2. **Token Expiration:** 7 days
3. **CORS:** Restricted to local network
4. **HTTPS:** Recommended for production
5. **Input Validation:** Server-side validation

## Scalability Considerations

### Current Limitations

- Single server instance
- File-based storage (not suitable for high concurrency)
- No load balancing
- Limited to LAN

### Scaling Strategies

**Horizontal Scaling:**
```
Load Balancer
    ├── Backend Server 1
    ├── Backend Server 2
    └── Backend Server 3
         ↓
    Central Database
```

**Database Migration:**
- Replace JSON files with PostgreSQL or MongoDB
- Implement connection pooling
- Add database replication

**WebSocket Scaling:**
- Use Redis Pub/Sub for message distribution
- Implement WebSocket sticky sessions
- Add message queue (RabbitMQ, Kafka)

## Performance Metrics

### Expected Response Times

| Operation          | Expected Time | Notes                    |
|-------------------|---------------|--------------------------|
| Login             | < 200ms       | Including token gen      |
| Get Orders        | < 100ms       | Cached in memory         |
| Create Order      | < 150ms       | With WebSocket broadcast |
| Update Status     | < 100ms       | Arduino to backend       |
| WebSocket Message | < 50ms        | Broadcast to all clients |

### Capacity Estimates

- Concurrent Users: 50-100
- Orders per minute: 100-200
- WebSocket Connections: 50
- Storage: 1000s of orders in JSON

## Monitoring and Logging

### Backend Logs

```
[2024-01-01 12:00:00] INFO: Server started on 10.40.190.130:8080
[2024-01-01 12:00:05] INFO: WebSocket client connected (total: 3)
[2024-01-01 12:00:10] POST /updateStatus 200 45ms
[2024-01-01 12:00:10] INFO: Broadcasted to 3 clients
```

### Flutter Logs

```dart
print('WebSocket connected');
print('Order received: ${order.id}');
print('Login error: $error');
```

### Arduino Logs

```
WiFi Connected!
RFID Scan Detected
Sending update to backend...
HTTP Response Code: 200
Status update successful!
```

## Deployment Architecture

### Development Environment

```
Developer Machine (10.40.190.130)
    ├── Backend Server (Dart)
    ├── Flutter Development
    └── Arduino IDE

Mobile Device (10.40.190.X)
    └── Flutter App (Debug Mode)

ESP8266 (10.40.190.Y)
    └── Arduino Firmware

Browser (Any Device)
    └── Dashboard
```

### Production Considerations

1. **Server Deployment:**
   - Use systemd service for auto-start
   - Implement graceful shutdown
   - Add health check endpoints

2. **App Distribution:**
   - Build release APK
   - Sign with release keystore
   - Distribute via internal channels

3. **Hardware:**
   - Use proper power supply for ESP
   - Add physical RFID reader
   - Install in secure location

## Disaster Recovery

### Backup Strategy

```
Automated Daily Backup
    ├── backend/data/users.json
    ├── backend/data/orders.json
    └── Configuration files
         ↓
    Cloud Storage / External Drive
```

### Recovery Procedures

1. **Backend Failure:** Restart server, restore from backup
2. **Network Failure:** Auto-reconnect mechanisms
3. **Data Corruption:** Restore from last good backup
4. **Hardware Failure:** Replace device, restore configuration

## Future Enhancements

1. **Microservices Architecture**
2. **Cloud Deployment (AWS, GCP, Azure)**
3. **Mobile App for iOS**
4. **Advanced Analytics Dashboard**
5. **Push Notifications**
6. **QR Code Integration**
7. **Multi-language Support**
8. **Role-based Access Control**

## Conclusion

The Smart Toy Store System demonstrates a modern, real-time architecture suitable for local network operations. The system is designed with clear separation of concerns, making it maintainable and extensible for future enhancements.
