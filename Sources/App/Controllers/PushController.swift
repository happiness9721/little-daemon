import Vapor
import HTTP
import LineBot

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class PushController: ResourceRepresentable {
  private let bot: LineBot

  init(_ config: Config) {
    let accessToken = config["linebot", "accessToken"]?.string ?? "*"
    let channelSecret = config["linebot", "channelSecret"]?.string ?? "*"
    bot = LineBot(accessToken: accessToken, channelSecret: channelSecret)
  }

  /// POST /push
  func store(_ request: Request) throws -> ResponseRepresentable {
    guard let pushTo = request.formData?["to"]?.string else {
      return Response(status: .forbidden)
    }
    bot.push(userId: pushTo, messages: [.text(text: "推播測試")])
    return Response(status: .ok)
  }

  /// When making a controller, it is pretty flexible in that it
  /// only expects closures, this is useful for advanced scenarios, but
  /// most of the time, it should look almost identical to this
  /// implementation
  func makeResource() -> Resource<ReplyText> {
    return Resource(
      store: store
    )
  }
}


