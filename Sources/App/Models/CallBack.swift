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
    
    try queryTRARoute()
    
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
  
  private func queryTRARoute() throws {
    let message = self.message.replacingOccurrences(of: "台", with: "臺")
    
    // 如果一開始的字沒有包含車站名稱就跳離
    guard let fromStation = try TRAStation.makeQuery()
                                          .filter(raw: "$1 LIKE name || '%'", [message])
                                          .first() else {
      return
    }
    
    let firstIndex = message.index(message.startIndex, offsetBy: fromStation.name.characters.count)
    let truncated = message.substring(from: firstIndex)
    
    // 去掉開頭車站名後如果沒有車站名稱就跳離
    guard let toStation = try TRAStation.makeQuery()
                                        .filter(raw: "$1 LIKE '%' || name || '%'", [truncated])
                                        .first() else {
      return
    }
    
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600 * 8)
    dateFormatter.dateFormat = "yyyy/MM/dd"
    let dateString = dateFormatter.string(from: now)
    dateFormatter.dateFormat = "HHmm"
    let fromTime = dateFormatter.string(from: now)
    let toTime = dateFormatter.string(from: now.addingTimeInterval(3600 * 3))
    
    var url = "http://www.madashit.com/api/get-Tw-Railway?date=\(dateString)"
    url += "&fromstation=\(fromStation.id?.string ?? "")"
    url += "&tostation=\(toStation.id?.string ?? "")"
    url += "&fromtime=\(fromTime)&totime=\(toTime)"
    
    guard let railwaies = try JSON(bytes: Data(contentsOf: URL(string: url)!).makeBytes()).array else {
      return
    }
    
    lineBot.add(message: "搜尋臺鐵班表 - [\(fromStation.name)] >>> [\(toStation.name)]")
    if railwaies.count > 0 {
      var railwayInfo = String()
      for railway in railwaies {
        if railwayInfo.characters.count > 0 {
          railwayInfo += "\n"
        }
        railwayInfo += (railway.object?["行駛時間"]?.string ?? "")
        railwayInfo += " \(railway.object?["開車時間"]?.string ?? "")"
        railwayInfo += "-\(railway.object?["到達時間"]?.string ?? "")"
        railwayInfo += " \((railway.object?["車種"]?.string ?? "").leftPadding(toLength: 3, withPad: "　"))"
        railwayInfo += "(\(railway.object?["經由"]?.string ?? ""))"
      }
      lineBot.add(message: railwayInfo)
    } else {
      lineBot.add(message: "三小時內尚無班次。")
    }
  }
}

extension String {
  func leftPadding(toLength: Int, withPad character: Character) -> String {
    let newLength = self.characters.count
    if newLength < toLength {
      return String(repeatElement(character, count: toLength - newLength)) + self
    } else {
      return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
    }
  }
}
