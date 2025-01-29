import Foundation

class RKIAPI {
    static func fetchIncidence(id: String, count: Int = 0) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/incidence/\(count == 0 ? "" : "\(count)")") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
