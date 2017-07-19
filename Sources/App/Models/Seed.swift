import Vapor
import FluentProvider

struct Seed: Preparation {
	static func prepare(_ database: Database) throws {
		if try Role.count() == 0 {
			try Role(name: Role.admin).save()
			try Role(name: Role.editor).save()
		}
	}

	static func revert(_ database: Database) throws {
	}
}
