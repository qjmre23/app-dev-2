# Smart Toy Store - Full System Documentation

# 📘 Project Paper: The Smart Toy Store System



## 1. Title Page

**Project Title:**
The Smart Toy Store: A Real-Time, Full-Stack Order Processing and Factory Management System


## 2. Introduction

The Smart Toy Store project is a comprehensive, full-stack application designed to modernize and streamline the order fulfillment process within a toy factory. The core idea is to create a seamless, real-time link between a customer placing an order on a mobile app and the factory worker physically preparing that order for shipment. 

This project addresses the inefficiencies and potential for error inherent in manual order tracking systems. By creating a digital ecosystem where orders are instantly communicated, visually signaled, and updated via physical interaction (RFID scanning), the system aims to significantly improve operational speed, accuracy, and overall factory floor visibility.



## 3. Background of the Study

The inspiration for this project stems from observing common challenges in small to medium-sized manufacturing environments, particularly in response to modern e-commerce demands. As customers increasingly place orders through mobile applications, factories face the need for a robust internal system to handle this influx of digital orders. Without such a system, factories often rely on printed-out order slips, verbal communication, or manual data entry, all of which are prone to delays, miscommunication, and human error.

This study is important because it directly tackles these issues by building a self-contained, LAN-based solution that is both powerful and cost-effective. Related studies in industrial IoT (Internet of Things) and real-time systems often focus on large-scale enterprise solutions. This project, however, demonstrates that the core principles of IoT—interconnected devices, real-time data synchronization, and physical-to-digital workflows—can be implemented using accessible technologies like Flutter, Dart, and Arduino. It proves the necessity of a tailored, digital workflow management system to bridge the gap between a customer's click and a worker's action on the factory floor.


## 4. Project Objectives

### General Objective

To design, develop, and deploy a full-stack, real-time order processing and management system that seamlessly integrates a customer-facing mobile application with a physical factory floor workflow.

### Specific Objectives

*   **To develop a cross-platform mobile application** using Flutter that allows customers to browse a toy catalog, register an account, and place orders.
*   **To build a centralized backend server** using Dart that manages all business logic, handles API requests, and maintains a persistent database for users and orders.
*   **To create a real-time web dashboard** that displays live order data, provides audio alerts for new orders, and allows for the clearing of order history.
*   **To integrate an Arduino-powered physical interface** that uses LEDs to signal new tasks to factory workers and an RFID scanner to allow workers to update order statuses.
*   **To establish a robust, local network architecture** where all components (phone app, backend server, dashboard, Arduino) can communicate reliably over a dedicated WiFi hotspot.
*   **To implement a hardcoded worker assignment system** that automatically designates a specific factory worker to an order based on the toy's category, streamlining accountability.

---

## 5. Significance of the Study

This project provides significant value by creating a tangible, working model for a modern, small-scale factory management system. Its contributions are felt across multiple levels:

*   **For Factory Workers:** The system provides clear, unambiguous visual (LED) and audio cues for new tasks, reducing cognitive load and the potential for error. The RFID-based workflow allows them to update their progress with a simple, intuitive physical action.

*   **For Factory Management:** The real-time dashboard offers unprecedented visibility into the factory floor's workload. Managers can instantly see how many orders are pending, in progress, and completed, allowing for better resource allocation and performance tracking. The `Clear History` function provides a simple way to manage the day's workload.

*   **For Customers:** The system provides a direct line from their order to the factory, leading to faster processing times and fewer errors in fulfillment. The mobile app offers a modern, professional-grade user experience.

*   **For the Institution and Future Students:** This project serves as a comprehensive, practical case study in full-stack development and the Internet of Things. It demonstrates how disparate technologies (mobile, web, backend, and embedded systems) can be integrated into a single, cohesive product. It provides a valuable blueprint for future projects in automation, logistics, and real-time systems.



<img width="1006" height="626" alt="image" src="https://github.com/user-attachments/assets/c2631c47-20a7-4bfc-85c0-a950944eb441" />

#  Toy Store System
MEMBERS:
JANNALYN CRUZ <br>
JOHN MARWIN EBONA<br>
PRINCE MARL LIZANDRELLE MIRASOL<br>
RENZ CHRISTIANE MING

note to self:
git add .
git commit -m "fix cors and server connection"
git branch -M main
git remote remove origin
git remote add origin https://github.com/Reposity23/APP-DEV---FINAL-REPO.git
git push -u origin main


    netstat -ano | findstr :8080
    
    taskkill /PID 26680 /F
    - kill task
## 1. System Architecture

The system is a full-stack, real-time order processing and tracking application designed for a toy factory. It consists of four main components:

1.  **Flutter Mobile App:** The customer-facing storefront. Users can browse a catalog of toys, register for an account, and place orders. It communicates with the backend server over the local network.

2.  **Dart Backend Server:** The central hub of the entire system. It runs on a laptop and is responsible for:
    *   Handling API requests (login, signup, order creation).
    *   Maintaining a persistent JSON database for users and orders.
    *   Serving the HTML dashboard to web clients.
    *   Broadcasting real-time updates to all connected clients (Dashboard and Arduino) via WebSockets.

3.  **HTML5 Dashboard:** The factory floor interface. It provides a real-time overview of all orders, including their status and assigned worker. It plays audio alerts for new orders.

