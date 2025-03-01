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
                return try await self.data(from: url, delegate: delegate)
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

