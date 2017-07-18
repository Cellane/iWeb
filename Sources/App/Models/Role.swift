import Vapor
import FluentProvider

final class Role: Model {
	let storage = Storage()
	static let editor = "editor"
	static let admin = "admin"

	var name: String

	init(name: String) {
		self.name = name
	}

	// MARK: - Row
	init(row: Row) throws {
		name = try row.get(Properties.name)
	}

	func makeRow() throws -> Row {
		var row = Row()

		try row.set(Properties.name, name)

		return row
	}
}

extension Role {
	var users: Children<Role, User> {
		return children()
	}
}

// MARK: - Preparation
extension Role: Preparation {
	struct Properties {
		static let id = "id" // swiftlint:disable:this identifier_name
		static let name = "name"
	}

	static func prepare(_ database: Database) throws {
		try database.create(self) { builder in
			builder.id()
			builder.string(Properties.name, unique: true)
		}
	}

	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

// MARK: - JSONConvertible
extension Role: JSONConvertible {
	convenience init(json: JSON) throws {
		try self.init(
			name: json.get(Properties.name)
		)
	}

	func makeJSON() throws -> JSON {
		var json = JSON()

		try json.set(Properties.id, id)
		try json.set(Properties.name, name)

		return json
	}
}

// MARK: - NodeRepresentable
extension Role: NodeRepresentable {
	func makeNode(in context: Context?) throws -> Node {
		return try Node(makeJSON())
	}
}

// MARK: - ResponseRepresentable
extension Role: ResponseRepresentable {
}

// MARK: - Request
extension Request {
	func role() throws -> Role {
		guard let json = json else {
			throw Abort(.badRequest)
		}

		let role = try Role(json: json)

		return role
	}
}
