@_exported import Vapor
import LineBot

extension Droplet {
  public func setup() throws {
    try setupRoutes()
  }
}

