//
//  Model.swift
//  InterviewV1_Clara
//
//  Created by 小妍寶 on 2024/12/9.
//

import Foundation

struct Banner: Decodable {
    let adSeqNo: Int
    let linkUrl: String
}

struct BannerResponse: Decodable {
    let msgCode: String
    let msgContent: String
    let result: BannerResult
}

struct BannerResult: Decodable {
    let bannerList: [Banner]
}

struct Account: Decodable {
    let account: String
    let curr: String
    let balance: Double
}

struct FixedDepositResponse: Decodable {
    let msgCode: String
    let msgContent: String
    let result: FixedDepositResult
}

struct FixedDepositResult: Decodable {
    let fixedDepositList: [Account]
}

struct SavingsResponse: Decodable {
    let msgCode: String
    let msgContent: String
    let result: SavingsResult
}

struct SavingsResult: Decodable {
    let savingsList: [Account]
}

struct NotificationResponse: Codable {
    let msgCode: String
    let msgContent: String
    let result: NotificationResult
}

struct NotificationResult: Codable {
    let messages: [NotificationMessage]
}

struct NotificationMessage: Codable {
    let status: Bool
    let updateDateTime: String
    let title: String
    let message: String
}

struct FavoriteResponse: Codable {
    let msgCode: String
    let msgContent: String
    let result: FavoriteResult
}

struct FavoriteResult: Codable {
    let favoriteList: [FavoriteItem]
}

struct FavoriteItem: Codable {
    let nickname: String
    let transType: String
}
