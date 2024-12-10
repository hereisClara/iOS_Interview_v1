//
//  AccountManager.swift
//  InterviewV1_Clara
//
//  Created by 小妍寶 on 2024/12/9.
//

import Foundation
import Alamofire

class AccountManager {
    
    private let usdFixedDepositAPI = "https://willywu0201.github.io/data/usdFixed1.json"
    private let usdSavingsAPI = "https://willywu0201.github.io/data/usdSavings1.json"
    private let usdDigitalAPI = "https://willywu0201.github.io/data/usdDigital1.json"
    
    private let khrFixedDepositAPI = "https://willywu0201.github.io/data/khrFixed1.json"
    private let khrSavingsAPI = "https://willywu0201.github.io/data/khrSavings1.json"
    private let khrDigitalAPI = "https://willywu0201.github.io/data/khrDigital1.json"
    
    private let refreshUsdFixedDepositAPI = "https://willywu0201.github.io/data/usdFixed2.json"
    private let refreshUsdSavingsAPI = "https://willywu0201.github.io/data/usdSavings2.json"
    private let refreshUsdDigitalAPI = "https://willywu0201.github.io/data/usdDigital2.json"
    
    private let refreshKhrFixedDepositAPI = "https://willywu0201.github.io/data/khrFixed2.json"
    private let refreshKhrSavingsAPI = "https://willywu0201.github.io/data/khrSavings2.json"
    private let refreshKhrDigitalAPI = "https://willywu0201.github.io/data/khrDigital2.json"
    
    func fetchAndCalculateBalances(isRefresh: Bool, completion: @escaping (Double, Double) -> Void) {
            var totalUSDBalance: Double = 0.0
            var totalKHRBalance: Double = 0.0
            
            let group = DispatchGroup()
            
            let usdFixedDepositURL = URL(string: isRefresh ? refreshUsdFixedDepositAPI : usdFixedDepositAPI)!
            let usdSavingsURL = URL(string: isRefresh ? refreshUsdSavingsAPI : usdSavingsAPI)!
            let usdDigitalURL = URL(string: isRefresh ? refreshUsdDigitalAPI : usdDigitalAPI)!
            
            let khrFixedDepositURL = URL(string: isRefresh ? refreshKhrFixedDepositAPI : khrFixedDepositAPI)!
            let khrSavingsURL = URL(string: isRefresh ? refreshKhrSavingsAPI : khrSavingsAPI)!
            let khrDigitalURL = URL(string: isRefresh ? refreshKhrDigitalAPI : khrDigitalAPI)!
            
            func fetchAndAddBalance<T: Decodable>(url: URL, type: T.Type, handler: @escaping (T) -> Void) {
                group.enter()
                URLSession.shared.dataTask(with: url) { data, _, error in
                    defer { group.leave() }
                    guard let data = data, error == nil else { return }
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(T.self, from: data)
                        handler(decoded)
                    } catch {
                        print("Failed to decode: \(error.localizedDescription)")
                    }
                }.resume()
            }
            
            fetchAndAddBalance(url: usdFixedDepositURL, type: FixedDepositResponse.self) { response in
                if response.msgCode == "0000" {
                    totalUSDBalance += response.result.fixedDepositList.reduce(0) { $0 + $1.balance }
                }
            }
            
            fetchAndAddBalance(url: usdSavingsURL, type: SavingsResponse.self) { response in
                if response.msgCode == "0000" {
                    totalUSDBalance += response.result.savingsList.reduce(0) { $0 + $1.balance }
                }
            }
            
            fetchAndAddBalance(url: usdDigitalURL, type: SavingsResponse.self) { response in
                if response.msgCode == "0000" {
                    totalUSDBalance += response.result.savingsList.reduce(0) { $0 + $1.balance }
                }
            }
            
            fetchAndAddBalance(url: khrFixedDepositURL, type: FixedDepositResponse.self) { response in
                if response.msgCode == "0000" {
                    totalKHRBalance += response.result.fixedDepositList.reduce(0) { $0 + $1.balance }
                }
            }
            
            fetchAndAddBalance(url: khrSavingsURL, type: SavingsResponse.self) { response in
                if response.msgCode == "0000" {
                    totalKHRBalance += response.result.savingsList.reduce(0) { $0 + $1.balance }
                }
            }
            
            fetchAndAddBalance(url: khrDigitalURL, type: SavingsResponse.self) { response in
                if response.msgCode == "0000" {
                    totalKHRBalance += response.result.savingsList.reduce(0) { $0 + $1.balance }
                }
            }
            
            group.notify(queue: .main) {
                completion(totalUSDBalance, totalKHRBalance)
            }
        }
}
