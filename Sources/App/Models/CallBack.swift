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

  private let lineBot: LineBot

  init?(request: Request) {
    guard let lineBot = LineBot.makeReply(from: request) else {
      return nil
    }
    self.lineBot = lineBot
  }

  func createReplyMessage() throws {
    guard let source = lineBot.source,
          let message = lineBot.receivedMessage else { return }

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

    try TRARoute.queryTRARoute(message: message, lineBot: lineBot)

    let raw = "$1 LIKE keyword"
    if let replyText = try ReplyText.makeQuery().filter(raw: raw, [message]).all().random {
      lineBot.add(message: LineMessageText(text: replyText.text))
    }

    if let replyImage = try ReplyImage.makeQuery().filter(raw: raw, [message]).all().random {
      lineBot.add(message: LineMessageImage(originalContentUrl: replyImage.originalContentUrl,
                                            previewImageUrl: replyImage.previewImageUrl))
    }
    if message == "測試" {
      lineBot.add(message: LineMessageText(text: "測試"))
      lineBot.add(message: LineMessageImage(originalContentUrl: "https://pbs.twimg.com/media/CmnGPoPVMAAZ32M.jpg",
                                            previewImageUrl: "https://pbs.twimg.com/media/CmnGPoPVMAAZ32M.jpg"))
      lineBot.add(message: LineMessageSticker(packageId: "1", stickerId: "2"))
      lineBot.add(message: LineMessageLocation(title: "my location",
                                               address: "〒150-0002 東京都渋谷区渋谷２丁目２１−１",
                                               latitude: 35.65910807942215,
                                               longitude: 139.70372892916203))
    }
  }

  func send() -> Response {
    return lineBot.sendReply()
  }

  private func makeSourceInfo(source: Node) -> String {
    var sourceInfo = String()
    if let type = source.object?["type"]?.string {
      sourceInfo += "type: " + type + ";"
    }
    if let userId = source.object?["userId"]?.string {
      sourceInfo += "userId: " + userId + ";"
    }
    if let groupId = source.object?["groupId"]?.string {
      sourceInfo += "groupId: " + groupId + ";"
    }
    if let roomId = source.object?["roomId"]?.string {
      sourceInfo += "roomId: " + roomId + ";"
    }
    return sourceInfo
  }
}

