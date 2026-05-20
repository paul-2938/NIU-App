
import SwiftUI

struct FirmwareView: View {

    @StateObject private var updater = UpdateManager()

    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                Text("Firmware Updates")
                    .font(.largeTitle.bold())

                Text("Latest Version: \(updater.latestVersion)")

                Button("Check Updates") {
                    Task {
                        await updater.check()
                    }
                }

                if !updater.downloadURL.isEmpty {

                    Link("Download Firmware",
                         destination: URL(string: updater.downloadURL)!)
                }
            }
            .padding()
        }
    }
}