4.  **Arduino (ESP8266):** The physical interface for the factory floor. It connects to the WiFi network, receives order updates, and controls LEDs to signal new tasks. Workers use an RFID scanner connected to it to update the status of an order.

### System Flow Diagram

```
+-----------------+      +--------------------+      +-----------------+
|USER'S Phone App |----->|  Laptop Backend    |<---->|  HTML Dashboard |
| (Flutter)       |      |  (Dart Server)     |      |  (Web Browser)  |
+-----------------+      | - API (HTTP)       |      +-----------------+
                         | - Real-time (WS)   |
                         | - Database (JSON)  |
                         +--------+-----------+
                                  ^
                                  |
                       +----------+---------+
                       |  Arduino (ESP8266) |
                       | - Lights (LEDs)    |
                       | - Scanner (RFID)   |
                       +--------------------+
```

---

## 2. Core Features

*   **Mobile-First Ordering:** A user-friendly mobile app for customers to browse and buy toys.
*   **Real-Time Dashboard:** A live dashboard for factory managers to monitor all incoming orders.
*   **Physical Task Signaling:** An Arduino-powered system with LEDs to provide clear, physical signals to factory workers.
*   **RFID-Based Workflow:** Workers use an RFID scanner to update an order's status through the stages: `PROCESSING` -> `ON_THE_WAY` -> `DELIVERED`.
*   **Persistent Storage:** Orders are saved to the server's disk and will survive a server restart.
*   **Audio Alerts:** The dashboard plays a unique sound for each toy category when a new order arrives, alerting the relevant worker.
*   **Hardcoded Worker Assignments:** Each order is automatically assigned to a specific factory worker based on the toy category.
*   **Role-Specific UI:** The mobile app is for customers; the dashboard is for factory staff.

---

## 3. Setup and Operation Guide

Follow these steps to run the entire system.

### Step 1: Network Configuration

1.  **Create a WiFi Hotspot** on your laptop with the following settings:
    *   **SSID:** `db`
    *   **Password:** `123456789`
2.  **Assign a Static IP Address** to your laptop's hotspot adapter.
    *   The IP address **must** be `192.168.137.1`.
    *   The Subnet Mask should be `255.255.255.0`.

### Step 2: Backend Server Setup

1.  Open a terminal and navigate to the `backend` directory:
    ```sh
    cd C:\Users\johnt\OneDrive\Desktop\app_dev_2\backend
    ```
2.  Install all required dependencies:
    ```sh
    dart pub get
    ```
3.  Run the server:
    ```sh
    dart run bin/server.dart
    ```
4.  The server should now be running. You will see the message: `Server running on http://0.0.0.0:8080`.

> **Troubleshooting:** If you see an `address already in use` error, it means an old server process is stuck. Open the Task Manager, find any `dart.exe` processes, and end them.

### Step 3: Flutter App Setup (for JM's Phone)

1.  **Prepare Assets:** Ensure the directory `assets/images/` exists in the root of the project. Place your toy images here (e.g., `toy_gun_1.png`).
2.  **Install & Run:** Build and install the app on an Android phone connected to your laptop's hotspot (`db`).
3.  **Functionality:**
    *   Users can sign up without providing a department.
    *   Users can browse the toy store, search for products, and place orders.

### Step 4: Arduino Setup

1.  Open the `arduino/smart_toy_rfid.ino` sketch in the Arduino IDE.
2.  **Verify Configuration:** Ensure the `serverIP` is set to `192.168.137.1`.
3.  **Upload the Sketch** to your ESP8266 device.
4.  **LED Color Logic:**
    *   `Dolls`: Green
    *   `Puzzles`: Red
    *   `Action Figures`: Yellow (Red + Green LEDs)
    *   `Toy Guns`: Blue

### Step 5: Dashboard Access

1.  On any device connected to the hotspot (including your laptop or another phone), open a web browser.
2.  Navigate to the server's URL:
    ```
    http://192.168.137.1:8080
    ```
3.  **Click the "Enable Sound & Enter" button.** This is a mandatory one-time step to comply with browser security policies.
4.  The dashboard will load, display all persistent orders, and play sounds for new ones.

---

## 4. System Workflow

1.  **Order Placement:** A customer on the Flutter app buys a "Laser Ray Gun".
2.  **Backend Processing:** The app sends the order to the backend. The backend assigns **John Marwin** to the order and saves it to `orders.json`.
3.  **Real-Time Notifications:** The backend sends a WebSocket message to all clients.
4.  **Dashboard Update:** The HTML dashboard receives the message, adds the "Laser Ray Gun" order to the table, and plays an mp3 for example: `lorem.mp3` sound.
5.  **Arduino Action:** The Arduino is now aware an order for a "Toy Gun" exists.
6.  **Factory Work:** a user  gets the toy. the person who was assign to the order scans the RFID tag for example (`TG01_UID`) on the Arduino scanner.
7.  **Arduino Update:** The Arduino's **Blue LED turns on**. The Arduino sends a `POST` request to `/api/updateStatus` with the new status `PROCESSING`.
8.  **Backend Update:** The backend updates the order in the database.
9.  **Live Sync:** The backend broadcasts the status change. The dashboard and Flutter app update to show the order is now `PROCESSING`.
10. **Completion:** This process repeats for `ON_THE_WAY` and `DELIVERED`. After the final scan, the Arduino's Blue LED turns off.

