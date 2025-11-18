import Foundation

enum ProductType: String, CaseIterable {
    case milk
    case eggs
    case wool
    
    var localizedName: String {
        switch self {
        case .milk:
            return LocalizedString("product.milk")
        case .eggs:
            return LocalizedString("product.eggs")
        case .wool:
            return LocalizedString("product.wool")
        }
    }
    
    var unit: String {
        switch self {
        case .milk:
            return LocalizedString("unit.liters")
        case .eggs:
            return LocalizedString("unit.pieces")
        case .wool:
            return LocalizedString("unit.kg")
        }
    }
}

