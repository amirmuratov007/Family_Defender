import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject private var shieldManager: FamilyShieldManager
    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            List {
                Section("Protection") {
                    Button("Request Parent Authorization") {
                        Task { await shieldManager.requestAuthorization() }
                    }

                    Button("Select Apps to Protect") {
                        isPickerPresented = true
                    }

                    Button("Apply Family Rules") {
                        shieldManager.applyDefaultRules()
                    }
                }

                Section("Status") {
                    Text(shieldManager.status)
                }
            }
            .navigationTitle("Heimdall")
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $shieldManager.selection)
        }
    }
}
