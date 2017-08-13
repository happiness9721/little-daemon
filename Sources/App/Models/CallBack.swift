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
    
    try queryTRARoute()
    
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
  
  func queryTRARoute() throws {
    let regex = try NSRegularExpression(pattern: "^[\\u4e00-\\u9fa5]{2,4}\\s[\\u4e00-\\u9fa5]{2,4}$")
    let nsString = message as NSString
    if regex.matches(in: message, range: NSRange(location: 0, length: nsString.length)).count > 0 {
      let messageArray = message.components(separatedBy: " ")
      let fromStation = try TRAStation.makeQuery().filter("name", messageArray[0]).first()
      let toStation = try TRAStation.makeQuery().filter("name", messageArray[1]).first()
      if let fromStation = fromStation, let toStation = toStation {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600 * 8)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "HHmm"
        let fromTime = dateFormatter.string(from: now)
        let toTime = dateFormatter.string(from: now.addingTimeInterval(3600 * 7))
        
        var url = "http://www.madashit.com/api/get-Tw-Railway?date=" + dateString
        url += "&fromstation=" + (fromStation.id?.string ?? "")
        url += "&tostation=" + (toStation.id?.string ?? "")
        url += "&fromtime=" + fromTime + "&totime=" + toTime
        
        let json = try JSON(bytes: Data(contentsOf: URL(string: url)!).makeBytes())
        if let railwaies = json.array {
          var railwayInfo = String()
          for railway in railwaies {
            if railwayInfo.characters.count > 0 {
              railwayInfo += "\n"
            }
            railwayInfo += railway.object?["車種"]?.string ?? ""
            railwayInfo += " " + (railway.object?["車次"]?.int ?? 0).description
            railwayInfo += " " + (railway.object?["經由"]?.string ?? "")
            railwayInfo += " " + (railway.object?["開車時間"]?.string ?? "")
            railwayInfo += "-" + (railway.object?["到達時間"]?.string ?? "")
          }
          replyMessage.add(message: railwayInfo.characters.count == 0 ? "七小時內尚無班次" : railwayInfo)
        }
      }
    }
  }
}
