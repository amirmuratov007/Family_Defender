import Foundation

#if canImport(DeviceActivity)
import DeviceActivity

final class MonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Production flow:
        // Send a minimal risk event to the parent alert backend.
    }
}
#endif
