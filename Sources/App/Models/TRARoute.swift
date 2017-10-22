//
//  TRARoute.swift
//  little-daemonPackageDescription
//
//  Created by 江承諭 on 2017/10/18.
//

import Foundation
import LineBot

class TRARoute: Codable {
  let trainClassName: String
  let trainNo: String
  let departureTime: String
  let arrivalTimeTime: String
  let duration: String
  let delayInfo: String

  init(trainClassName: String,
       trainNo: String,
       departureTime: String,
       arrivalTimeTime: String,
       duration: String,
       delayInfo: String) {
    self.trainClassName = trainClassName
    self.trainNo = trainNo
    self.departureTime = departureTime
    self.arrivalTimeTime = arrivalTimeTime
    self.duration = duration
    self.delayInfo = delayInfo
  }

  static func queryTRARoute(message: String, lineBot: LineBot) throws {
    let message = message.replacingOccurrences(of: "台", with: "臺")

    // 如果一開始的字沒有包含車站名稱就跳離
    guard let fromStation = try TRAStation.makeQuery()
      .filter(raw: "$1 LIKE name || '%'", [message])
      .sort(raw: "length(name) DESC")
      .first() else {
        return
    }

    let firstIndex = message.index(message.startIndex, offsetBy: fromStation.name.characters.count)
    let truncated = message.substring(from: firstIndex)

    // 去掉開頭車站名後如果沒有車站名稱就跳離
    guard let toStation = try TRAStation.makeQuery()
      .filter(raw: "$1 LIKE '%' || name || '%'", [truncated])
      .sort(raw: "length(name) DESC")
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

    let routes = try twtrafficAPI(fromStation: fromStation.name,
                                  toStation: toStation.name,
                                  searchDate: dateString,
                                  fromTime: fromTime,
                                  toTime: Int(fromTime)! >= 2100 ? String(Int(toTime)! + 2400) : toTime)
    if routes.count > 0 {
      lineBot.add(message: "搜尋臺鐵班表 - [\(fromStation.name)] >>> [\(toStation.name)]")
      var railwayInfo = String()
      for route in routes {
        if railwayInfo.characters.count > 0 {
          railwayInfo += "\n"
        }
        railwayInfo += route.duration
        railwayInfo += " \(route.departureTime)-\(route.arrivalTimeTime)"
        railwayInfo += " \(route.trainClassName.leftPadding(toLength: 3, withPad: "　"))"
        railwayInfo += "(\(route.trainNo))"
        if route.delayInfo.characters.count > 0 {
          railwayInfo += route.delayInfo == "0" ? " 準點" : " 晚\(route.delayInfo)分"
        }
      }
      lineBot.add(message: railwayInfo)
    } else {
      lineBot.add(message: "三小時內尚無班次。")
    }
  }

  static func twtrafficAPI(fromStation: String,
                           toStation: String,
                           searchDate: String,
                           fromTime: String,
                           toTime: String) throws -> [TRARoute] {
    var routes = [TRARoute]()
    var url = "http://twtraffic.tra.gov.tw/twrail/mobile//TimeTableSearchResult.aspx"
    url += "?searchtype=1"
    url += "&searchdate=\(searchDate)"
    url += "&trainclass=2"
    url += "&fromtime=\(fromTime)"
    url += "&totime=\(toTime)"
    url += "&searchtext=\(fromStation.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
    url += ",\(toStation.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"

    let myHTMLString = try String(bytes: Data(contentsOf: URL(string: url)!).makeBytes())
    let componets = myHTMLString.components(separatedBy: "TRSearchResult.push('")
    guard componets.count > 1 else {
      return routes
    }
    var route = [String]()
    var routeIndex = 0
    for index in 1...componets.count - 1 {
      let splitString = componets[index].components(separatedBy: "')")[0]
      route.append(splitString)
      routeIndex += 1
      if routeIndex == 8 {
        let newRoute = TRARoute(trainClassName: route[0],
                                trainNo: route[1],
                                departureTime: route[2],
                                arrivalTimeTime: route[3],
                                duration: route[4],
                                delayInfo: route[7])
        routes.append(newRoute)
        route.removeAll()
        routeIndex = 0
      }
    }
    return routes
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

