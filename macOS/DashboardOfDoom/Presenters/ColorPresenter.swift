import Foundation
import SwiftUI

@Observable class ColorPresenter {
    var tintColor: Color = .cyan
    var colorScheme: ColorScheme {
        return UserDefaults.standard.bool(forKey: "enableDarkTheme") == true ? .dark : .light
    }
}
