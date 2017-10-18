import FluentProvider
import Foundation

final class TRAStation: Model {
  var name: String
  let storage = Storage()
  
  init(row: Row) throws {
    name = try row.get("name")
  }
  
  init(id: String, name: String) {
    self.name = name
    self.id = Identifier(id)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("id", id)
    try row.set("name", name)
    return row
  }
}

extension TRAStation: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { replyText in
      replyText.id()
      replyText.string("name")
    }
    
    let url = "http://ptx.transportdata.tw/MOTC/v2/Rail/TRA/Station?$format=JSON"
    let json = try JSON(bytes: Data(contentsOf: URL(string: url)!).makeBytes())
    if let stations = json.array {
      for station in stations {
        if let stationID = station.object?["StationID"]?.string,
          let name = station.object?["StationName"]?.object?["Zh_tw"]?.string {
          let newStation = TRAStation(id: stationID, name: name)
          try newStation.save()
        }
      }
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
