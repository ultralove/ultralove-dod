import MapKit
import SwiftUI

struct PointOfInterestView: MapContent {
    let pointOfInterest: PointOfInterest
    let color: Color

    var body: some MapContent {
        Annotation("", coordinate: pointOfInterest.location.coordinate, anchor: .center) {
            VStack {
                if self.color == .green {
                    Circle()
                        .fill(Color.spaeti)
                        .frame(width: 6, height: 6)

                }
                else {
                    Circle()
                        .fill(self.color.opacity(0.67))
                        .frame(width: 11, height: 11)

                }
            }
        }
    }
}
