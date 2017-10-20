import FluentProvider

final class MessageLog: Model {
  var sourceInfo: String
  var message: String
  let storage = Storage()

  init(row: Row) throws {
    sourceInfo = try row.get("sourceInfo")
    message = try row.get("message")
  }

  init(sourceInfo: String, message: String) {
    self.sourceInfo = sourceInfo
    self.message = message
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set("id", id)
    try row.set("sourceInfo", sourceInfo)
    try row.set("message", message)
    return row
  }
}

extension MessageLog: Timestampable { }

extension MessageLog: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { replyText in
      replyText.id()
      replyText.string("sourceInfo")
      replyText.string("message")
    }
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

