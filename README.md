# Laundry Mobile Application

The Laundry Mobile Application is a cross-platform solution developed with Flutter, designed to facilitate real-time data entry and management for laundry facility personnel. The application replaces traditional paper-based tracking systems with a digital, synchronized auditing tool.

## Technical Specifications

- **Framework:** Flutter SDK
- **State Management:** Provider
- **Networking:** Dio (REST API)
- **Real-time:** Socket.io
- **Persistence:** Shared Preferences and Flutter Secure Storage

## Getting Started

### Installation

1. Synchronize project dependencies:
   ```bash
   flutter pub get
   ```

2. Configuration:
   The application uses environment variables for network configuration. Create or modify the `.env` file in the root directory:
   ```env
   API_URL_MOBILE=http://192.168.1.XX:8080  # Your machine's IP for physical devices
   API_URL_WEB=http://localhost:8080       # For Web/Chrome testing
   ```
   For Android Emulators, the app automatically handles the loopback to `10.0.2.2` if configured correctly in the `.env`.

3. Execution:
   ```bash
   flutter run
   ```

## Application Workflow

The application is structured to optimize the data entry lifecycle for field operators.

### Authentication and Session Management
- Secure entry via user credentials.
- Automatic session restoration utilizing encrypted local storage for JWT tokens.

### Operational Dashboard
- Displays real-time KPIs and system status.
- Provides immediate visibility into pending approvals and daily processing volumes.

### Reporting Wizard
A sequential, validation-driven workflow:
- **General Logistics:** Selection of client entity and entry of packaging metrics.
- **Inventory Count:** Categorized data entry for linens, towels, and protective covers.
- **Review and Dispatch:** Final audit step for data integrity before submission to the backend.

## Project Structure

The codebase follows a modular clean architecture approach:

- `lib/core`: Foundation logic, themes, and API client configuration.
- `lib/models`: Data structures and serialization logic for API entities.
- `lib/providers`: State management containers for authentication and business logic.
- `lib/screens`: UI layer containing all functional views and navigation layouts.
- `lib/services`: Infrastructure services for connectivity and background synchronization.
- `lib/widgets`: Reusable UI components and specialized form controls.

## Maintenance and Architecture

- **State Management:** Logic is decoupled from the UI using the Provider pattern, ensuring testability and modularity.
- **Communication Layer:** A centralized Dio client manages interceptors for global error handling and authentication headers.
- **Zero-Trust Security Architecture:** The application implements a server-driven UI model. Navigation items and feature access are dynamically generated based on the `permissions_mobile` payload provided by the API. The app contains no local permission management, ensuring that security policies are strictly enforced from the centralized web dashboard.
- **Global Alerts:** Integration with Socket.io provides instantaneous system updates and manager feedback.
