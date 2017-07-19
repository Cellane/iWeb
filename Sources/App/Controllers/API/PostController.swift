import Vapor
import AuthProvider

extension Controllers.API {
	final class PostController {
		private let droplet: Droplet

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let post = droplet.grouped(["api", "post"])
			let adminOrEditorAuthenticated = post.grouped(TokenRolesMiddleware(User.self, roles: [Role.admin, Role.editor]))

			post.get(handler: index)
			post.get(Post.parameter, handler: show)
			adminOrEditorAuthenticated.post(handler: store)
		}

		func index(req: Request) throws -> ResponseRepresentable {
			return try Post.all().makeJSON()
		}

		func store(req: Request) throws -> ResponseRepresentable {
			let post = try req.post()

			try post.save()

			return post
		}

		func show(req: Request) throws -> ResponseRepresentable {
			let post = try req.parameters.next(Post.self)

			return post
		}
	}
}
