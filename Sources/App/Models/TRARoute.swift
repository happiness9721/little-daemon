//
//  TRARoute.swift
//  little-daemonPackageDescription
//
//  Created by 江承諭 on 2017/10/18.
//

import Foundation
import LineBot

class TRARoute {
  static func queryTRARoute(message: String, lineBot: LineBot) throws {
    let message = message.replacingOccurrences(of: "台", with: "臺")

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

    try twtrafficAPI(fromStation: fromStation, toStation: toStation, lineBot: lineBot)
  }

  private static func twtrafficAPI(fromStation: TRAStation,
                                   toStation: TRAStation,
                                   lineBot: LineBot) throws {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600 * 8)
    dateFormatter.dateFormat = "yyyy/MM/dd"
    let dateString = dateFormatter.string(from: now)
    dateFormatter.dateFormat = "HHmm"
    let fromTime = dateFormatter.string(from: now)
    let toTime = dateFormatter.string(from: now.addingTimeInterval(3600 * 3))

    var url = "http://twtraffic.tra.gov.tw/twrail/mobile//TimeTableSearchResult.aspx"
      url += "?searchtype=1"
      url += "&searchdate=\(dateString)"
      url += "&trainclass=2"
      url += "&fromtime=\(fromTime)"
      url += "&totime=\(toTime)"
      url += "&searchtext=\(fromStation.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
      url += ",\(toStation.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"

    guard let myURL = URL(string: url) else {
      return
    }

    let myHTMLString = try String(contentsOf: myURL)
    let pattern = "TRSearchResult.push\\(\'([^\']*)\'\\)"
    let re = try NSRegularExpression(pattern: pattern, options: [])
    let matches = re.matches(in: myHTMLString,
                             options: [],
                             range: NSRange(location: 0, length: myHTMLString.count))

    guard matches.count > 0 else {
      lineBot.add(message: "三小時內尚無班次。")
      return
    }
    var route = [String]()
    var index = 0
    var railwayInfo = String()
    lineBot.add(message: "搜尋臺鐵班表 - [\(fromStation.name)] >>> [\(toStation.name)]")
    for match in matches as [NSTextCheckingResult] {
      // range at index 0: full match
      // range at index 1: first capture group
      let substring = NSString(string: myHTMLString).substring(with: match.range(at: 1))
      route.append(substring)
      index += 1
      if index == 8 {
        if railwayInfo.characters.count > 0 {
          railwayInfo += "\n"
        }
        railwayInfo += route[4]
        railwayInfo += " \(route[2])"
        railwayInfo += "-\(route[3])"
        railwayInfo += " \(route[0].leftPadding(toLength: 3, withPad: "　"))"
        railwayInfo += "(\(route[1]))"
        if route[6] == "Y" && route[7].count > 0 {
          railwayInfo += route[7] == "0" ? " 準點" : " 晚\(route[7])分"
        }
        print(route)
        route.removeAll()
        index = 0
      }
    }
    lineBot.add(message: railwayInfo)
  }

  private static func madashitAPI(fromStation: TRAStation,
                                  toStation: TRAStation,
                                  lineBot: LineBot) throws {
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
