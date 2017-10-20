import FluentProvider

final class ReplyText: Model {
  var keyword: String
  var text: String
  let storage = Storage()

  init(row: Row) throws {
    keyword = try row.get("keyword")
    text = try row.get("text")
  }

  init(keyword: String, text: String) {
    self.keyword = keyword
    self.text = text
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set("id", id)
    try row.set("keyword", keyword)
    try row.set("text", text)
    return row
  }
}

extension ReplyText: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { replyText in
      replyText.id()
      replyText.string("keyword")
      replyText.string("text")
    }
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension ReplyText: JSONConvertible {
  convenience init(json: JSON) throws {
    try self.init(keyword: json.get("keyword"), text: json.get("text"))
  }

  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set("id", id)
    try json.set("keyword", keyword)
    try json.set("text", text)
    return json
  }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension ReplyText: ResponseRepresentable { }

extension ReplyText: NodeConvertible {
  convenience init(node: Node) throws {
    try self.init(keyword: node.get("keyword"), text: node.get("text"))
  }

  func makeNode(in context: Context?) throws -> Node {
    var node = Node(context)
    try node.set("id", id)
    try node.set("keyword", keyword)
    try node.set("text", text)
    return node
  }
}

