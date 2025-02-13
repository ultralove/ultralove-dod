import SwiftUI

struct ActivityIndicator: View {
   var body: some View {
      VStack {
         ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
//                  .scaleEffect(1.0)
            .padding()
      }
   }
}

