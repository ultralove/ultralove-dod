import Foundation
import Network

class ReachabilityManager {
    static let shared = ReachabilityManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityMonitor")
    
    private(set) var isConnected = true
    private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            
            if path.usesInterfaceType(.wifi) {
                self?.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.connectionType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                self?.connectionType = .ethernet
            } else {
                self?.connectionType = .unknown
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

extension URLSession {
    func dataWithRetry (from url: URL, retryCount: Int = 3, retryInterval: TimeInterval = 1.0, delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
        var lastError: Error?

        // Check if device is connected before attempting network request
        guard ReachabilityManager.shared.isConnected else {
            throw URLError(.notConnectedToInternet)
        }

        for attempt in 0..<retryCount {
            do {
                let (data, response) = try await self.data(from: url, delegate: delegate)

                // Check HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                // Check status code
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                }

                // Check if data is empty
                guard !data.isEmpty else {
                    throw NetworkError.noData
                }

                return (data, response)

            } catch {
                lastError = error

                // If we lost connectivity during the request, throw immediately
                if !ReachabilityManager.shared.isConnected {
                    throw URLError(.notConnectedToInternet)
                }

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

