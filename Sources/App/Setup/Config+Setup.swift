import AuthProvider
import Flash
import FluentProvider
import LeafProvider
import MarkdownProvider
import MongoProvider
import Paginator
import RedisProvider

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
		try addProvider(AuthProvider.Provider.self)
		try addProvider(FluentProvider.Provider.self)
		try addProvider(LeafProvider.Provider.self)
		try addProvider(MarkdownProvider.Provider.self)
		try addProvider(MongoProvider.Provider.self)
		try addProvider(RedisProvider.Provider.self)

		try addProvider(PaginatorProvider.self)

		addConfigurable(middleware: FlashMiddleware(), name: "flash")
		addConfigurable(middleware: PersistMiddleware<User>(), name: "persist-user")
	}

	/// Add all models that should have their
	/// schemas prepared before the app boots
	private func setupPreparations() throws {
		preparations.append(Role.self)
		preparations.append(User.self)
		preparations.append(Token.self)
		preparations.append(Post.self)
		preparations.append(Comment.self)

		preparations.append(Seed.self)
	}
}
