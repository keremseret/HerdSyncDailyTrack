import Foundation
import UIKit
import Darwin
import AppsFlyerLib

class TokenService {
    static let shared = TokenService()
    
    private let tokenKey = "saved_token"
    private let linkKey = "saved_link"
    
    private init() {}
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func saveLink(_ link: String) {
        UserDefaults.standard.set(link, forKey: linkKey)
    }
    
    func getLink() -> String? {
        return UserDefaults.standard.string(forKey: linkKey)
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: linkKey)
    }
    
    func fetchToken(completion: @escaping (String?, String?) -> Void) {
        let osVersion = UIDevice.current.systemVersion
        let language = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        let region = Locale.current.region?.identifier ?? "US"
        let deviceModel = getDeviceModel()
        let appsFlayerId = AppsFlyerLib.shared().getAppsFlyerUID()
        
        let linkString = "https://gtappinfo.site/ios-herdsync-dailytrack/server.php?p=Bs2675kDjkb5Ga&os=\(osVersion)&lng=\(language)&devicemodel=\(deviceModel)&country=\(region)&appsflyerid=\(appsFlayerId)"
        
        guard let linkAddress = URL(string: linkString) else {
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: linkAddress) { data, response, error in
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8),
                  error == nil else {
                completion(nil, nil)
                return
            }
            
            if let hashIndex = responseString.firstIndex(of: "#") {
                let token = String(responseString[..<hashIndex])
                let link = String(responseString[responseString.index(after: hashIndex)...])
                completion(token, link)
            } else {
                completion(nil, nil)
            }
        }.resume()
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        
        let modelMap: [String: String] = [
            "iPhone14,7": "iphone13mini",
            "iPhone14,8": "iphone13",
            "iPhone14,2": "iphone13pro",
            "iPhone14,3": "iphone13promax",
            "iPhone15,2": "iphone14",
            "iPhone15,3": "iphone14plus",
            "iPhone15,4": "iphone14pro",
            "iPhone15,5": "iphone14promax",
            "iPhone16,1": "iphone15",
            "iPhone16,2": "iphone15plus",
            "iPhone16,3": "iphone15pro",
            "iPhone16,4": "iphone15promax",
            "iPhone17,1": "iphone16",
            "iPhone17,2": "iphone16plus",
            "iPhone17,3": "iphone16pro",
            "iPhone17,4": "iphone16promax"
        ]
        
        if let model = modelCode, let mapped = modelMap[model] {
            return mapped
        }
        
        if let model = modelCode {
            let cleaned = model.replacingOccurrences(of: "iPhone", with: "iphone")
                .replacingOccurrences(of: ",", with: ".")
            return cleaned.lowercased()
        }
        
        return "iphone"
    }
}

