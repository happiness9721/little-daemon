@_exported import Vapor
import LineBot

extension Droplet {
  public func setup() throws {
    try setupRoutes()

    let accessToken = config["linebot", "accessToken"]?.string ?? "*"
    let channelSecret = config["linebot", "channelSecret"]?.string ?? "*"
    LineBot.configure(accessToken: accessToken, channelSecret: channelSecret)
  }
}

