import MapKit
import SwiftUI

struct WeatherView: View {
   @State private var viewModel = WeatherViewModel.shared

   var body: some View {
      if viewModel.lastUpdate == nil {
         ActivityIndicator()
      }
      else {
         _view()
      }
   }

   func _view() -> some View {
      VStack {
         HStack {
            Text(String(format: "Current weather conditions:"))
               .font(.headline)
            Spacer()
         }
         Map(position: $viewModel.region, interactionModes: []) {
            Annotation(coordinate: viewModel.coordinate, anchor: .leading) {
               VStack {
                  HStack {
                     Image(systemName: viewModel.conditionsSymbol)
                        .font(.title)
                     Spacer()
                     Text(String(format: "%.1f%@", viewModel.actualTemperature?.value ?? Double.nan, viewModel.actualTemperature?.unit.symbol ?? ""))
                        .font(.title)
                     Spacer()
                     Text(String(format: "%.1f%@", viewModel.apparentTemperature?.value ?? Double.nan, viewModel.apparentTemperature?.unit.symbol ?? ""))
                        .font(.title3)
                  }
               }
               .padding(5)
               .padding(.horizontal, 5)
               .background(.opacity(0.125))
               .foregroundStyle(.black)
               .clipShape(.capsule(style: .continuous))

            } label: {
            }
         }
         HStack {
            Text("Last update: \(Date.absoluteString(date: viewModel.lastUpdate))")
               .font(.footnote)
            Spacer()
         }
      }
   }

   func updateCameraRegion() -> MKCoordinateRegion {
      let mapPoint = MKMapPoint(viewModel.coordinate)
      let mapRect = MKMapRect(x: mapPoint.x - 9_000, y: mapPoint.y - 9_000, width: 18_000, height: 18_000)
      var newRegion = MKCoordinateRegion(mapRect)
      newRegion.span.latitudeDelta *= 1.0
      newRegion.span.longitudeDelta *= 1.0
      return newRegion
   }
}

#Preview {
   WeatherView()
}
