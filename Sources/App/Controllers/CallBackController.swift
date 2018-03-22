import Vapor
import HTTP
import LineBot

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class CallBackController: ResourceRepresentable {
  private let bot: LineBot

  init(_ config: Config) {
    let accessToken = config["linebot", "accessToken"]?.string ?? "*"
    let channelSecret = config["linebot", "channelSecret"]?.string ?? "*"
    bot = LineBot(accessToken: accessToken, channelSecret: channelSecret)
  }
  
  /// POST /callback
  func store(_ request: Request) throws -> ResponseRepresentable {
    guard let content = request.body.bytes?.makeString() else {
      return Response(status: .forbidden)
    }

    guard let signature = request.headers["X-Line-Signature"] else {
      return Response(status: .forbidden)
    }

    guard !bot.validateSignature(content: content, signature: signature) else {
      return Response(status: .forbidden)
    }

    guard let events = bot.parseEventsFrom(requestBody: content) else {
      return Response(status: .forbidden)
    }

    for event in events {
      switch event {
      case .message(let message):
        let replyToken = message.replyToken
        switch message.message {
        case .text(let text):
          guard let messages = try? CallBack.reply(message: text.text, source: message.source), messages.count > 0 else {
            break
          }
          bot.reply(token: replyToken, messages: messages)
        case _:
          break
        }
      case _:
        break
      }
    }
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

