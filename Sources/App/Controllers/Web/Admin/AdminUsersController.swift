import Vapor
import Paginator

extension Controllers.Web {
	final class AdminUsersController {
		private let droplet: Droplet
		private let context = AdminContext()

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let users = droplet.grouped("admin", "users")
			let adminAuthorized = users.grouped(SessionRolesMiddleware(User.self, roles: [Role.admin]))

			adminAuthorized.get(handler: showUsers)
			adminAuthorized.post(User.parameter, "edit", handler: editUser)
			adminAuthorized.get(User.parameter, "delete", handler: deleteUser)
			adminAuthorized.get(String.parameter, "restore", handler: restoreUser)
		}

		func showUsers(req: Request) throws -> ResponseRepresentable {
			let users = try User
				.makeQuery()
				.withSoftDeleted()
				.sort(User.createdAtKey, .ascending)
				.paginator(50, request: req)

			return try droplet.view.makeDefault("admin/users/list", for: req, [
				"users": users.makeNode(in: context),
				"roles": Role.all().makeNode(in: context)
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

		func deleteUser(req: Request) throws -> ResponseRepresentable {
			do {
				let user = try req.parameters.next(User.self)

				try user.delete()

				return Response(redirect: "/admin/users")
					.flash(.success, "User deleted.")
			} catch {
				return Response(redirect: "/admin/users")
					.flash(.error, "Couldn't modify user.")
			}
		}

		func restoreUser(req: Request) throws -> ResponseRepresentable {
			do {
				let userId = try req.parameters.next(String.self)
				let user = try User.withSoftDeleted().find(userId)!

				try user.restore()

				return Response(redirect: "/admin/users")
					.flash(.success, "User restored.")
			} catch {
				return Response(redirect: "/admin/users")
					.flash(.error, "Couldn't modify user.")
			}
		}
	}
}
