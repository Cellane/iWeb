import Node

final class UserContext: Context {
}

extension Context {
	var isUserContext: Bool {
		return self is UserContext
	}
}
