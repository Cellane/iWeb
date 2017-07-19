import Vapor
import Paginator

extension Controllers.Web {
	final class AdminPostsController {
		private let droplet: Droplet
		private let context = AdminContext()

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let posts = droplet.grouped("admin", "posts")
			let adminOrEditorAuthorized = posts.grouped(SessionRolesMiddleware(User.self, roles: [Role.admin, Role.editor]))

			adminOrEditorAuthorized.get(handler: showPosts)
			adminOrEditorAuthorized.get(Post.parameter, "delete", handler: deletePost)
			adminOrEditorAuthorized.get(String.parameter, "restore", handler: restorePost)
		}

		func showPosts(req: Request) throws -> ResponseRepresentable {
			let posts = try Post
				.makeQuery()
				.withSoftDeleted()
				.sort(Post.createdAtKey, .descending)
				.paginator(50, request: req)

			return try droplet.view.makeDefault("admin/posts/list", for: req, [
				"posts": posts.makeNode(in: context)
			])
		}

		func deletePost(req: Request) throws -> ResponseRepresentable {
			do {
				let post = try req.parameters.next(Post.self)

				try post.delete()

				return Response(redirect: "/admin/posts")
					.flash(.success, "Post deleted.")
			} catch {
				return Response(redirect: "/admin/posts")
					.flash(.error, "Unexpected error occurred.")
			}
		}

		func restorePost(req: Request) throws -> ResponseRepresentable {
			do {
				let postId = try req.parameters.next(String.self)
				let post = try Post.withSoftDeleted().find(postId)!

				try post.restore()

				return Response(redirect: "/admin/posts")
					.flash(.success, "Post restored.")
			} catch {
				return Response(redirect: "/admin/posts")
					.flash(.error, "Unexpected error occurred.")
			}
		}
	}
}
