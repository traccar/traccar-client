import AppIntents
import TSLocationManager

@available(iOS 16.0, *)
struct StartTrackingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Tracking"
    static var description = IntentDescription("Start continuous location tracking")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        BackgroundGeolocation.sharedInstance().start()
        return .result()
    }
}

@available(iOS 16.0, *)
struct StopTrackingIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Tracking"
    static var description = IntentDescription("Stop continuous location tracking")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        BackgroundGeolocation.sharedInstance().stop()
        return .result()
    }
}

@available(iOS 16.0, *)
struct TraccarShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTrackingIntent(),
            phrases: [
                "Start tracking in \(.applicationName)",
                "Start location tracking in \(.applicationName)",
                "Enable tracking in \(.applicationName)",
                "Turn on tracking in \(.applicationName)",
            ],
            shortTitle: "Start Tracking",
            systemImageName: "play.fill"
        )
        AppShortcut(
            intent: StopTrackingIntent(),
            phrases: [
                "Stop tracking in \(.applicationName)",
                "Stop location tracking in \(.applicationName)",
                "Disable tracking in \(.applicationName)",
                "Turn off tracking in \(.applicationName)",
            ],
            shortTitle: "Stop Tracking",
            systemImageName: "stop.fill"
        )
    }
}
