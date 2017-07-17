import Vapor
import Paginator

extension Controllers.Web {
	final class BlogController {
		private let droplet: Droplet
		private let context = BlogContext()

		init(droplet: Droplet) {
			self.droplet = droplet
		}

		func addRoutes() {
			let blog = droplet.grouped("blog")

			blog.get("", handler: showBlog)
			blog.get("", Post.parameter, handler: showBlogPost)
			blog.post("", Post.parameter, "comment", handler: submitComment)
		}

		func showBlog(req: Request) throws -> ResponseRepresentable {
			let posts = try Post
				.makeQuery()
				.sort(Post.createdAtKey, .descending)
				.paginator(5, request: req)

			return try droplet.view.makeDefault("blog/index", for: req, [
				"posts": posts.makeNode(in: context)
			])
		}

		func showBlogPost(req: Request) throws -> ResponseRepresentable {
			let post = try req.parameters.next(Post.self)

			return try droplet.view.makeDefault("blog/post", for: req, [
				"post": post.makeNode(in: context)
			])
		}

		func submitComment(req: Request) throws -> ResponseRepresentable {
			let comment = try req.comment()

			try comment.save()

			guard let postId = comment.postId?.string else {
				return Response(redirect: "/blog")
			}

			return Response(redirect: "/blog/\(postId)")
		}
	}
}
