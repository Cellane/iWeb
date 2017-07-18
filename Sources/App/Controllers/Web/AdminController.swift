import Vapor
import Paginator

extension Controllers.Web {
	final class AdminController {
		private let droplet: Droplet

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let admin = droplet.grouped("admin")
			let adminAuthorized = admin.grouped(SessionRolesMiddleware(User.self, roles: [Role.admin]))
			let adminOrEditorAuthorized = admin.grouped(SessionRolesMiddleware(User.self, roles: [Role.admin, Role.editor]))

			admin.get("users", handler: showUsers)
			admin.post("users", User.parameter, "edit", handler: editUser)
			adminOrEditorAuthorized.get("posts", handler: showPosts)
		}

		func showUsers(req: Request) throws -> ResponseRepresentable {
			let users = try User
				.makeQuery()
				.sort(User.createdAtKey, .ascending)
				.paginator(50, request: req)

			return try droplet.view.makeDefault("admin/users", for: req, [
				"users": users,
				"roles": Role.all().makeNode(in: nil)
			])
		}

		func editUser(req: Request) throws -> ResponseRepresentable {
			do {
				let user = try req.parameters.next(User.self)
				let roleId = req.data["roleId"]?.string
				let role = try Role.find(roleId)

				user.roleId = try role?.assertExists()

				try user.save()

				return Response(redirect: "/admin/users")
					.flash(.success, "User successfully edited.")
			} catch {
				return Response(redirect: "/admin/users")
					.flash(.error, "Unexpected error occurred.")
			}
		}

		func showPosts(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.makeDefault("admin/posts", for: req)
		}
	}
}
