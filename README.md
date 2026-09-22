# 🚗 VehicleCare

> A smart and user-friendly vehicle management application for tracking vehicles, servicing, fuel expenses, spare parts, reminders, and recent vehicle activity.

---

## 📌 Overview

**VehicleCare** is a Flutter-based mobile application designed to simplify vehicle maintenance and management.

The application allows users to maintain their vehicle information, record service history, track petrol/fuel expenses, manage spare parts used during servicing, monitor vehicle activity, and receive automatic service reminders.

The project is designed to support both **2-wheelers and 4-wheelers** through a simple and modern mobile interface.

---

## 🎯 Objectives

The main objectives of VehicleCare are:

- Maintain vehicle information digitally.
- Track vehicle service history.
- Record petrol/fuel purchases and expenses.
- Track spare parts used during servicing.
- Automatically calculate spare-part costs.
- Maintain recent vehicle activity in one place.
- Provide automatic service reminders.
- Retrieve vehicle information using external vehicle APIs.
- Integrate spare-part information using an automotive parts API.
- Provide a clean, simple, and user-friendly interface.

---

## ✨ Features

### 👤 User Onboarding

- Simple name-based onboarding.
- No email, password, phone number, or OTP required.
- User name is stored locally.
- Returning users can directly access the Home screen.

---

### 🏠 Home Screen

The Home screen provides quick access to:

- 2 Wheeler
- 4 Wheeler
- Reminders
- Your Vehicles

The interface uses a clean automotive design with rounded cards, soft shadows, and green/teal accents.

---

### 🛵 Vehicle Management

Users can:

- Add a vehicle.
- Edit vehicle information.
- Delete a vehicle.
- View vehicle details.
- Maintain registration number.
- Maintain vehicle brand.
- Maintain vehicle model.
- Maintain manufacturing year.
- Maintain current odometer reading.

Vehicle information is stored locally using `SharedPreferences`.

---

### 🔎 Vehicle Brand & Model Selection

Vehicle brand and model information can be retrieved using an external vehicle catalogue API.

The current implementation uses the:

**NHTSA vPIC Vehicle API**

The application loads:

- Vehicle brands
- Vehicle models

based on the selected vehicle type.

Supported vehicle types:

- 2 Wheeler
- 4 Wheeler

---

### 🔧 Service Logs

Users can create and maintain service records.

Each service record can contain:

- Service date
- Odometer reading
- Service center
- Spare parts
- Spare parts cost
- Notes

The application displays:

- Service history
- Service date
- Odometer reading
- Service center
- Spare parts
- Total spare-part cost
- Notes

---

### 🔩 Spare Parts Management

VehicleCare provides spare-part selection during service-log creation.

Users can:

- Search spare parts.
- View available parts.
- View part numbers.
- Select spare parts.
- Remove selected spare parts.
- View individual part prices.
- Automatically calculate total spare-part cost.

Example:

```text
Brake Pad        ₹800
Oil Filter       ₹450
Air Filter       ₹600
----------------------
Total            ₹1850