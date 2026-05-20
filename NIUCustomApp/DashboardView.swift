
import SwiftUI

struct DashboardView: View {

    @StateObject private var ble = BLEManager()
    @State private var regen: Double = 0.5

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    Text("NIU Dashboard")
                        .font(.largeTitle.bold())

                    HStack {
                        Circle()
                            .fill(ble.connected ? Color.green : (ble.isBluetoothOn ? Color.orange : Color.red))
                            .frame(width: 10, height: 10)
                        Text(ble.foundDeviceName)
                            .foregroundColor(.secondary)
                    }

                    telemetry("Power", "\(Int(ble.watts)) W")
                    telemetry("Speed", "\(Int(ble.speed)) km/h")
                    telemetry("Motor Temp", "\(Int(ble.temp)) °C")
                    telemetry("Battery Current", "\(Int(ble.batteryCurrent)) A")

                    VStack(alignment: .leading) {

                        Text("Rekuperation")

                        Slider(value: $regen)

                        Text("Level: \(Int(regen * 100))%")
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(20)
                }
                .padding()
            }
        }
    }

    func telemetry(_ title: String, _ value: String) -> some View {

        VStack {
            Text(title)
                .font(.headline)

            Text(value)
                .font(.title.bold())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20)
    }
}

#Preview {
    DashboardView()
}
