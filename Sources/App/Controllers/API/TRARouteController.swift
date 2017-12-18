//
//  TRARouteController.swift
//  little-daemonPackageDescription
//
//  Created by 江承諭 on 2017/10/21.
//

import Foundation
import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class TRARouteController: ResourceRepresentable {
  /// GET /api/TRARoute
  func index(_ req: Request) throws -> ResponseRepresentable {
    guard let fromStation = req.query?["fromStation"]?.string else {
      return Response(status: .badRequest, body: "fromStation is required")
    }
    guard let toStation = req.query?["toStation"]?.string else {
      return Response(status: .badRequest, body: "toStation is required")
    }
    guard let searchDate = req.query?["searchDate"]?.string else {
      return Response(status: .badRequest, body: "searchDate is required")
    }
    guard let fromTime = req.query?["fromTime"]?.string else {
      return Response(status: .badRequest, body: "fromTime is required")
    }
    guard let toTime = req.query?["toTime"]?.string else {
      return Response(status: .badRequest, body: "toTime is required")
    }
    let routes = try TRARoute.twtrafficAPI(fromStation: fromStation,
                                           toStation: toStation,
                                           searchDate: searchDate,
                                           fromTime: fromTime,
                                           toTime: toTime)
    let encoder = JSONEncoder()
    let data = try encoder.encode(routes)
    let response = try Response(status: .ok, json: JSON(bytes: data.makeBytes()))
    return response
  }

  /// When making a controller, it is pretty flexible in that it
  /// only expects closures, this is useful for advanced scenarios, but
  /// most of the time, it should look almost identical to this
  /// implementation
  func makeResource() -> Resource<ReplyText> {
    return Resource(
      index: index
    )
  }
}

