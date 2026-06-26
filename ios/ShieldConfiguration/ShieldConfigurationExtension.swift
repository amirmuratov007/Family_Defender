import Foundation

#if canImport(ManagedSettings)
import ManagedSettings
import ManagedSettingsUI

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: .black,
            icon: nil,
            title: ShieldConfiguration.Label(text: "Пауза Heimdall", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Это действие похоже на риск. Позови доверенного взрослого перед продолжением.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Понятно", color: .black),
            primaryButtonBackgroundColor: .systemYellow
        )
    }
}
#endif
