import Foundation
import Network

// Network error types
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingError(error: Error)
    case networkUnavailable
    case taskCancelled
    case timeout
}

actor NetworkManager {
    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isConnected = false
    private(set) var connectionType: ConnectionType = .unknown

    // Maximum number of retry attempts
    private let maxRetryAttempts = 5

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        setupMonitor()
    }

    private nonisolated func setupMonitor() {
        monitor.start(queue: monitorQueue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            Task {
                await self.updateConnectionStatus(path: path)
            }
        }
    }

    func startMonitoring() {
        setupMonitor()
    }

    private func updateConnectionStatus(path: NWPath) async {
        isConnected = path.status == .satisfied
        getConnectionType(path)

        // Post notification about network status change
        await MainActor.run {
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        }
        else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        }
        else {
            connectionType = .unknown
        }
    }

    // Perform network request using Result type rather than throws
    func performRequest<T: Decodable>(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async -> Result<T, NetworkError> {

        return await attemptRequest(
            urlString: urlString,
            method: method,
            body: body,
            headers: headers,
            decoder: decoder,
            attempt: 1
        )
    }

    private func attemptRequest<T: Decodable>(
        urlString: String,
        method: String,
        body: Data?,
        headers: [String: String]?,
        decoder: JSONDecoder,
        attempt: Int
    ) async -> Result<T, NetworkError> {

        // Check network availability
        if !isConnected {
            // Wait for network to become available
            let waitResult = await waitForConnection(timeoutSeconds: 60)
            if case .failure = waitResult {
                return .failure(.networkUnavailable)
            }
        }

        // Validate URL
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        // Setup request
        var request = URLRequest(url: url)
        request.httpMethod = method

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            request.httpBody = body
        }

        // Perform network request
        let dataResult: Result<(Data, HTTPURLResponse), NetworkError>

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            dataResult = .success((data, httpResponse))
        }
        catch let urlError as URLError {
            // Map URLErrors to NetworkErrors
            let networkError: NetworkError
            switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    networkError = .networkUnavailable
                case .timedOut:
                    networkError = .timeout
                case .cancelled:
                    networkError = .taskCancelled
                default:
                    networkError = .invalidResponse
            }

            // Handle retry
            if attempt < maxRetryAttempts {
                // Calculate exponential backoff time
                let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)

                // Use a standard Task.sleep without try
                do {
                    try await Task.sleep(for: .seconds(delaySeconds))
                }
                catch {
                    return .failure(.taskCancelled)
                }

                // Retry
                return await attemptRequest(
                    urlString: urlString,
                    method: method,
                    body: body,
                    headers: headers,
                    decoder: decoder,
                    attempt: attempt + 1
                )
            }

            return .failure(networkError)
        }
        catch {
            return .failure(.invalidResponse)
        }

        // Process response
        switch dataResult {
            case .success((let data, let httpResponse)):
                // Check status code
                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    return .failure(.serverError(statusCode: httpResponse.statusCode))
                }

                // Decode response
                do {
                    let decodedData = try decoder.decode(T.self, from: data)
                    return .success(decodedData)
                }
                catch {
                    return .failure(.decodingError(error: error))
                }

            case .failure(let error):
                return .failure(error)
        }
    }

    // Wait for network connection using Result type
    private func waitForConnection(timeoutSeconds: Double) async -> Result<Void, NetworkError> {
        if isConnected { return .success(()) }

        // Create a network monitor to track when connection becomes available
        return await withCheckedContinuation { continuation in
            let connectionMonitor = NWPathMonitor()
            let monitorQueue = DispatchQueue(label: "ConnectionWaitMonitor")

            // Create a task for the timeout
            let timeoutTask = Task {
                do {
                    try await Task.sleep(for: .seconds(timeoutSeconds))
                }
                catch {
                    continuation.resume(returning: .failure(.taskCancelled))
                }
                connectionMonitor.cancel()
                continuation.resume(returning: .failure(.timeout))
            }

            connectionMonitor.start(queue: monitorQueue)
            connectionMonitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    timeoutTask.cancel()
                    connectionMonitor.cancel()
                    continuation.resume(returning: .success(()))
                }
            }
        }
    }
}

// Notification extension
extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
