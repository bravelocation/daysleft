# AGENTS.md

## Project overview

Count The Days Left is a Swift app that calculates elapsed and remaining time for an event or project. Users can count calendar days or weekdays only, and view the result in the main app, Apple Watch app/complications, WidgetKit widgets, and Siri Shortcuts.

The Xcode project is `DaysLeft.xcodeproj`. It contains iOS and macOS app targets, a watchOS app and widget extension, iOS/macOS WidgetKit extensions, unit tests, and UI/screenshot tests. The project uses Swift Package Manager for its resolved dependencies and includes Firebase Messaging for notifications.

## Source layout

- `daysleft/Models` contains the value types representing user settings and display/control values.
- `daysleft/Model Extensions` contains date normalization, day-counting rules, and display text helpers. Keep date calculations here rather than in views.
- `daysleft/Data Providers` abstracts persistence. `CloudKeyValueDataProvider` uses iCloud key-value storage; `InMemoryDataProvider` is used by tests.
- `daysleft/Data Managers` coordinates settings persistence and WatchConnectivity/Firebase integrations.
- `daysleft/View Models` contains presentation logic for the main and settings screens.
- `daysleft/Views` contains the shared SwiftUI views used by the app.
- `DaysLeftWidget` contains the modern WidgetKit implementation and timeline/data conversion.
- `daysleft WatchKit App`, `daysleft WatchKit Extension`, and `DaysLeft WatchKit Widget` contain watch-specific UI, connectivity, and complications.
- `daysleft/AppIntents` contains Siri Shortcuts and widget configuration intents.
- `Unit Tests` covers date calculations; `UI Tests` and `fastlane/SnapshotHelper.swift` cover UI screenshots.
- `fastlane/metadata` and `fastlane/screenshots` are App Store Connect content. Treat them as release assets, not generated source.

## Data and feature flow

The main settings model is `AppSettings`. `AppSettingsDataManager` reads and writes the settings through `DataProviderProtocol`, so production storage and test storage can be swapped without changing calculation code. `AppSettings+DayCalculations` is the source of truth for `daysLength`, `daysGone`, and `daysLeft`; preserve its inclusive-date and weekday-only semantics when changing behavior.

When settings need to appear outside the main app, update the relevant integration as well: WatchConnectivity for the watch app, WidgetKit timeline/data providers for widgets, and App Intents for Shortcuts and configurable widgets. Avoid duplicating day-counting logic in those targets.

## Development practices

- Use Swift and the existing target/module structure. Prefer small, focused changes and existing abstractions over new global state.
- Keep business rules in models/model extensions or view models; keep SwiftUI views focused on rendering and user interaction.
- Use `Calendar` and the existing date helpers for date calculations. Normalize dates consistently with the current `startOfDay` behavior, and add tests for boundary dates, weekends, and dates before/after the event.
- Preserve user-facing strings in `daysleft/Localizable.strings` and the string-dict resources rather than hard-coding new UI copy. Add accessibility labels for meaningful images and controls.
- Follow the repository SwiftLint configuration in `swiftlint.yml`; do not broadly disable rules to get a change through. Keep target membership and entitlements correct when adding files.
- Do not commit credentials or machine-specific configuration. `GoogleService-Info.plist` is required for a fully configured build but is not supplied in this repository; obtain it separately and keep it out of version control.
- Be careful with changes to entitlements, bundle identifiers, App Store metadata, signing, Firebase, iCloud, and WatchConnectivity: these affect release/runtime configuration beyond the source file being edited.

## Build, test, and lint

Run commands from the repository root. The exact simulator/device availability depends on the installed Xcode version.

```sh
# Unit tests through the checked-in Fastlane lane
bundle exec fastlane ios test

# UI screenshots
bundle exec fastlane ios screenshots

# SwiftLint, if installed via Homebrew
swiftlint lint --config swiftlint.yml
```

For focused local work, use Xcode schemes in `DaysLeft.xcodeproj`: `DaysLeft` for the app/unit-test workflow, `UI Tests` for screenshot tests, and the watch/widget schemes when changing those extensions. Before handing off a change, run the relevant tests and lint, and build every affected target when shared code or target membership changes.

## Release workflow

Fastlane lanes in `fastlane/Fastfile` upload iOS/macOS metadata and screenshots to App Store Connect. Review generated screenshots and metadata before uploading. Do not run upload lanes unless explicitly requested and the correct signing/App Store Connect credentials are available.

## Change checklist

1. Identify whether the change affects shared calculations, persistence, presentation, or a platform extension.
2. Update the source of truth and all consumers that display or transfer that value.
3. Add or update unit/UI coverage, especially for date boundaries and platform-specific behavior.
4. Run relevant tests and SwiftLint; inspect the diff for accidental project-file, metadata, or secret changes.

