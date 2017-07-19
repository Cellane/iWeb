import Node

final class AdminContext: Context {
}

extension Context {
	var isAdminContext: Bool {
		return self is AdminContext
	}
}
