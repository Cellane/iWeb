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
			adminOrEditorAuthorized.get("new", handler: showNewPost)
			adminOrEditorAuthorized.post("new", handler: createPost)
			adminOrEditorAuthorized.get(Post.parameter, "edit", handler: showEditPost)
			adminOrEditorAuthorized.post(Post.parameter, "edit", handler: editPost)
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

		func showNewPost(req: Request) throws -> ResponseRepresentable {
			return try droplet.view.makeDefault("admin/posts/edit", for: req)
		}

		func createPost(req: Request) throws -> ResponseRepresentable {
			do {
				let post = try req.post()

				try post.save()

				return Response(redirect: "/admin/posts")
					.flash(.success, "Post created.")
			} catch {
				return Response(redirect: "/admin/posts")
					.flash(.error, "Unexpected error occurred.")
			}
		}

		func showEditPost(req: Request) throws -> ResponseRepresentable {
			let post = try req.parameters.next(Post.self)

			return try droplet.view.makeDefault("admin/posts/edit", for: req, [
				"post": post
			])
		}

		func editPost(req: Request) throws -> ResponseRepresentable {
			do {
				let post = try req.parameters.next(Post.self)

				try post.update(for: req)
				try post.save()

				return Response(redirect: "/admin/posts")
					.flash(.success, "Post edited.")
			} catch {
				return Response(redirect: "/admin/posts")
					.flash(.error, "Unexpected error occurred.")
			}
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
