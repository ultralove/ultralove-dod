# DashboardOfDoom

DashboardOfDoom is an open-source cross-platform SwiftUI application for iOS and macOS that provides real-time and historical data visualizations for various environmental and public health metrics. It aggregates data such as COVID-19 incidence rates, radiation levels, particle concentrations, weather forecasts, and survey results to give users an interactive dashboard.

**Note:** This application is designed to run only in Germany.

## Features

- COVID-19 incidence maps and charts
- ARIMA-based forecasting for future trends
- Real-time radiation and particle concentration monitoring
- Weather forecasts and environmental data
- Customizable filters and selectors for different metrics
- Intuitive SwiftUI interface on both iOS and macOS

## Requirements

- macOS 15.0 or later / iOS 18.0 or later
- Xcode 16.3 or later
- Swift 6.0 or later

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/ultralove/ultralove-dod.git
   cd ultralove-dod
   ```

2. Open the project in Xcode:
   - For iOS: `iOS/DashboardOfDoom.xcodeproj`
   - For macOS: `macOS/DashboardOfDoom.xcodeproj`

3. Select the appropriate scheme (DashboardOfDoom-iOS or DashboardOfDoom-macOS) and run on a simulator or device.

## Project Structure

- `iOS/` – Contains the iOS SwiftUI application, organized into Controllers, Services, Sensors, ViewModels, Views, and Utilities.
- `macOS/` – Contains the macOS SwiftUI application, with Controllers, Presenters, Services, Transformers, Views, and Utilities.
- `Shared/` – (Reserved) for common code shared between iOS and macOS targets.
- `LICENSE` – MIT license.

## Architecture

- **iOS**: Follows an MVVM pattern with Sensors (data sources), Services (network), Controllers, ViewModels, and Views.
- **macOS**: Follows an MVP pattern with Controllers, Presenters, Services, Transformers, and Views.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.