//
//  NotificationManager.swift
//  InterviewV1_Clara
//
//  Created by 小妍寶 on 2024/12/9.
//

import Foundation

class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    private let notificationAPI = "https://willywu0201.github.io/data/notificationList.json"
    
    func fetchNotifications(completion: @escaping (Result<[NotificationMessage], Error>) -> Void) {
        guard let url = URL(string: notificationAPI) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(NotificationResponse.self, from: data)
                
                if response.msgCode == "0000" {
                    let sortedMessages = response.result.messages.sorted {
                        guard let date1 = self.parseDate(from: $0.updateDateTime),
                              let date2 = self.parseDate(from: $1.updateDateTime) else {
                            return false
                        }
                        return date1 > date2
                    }
                    completion(.success(sortedMessages))
                } else {
                    completion(.failure(NSError(domain: response.msgContent, code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func parseDate(from string: String) -> Date? {
        let formats = [
            "yyyy/MM/dd HH:mm:ss",
            "HH:mm:ss yyyy/MM/dd",
            "yyyy-MM-dd'T'HH:mm:ss",
        ]
        
        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    func fetchBannerData(completion: @escaping (Result<[Banner], Error>) -> Void) {
            let urlString = "https://willywu0201.github.io/data/banner.json"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    let bannerResponse = try decoder.decode(BannerResponse.self, from: data)
                    if bannerResponse.msgCode == "0000" {
                        let banners = bannerResponse.result.bannerList
                        completion(.success(banners))
                    } else {
                        let error = NSError(domain: "HomeManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch banners: \(bannerResponse.msgContent)"])
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
        
        func fetchFavoriteList(completion: @escaping (Result<[FavoriteItem], Error>) -> Void) {
            let urlString = "https://willywu0201.github.io/data/favoriteList.json"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    let favoriteResponse = try decoder.decode(FavoriteResponse.self, from: data)
                    if favoriteResponse.msgCode == "0000" {
                        completion(.success(favoriteResponse.result.favoriteList))
                    } else {
                        let error = NSError(domain: "HomeManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch favorite list: \(favoriteResponse.msgContent)"])
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}
