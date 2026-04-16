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
   Verify the API endpoints in `lib/core/api/api_client.dart`. Ensure the `baseUrl` correlates with your active backend environment.

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
- **Global Alerts:** Integration with Socket.io provides instantaneous system updates and manager feedback.
