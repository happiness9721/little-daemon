//
//  CallBack.swift
//  little-daemon
//
//  Created by 江承諭 on 2017/8/11.
//
//

import Foundation

class CallBack {
  
  let replyToken: String
  let sourceInfo: String
  let message: String
  private let replyMessage: ReplyMessageAPI
  
  init(replyToken: String, sourceInfo: String, message: String) {
    self.replyToken = replyToken
    self.sourceInfo = sourceInfo
    self.message = message
    self.replyMessage = ReplyMessageAPI(replyToken: replyToken)
  }
  
  func createReplyMessage() throws {
    if let lastMessageLog = try MessageLog.makeQuery().sort(MessageLog.updatedAtKey, .descending).first() {
      lastMessageLog.message = message
      try lastMessageLog.save()
    } else {
      let messageLog = MessageLog(sourceInfo: sourceInfo, message: message)
      try messageLog.save()
    }
    
    let raw = "$1 LIKE keyword"
    if let replyText = try ReplyText.makeQuery().filter(raw: raw, [message]).all().random {
      replyMessage.add(message: replyText.text)
    }
    
    if let replyImage = try ReplyImage.makeQuery().filter(raw: raw, [message]).all().random {
      replyMessage.add(originalContentUrl: replyImage.originalContentUrl,
                       previewImageUrl: replyImage.previewImageUrl)
    }
  }
  
  func send() {
    replyMessage.send()
  }
  
  func json() throws -> JSON {
    return try JSON(replyMessage.body.makeNode(in: nil))
  }
}
