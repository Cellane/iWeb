import Node

final class BlogContext: Context {
}

extension Context {
	var isBlogContext: Bool {
		return self is BlogContext
	}
}
