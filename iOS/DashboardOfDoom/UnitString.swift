import Foundation

class StringDimension: Dimension {
    private let identifierString: String

    init(symbol: String, identifier: String) {
        self.identifierString = identifier
        super.init(symbol: symbol)
    }

    required init?(coder: NSCoder) {
        self.identifierString = ""
        super.init(coder: coder)
    }
}

class UnitString: StringDimension {
    static let base = UnitString(symbol: "base", identifier: "base")

    static func custom(symbol: String, identifier: String) -> UnitString {
        return UnitString(symbol: symbol, identifier: identifier)
    }

    override class func baseUnit() -> Self {
        return base as! Self
    }
}

