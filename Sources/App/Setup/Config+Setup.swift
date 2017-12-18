import FluentProvider
import PostgreSQLProvider
import LeafProvider
import SteamPress

extension Config {
  public func setup() throws {
    // allow fuzzy conversions for these types
    // (add your own types here)
    Node.fuzzy = [Row.self, JSON.self, Node.self]

    try setupProviders()
    try setupPreparations()
  }

  /// Configure providers
  private func setupProviders() throws {
    try addProvider(FluentProvider.Provider.self)
    try addProvider(PostgreSQLProvider.Provider.self)
    try addProvider(LeafProvider.Provider.self)
    try addProvider(SteamPress.Provider.self)
  }

  /// Add all models that should have their
  /// schemas prepared before the app boots
  private func setupPreparations() throws {
    preparations.append(ReplyText.self)
    preparations.append(ReplyImage.self)
    preparations.append(MessageLog.self)
    preparations.append(TRAStation.self)
  }
}

