@_exported import Vapor

extension Droplet {
  public func setup() throws {
    let routes = Routes(view)
    try collection(routes)
    // Do any additional droplet setup
    LineAPIConfig.configure(with: config)
  }
}
