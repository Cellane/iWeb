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

			adminAuthorized.get("", handler: index)
			adminAuthorized.post("", handler: store)
			adminAuthorized.delete(Role.parameter, handler: delete)
		}

		func index(req: Request) throws -> ResponseRepresentable {
			return try Role.all().makeJSON()
		}

		func store(req: Request) throws -> ResponseRepresentable {
			let role = try req.role()

			try role.save()

			return role
		}

		func delete(req: Request) throws -> ResponseRepresentable {
			let role = try req.parameters.next(Role.self)

			try role.delete()

			return Response(status: .ok)
		}
	}
}
