
import Foundation

final class UpdateManager: ObservableObject {

    @Published var latestVersion = "Unknown"
    @Published var downloadURL = ""

    func check() async {

        guard let url = URL(string:
            "https://example.com/update.json")
        else { return }

        do {

            let (data, _) =
                try await URLSession.shared.data(from: url)

            if let json =
                try JSONSerialization.jsonObject(with: data)
                as? [String: Any] {

                DispatchQueue.main.async {

                    self.latestVersion =
                        json["version"] as? String ?? "Unknown"

                    self.downloadURL =
                        json["firmware_url"] as? String ?? ""
                }
            }

        } catch {
            print(error)
        }
    }
}
