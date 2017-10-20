//
//  CallBack.swift
//  little-daemon
//
//  Created by 江承諭 on 2017/8/11.
//
//

import Foundation
import LineBot

class CallBack {

  let replyToken: String
  let sourceInfo: String
  let message: String
  private let lineBot: LineBot

  init(replyToken: String, sourceInfo: String, message: String) {
    self.replyToken = replyToken
    self.sourceInfo = sourceInfo
    self.message = message
    self.lineBot = LineBot(replyToken: replyToken)
  }

  func createReplyMessage() throws {
    if let lastMessageLog = try MessageLog.makeQuery()
                                          .filter("sourceInfo", sourceInfo)
                                          .first() {
      lastMessageLog.message = message
      try lastMessageLog.save()
    } else {
      let messageLog = MessageLog(sourceInfo: sourceInfo, message: message)
      try messageLog.save()
    }

    do {
      try TRARoute.queryTRARoute(message: message, lineBot: lineBot)
    } catch {
      lineBot.add(message: "伺服器忙碌中，查詢失敗😇")
      print("Error: \(error._domain)")
      print(Thread.callStackSymbols)
    }

    let raw = "$1 LIKE keyword"
    if let replyText = try ReplyText.makeQuery().filter(raw: raw, [message]).all().random {
      lineBot.add(message: replyText.text)
    }

    if let replyImage = try ReplyImage.makeQuery().filter(raw: raw, [message]).all().random {
      lineBot.add(originalContentUrl: replyImage.originalContentUrl,
                  previewImageUrl: replyImage.previewImageUrl)
    }
  }

  func send() {
    lineBot.send()
  }

  func json() throws -> JSON {
    return try JSON(lineBot.body.makeNode(in: nil))
  }
}

