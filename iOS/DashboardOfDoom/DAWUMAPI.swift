import Foundation

class DAWUMAPI {
    static func fetchPolls() async throws -> Data? {
        let endpoint = "https://api.dawum.de"
        guard let url = URL(string: endpoint) else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
