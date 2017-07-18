import Vapor
import AuthProvider

extension Controllers.API {
	final class RoleController {
		private let droplet: Droplet

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let role = droplet.grouped(["api", "role"])
			let adminAuthorized = role.grouped(TokenRolesMiddleware(User.self, roles: [Role.admin]))

			role.get("", handler: index)
			role.post("", handler: store)
		}

		func index(req: Request) throws -> ResponseRepresentable {
			return try Role.all().makeJSON()
		}

		func store(req: Request) throws -> ResponseRepresentable {
			let role = try req.role()

			try role.save()

			return role
		}
	}
}
