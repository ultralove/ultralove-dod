import Foundation

class RKIAPI {
    static func fetchIncidence(id: String) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/incidence/100") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
