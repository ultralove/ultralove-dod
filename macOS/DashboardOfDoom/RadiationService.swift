import Foundation

class RadiationService {
    static func fetchStations() async throws -> Data? {
        let endpoint =
            "https://www.imis.bfs.de/ogc/opendata/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=opendata:odlinfo_odl_1h_latest&outputFormat=application/json"
        guard let url = URL(string: endpoint) else {
            return nil
        }
        trace.debug("Fetching radiation measurement stations...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched radiation measurement stations.")
        return data
    }

    static func fetchMeasurements(for id: String) async throws -> Data? {
        let endpoint = String(
            format: "https://www.imis.bfs.de/ogc/opendata/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=opendata:odlinfo_timeseries_odl_1h&outputFormat=application/json&viewparams=kenn:%@",
            id)
        guard let url = URL(string: endpoint) else {
            return nil
        }
        trace.debug("Fetching radiation measurement...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched radiation measurement.")
        return data
    }
}
