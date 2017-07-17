import Vapor
import Flash

extension ViewRenderer {
	public func makeDefault(_ path: String, for request: Request, _ data: NodeRepresentable? = nil,
	                        from provider: Provider.Type? = nil) throws -> View {
		var node = try data?.makeNode(in: nil) ?? Node(nil)

		try node.set("flash", request.storage[Helper.flashKey])
		try node.set("me", User.fetchPersisted(for: request).makeNode(in: nil))

		let viewData = try node.converted(to: ViewData.self, in: ViewData.defaultContext)
		let viewsDir = provider?.viewsDir ?? ""

		return try make(viewsDir + path, viewData)
	}
}
