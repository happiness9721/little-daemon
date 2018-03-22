import App
import LineBot

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands,
/// if no command is given, it will default to "serve"
let config = try Config()
try config.setup()

let drop = try Droplet(config)
try drop.setup()
drop.database?.log = { query in
  print(query)
}

let accessToken = config["linebot", "accessToken"]?.string ?? "*"
let channelSecret = config["linebot", "channelSecret"]?.string ?? "*"
let userID = config["linebot", "userID"]?.string ?? "*"
let bot = LineBot(accessToken: accessToken, channelSecret: channelSecret)
bot.push(userId: userID, messages: [.text(text: "更新完成囉😈")])

try drop.run()
