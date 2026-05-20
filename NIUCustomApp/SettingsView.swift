
import SwiftUI

struct SettingsView: View {

    @AppStorage("darkMode") var darkMode = true

    var body: some View {

        NavigationStack {

            Form {

                Toggle("Dark Mode", isOn: $darkMode)

                Section("About") {

                    Text("NIU Custom App")
                    Text("SwiftUI + CoreBluetooth")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
