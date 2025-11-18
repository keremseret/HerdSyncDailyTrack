import Foundation

enum Language: String, CaseIterable {
    case russian = "ru"
    case english = "en"
    case arabic = "ar"
    case catalan = "ca"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case croatian = "hr"
    case czech = "cs"
    case danish = "da"
    case dutch = "nl"
    case englishAustralia = "en-AU"
    case englishCanada = "en-CA"
    case englishUK = "en-GB"
    case englishUS = "en-US"
    case finnish = "fi"
    case french = "fr"
    case frenchCanada = "fr-CA"
    case german = "de"
    case greek = "el"
    case hebrew = "he"
    case hindi = "hi"
    case hungarian = "hu"
    case indonesian = "id"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case malay = "ms"
    case norwegian = "no"
    case polish = "pl"
    case portugueseBrazil = "pt-BR"
    case portuguesePortugal = "pt-PT"
    case romanian = "ro"
    case slovak = "sk"
    case spanishMexico = "es-MX"
    case spanishSpain = "es"
    case swedish = "sv"
    case thai = "th"
    case turkish = "tr"
    case ukrainian = "uk"
    case vietnamese = "vi"
    
    var displayName: String {
        switch self {
        case .russian:
            return "Русский"
        case .english:
            return "English"
        case .arabic:
            return "العربية"
        case .catalan:
            return "Català"
        case .chineseSimplified:
            return "简体中文"
        case .chineseTraditional:
            return "繁體中文"
        case .croatian:
            return "Hrvatski"
        case .czech:
            return "Čeština"
        case .danish:
            return "Dansk"
        case .dutch:
            return "Nederlands"
        case .englishAustralia:
            return "English (Australia)"
        case .englishCanada:
            return "English (Canada)"
        case .englishUK:
            return "English (U.K.)"
        case .englishUS:
            return "English (U.S.)"
        case .finnish:
            return "Suomi"
        case .french:
            return "Français"
        case .frenchCanada:
            return "Français (Canada)"
        case .german:
            return "Deutsch"
        case .greek:
            return "Ελληνικά"
        case .hebrew:
            return "עברית"
        case .hindi:
            return "हिन्दी"
        case .hungarian:
            return "Magyar"
        case .indonesian:
            return "Bahasa Indonesia"
        case .italian:
            return "Italiano"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .malay:
            return "Bahasa Melayu"
        case .norwegian:
            return "Norsk"
        case .polish:
            return "Polski"
        case .portugueseBrazil:
            return "Português (Brasil)"
        case .portuguesePortugal:
            return "Português (Portugal)"
        case .romanian:
            return "Română"
        case .slovak:
            return "Slovenčina"
        case .spanishMexico:
            return "Español (México)"
        case .spanishSpain:
            return "Español (España)"
        case .swedish:
            return "Svenska"
        case .thai:
            return "ไทย"
        case .turkish:
            return "Türkçe"
        case .ukrainian:
            return "Українська"
        case .vietnamese:
            return "Tiếng Việt"
        }
    }
    
    var identifier: String {
        return rawValue
    }
}

