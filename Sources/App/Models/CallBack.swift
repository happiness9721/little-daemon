//
//  CallBack.swift
//  little-daemon
//
//  Created by 江承諭 on 2017/8/11.
//
//

import Foundation
import LineBot
import HTTP

class CallBack {

  static func reply(message: String, source: LineEventBase.Source) throws -> [LineMessage] {
    var messages = [LineMessage]()
    let sourceInfo = makeSourceInfo(source: source)
    if let lastMessageLog = try MessageLog.makeQuery()
                                          .filter("sourceInfo", sourceInfo)
                                          .first() {
      lastMessageLog.message = message
      try lastMessageLog.save()
    } else {
      let messageLog = MessageLog(sourceInfo: sourceInfo, message: message)
      try messageLog.save()
    }

    let routeMessage = try TRARoute.queryTRARoute(message: message)
    messages.append(contentsOf: routeMessage.map { LineMessage.text(text: $0) })

    let raw = "$1 LIKE keyword"
    if let replyText = try ReplyText.makeQuery().filter(raw: raw, [message]).all().random {
      messages.append(.text(text: replyText.text))
    }

    if let replyImage = try ReplyImage.makeQuery().filter(raw: raw, [message]).all().random {
      messages.append(.image(originalContentUrl: replyImage.originalContentUrl,
                             previewImageUrl: replyImage.previewImageUrl))
    }
    if message == "測試" {
      messages.append(.text(text: "測試"))
      messages.append(.image(originalContentUrl: "https://pbs.twimg.com/media/CmnGPoPVMAAZ32M.jpg",
                             previewImageUrl: "https://pbs.twimg.com/media/CmnGPoPVMAAZ32M.jpg"))
      messages.append(.sticker(packageId: "1", stickerId: "2"))
      messages.append(.location(title: "my location",
                                address: "〒150-0002 東京都渋谷区渋谷２丁目２１−１",
                                latitude: 35.65910807942215,
                                longitude: 139.70372892916203))
    }
    return messages
  }

  static private func makeSourceInfo(source: LineEventBase.Source) -> String {
    var sourceInfo = String()
    sourceInfo += "type: \(source.type.rawValue);"
    sourceInfo += "userId: \(source.userId);"
    if let groupId = source.groupId {
      sourceInfo += "groupId: \(groupId);"
    }
    if let roomId = source.roomId {
      sourceInfo += "roomId: \(roomId);"
    }
    return sourceInfo
  }
}

