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
            title: ShieldConfiguration.Label(text: "Heimdall protection pause", color: .white),
            subtitle: ShieldConfiguration.Label(text: "This action looks risky. Call a trusted adult before continuing.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "I understand", color: .black),
            primaryButtonBackgroundColor: .systemYellow
        )
    }
}
#endif
