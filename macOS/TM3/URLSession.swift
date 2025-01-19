import Foundation

extension URLSession {
    func dataWithRetry (from url: URL, retryCount: Int = 3, retryInterval: TimeInterval = 1.0, delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
        var lastError: Error?

        for attempt in 0..<retryCount {
            do {
                return try await self.data(from: url, delegate: delegate)
            } catch {
                lastError = error

                // Check if we should retry
                if attempt < retryCount - 1 {
                    try await Task.sleep(nanoseconds: UInt64(retryInterval * 1_000_000_000))
                    continue
                }
            }
        }
        throw lastError ?? URLError(.unknown)
    }
}

