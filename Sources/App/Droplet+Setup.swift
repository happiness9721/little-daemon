@_exported import Vapor
import LineAPI

extension Droplet {
  public func setup() throws {
    let routes = Routes(view, config)
    try collection(routes)
    // Do any additional droplet setup
    // Channel Access Token
    guard let accessToken = config["line_config", "access_token"]?.string else {
      fatalError("error, put line_config.json into Config/secrets and write access_token")
    }
    LineAPI.configure(with: accessToken)
  }
}
