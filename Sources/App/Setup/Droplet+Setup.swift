@_exported import Vapor
import LineBot

extension Droplet {
  public func setup() throws {
    try setupRoutes()
    // Do any additional droplet setup
    // Channel Access Token
    guard let accessToken = config["line_config", "access_token"]?.string else {
      fatalError("error, put line_config.json into Config/secrets and write access_token")
    }
    LineBot.configure(with: accessToken)
  }
}

