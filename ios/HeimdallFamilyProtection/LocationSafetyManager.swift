import Combine
import CoreLocation
import Foundation

final class LocationSafetyManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var statusText = "Геолокация ещё не включена."
    @Published var authorizationText = "Разрешение не запрошено."
    @Published var isMonitoring = false
    @Published var lastCoordinate: CLLocationCoordinate2D?
    @Published var lastAccuracyMeters: CLLocationAccuracy = 0

    var onLocationUpdate: ((CLLocationCoordinate2D, CLLocationAccuracy) -> Void)?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 80
        refreshAuthorizationText(for: manager.authorizationStatus)
    }

    func requestAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusText = "Службы геолокации выключены в iOS."
            return
        }
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusText = "Службы геолокации выключены в iOS."
            return
        }
        manager.requestAlwaysAuthorization()
    }

    func startMonitoring() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusText = "Службы геолокации выключены в iOS."
            return
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.allowsBackgroundLocationUpdates = manager.authorizationStatus == .authorizedAlways
            manager.pausesLocationUpdatesAutomatically = true
            isMonitoring = true
            statusText = "Мониторинг геолокации включён."
            manager.startUpdatingLocation()
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            statusText = "Геолокация запрещена в настройках iOS."
        @unknown default:
            statusText = "Статус геолокации неизвестен."
        }
    }

    func stopMonitoring() {
        manager.stopUpdatingLocation()
        isMonitoring = false
        statusText = "Мониторинг геолокации остановлен."
    }

    func checkNow() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusText = "Службы геолокации выключены в iOS."
            return
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            statusText = "Запрашиваю текущую геолокацию."
            manager.requestLocation()
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            statusText = "Геолокация запрещена в настройках iOS."
        @unknown default:
            statusText = "Статус геолокации неизвестен."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.refreshAuthorizationText(for: manager.authorizationStatus)
            if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                self.statusText = "Геолокация разрешена. Можно включить мониторинг."
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastCoordinate = location.coordinate
            self.lastAccuracyMeters = location.horizontalAccuracy
            self.statusText = "Последняя точка обновлена: \(Self.format(location.coordinate))."
            self.onLocationUpdate?(location.coordinate, location.horizontalAccuracy)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.statusText = "Не удалось получить геолокацию: \(error.localizedDescription)"
        }
    }

    static func format(_ coordinate: CLLocationCoordinate2D) -> String {
        "\(String(format: "%.5f", coordinate.latitude)), \(String(format: "%.5f", coordinate.longitude))"
    }

    private func refreshAuthorizationText(for status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            authorizationText = "Разрешено всегда."
        case .authorizedWhenInUse:
            authorizationText = "Разрешено при использовании."
        case .denied:
            authorizationText = "Запрещено."
        case .restricted:
            authorizationText = "Ограничено системой."
        case .notDetermined:
            authorizationText = "Разрешение не запрошено."
        @unknown default:
            authorizationText = "Неизвестный статус."
        }
    }
}
