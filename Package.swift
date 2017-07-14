import PackageDescription

let package = Package(
	name: "iWeb",
	targets: [
		Target(name: "App"),
		Target(name: "Run", dependencies: ["App"]),
	],
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
		.Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 2),
		.Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor-community/markdown-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/nodes-vapor/paginator.git", majorVersion: 1)
	],
	exclude: [
		"Config",
		"Database",
		"Localization",
		"Public",
		"Resources",
	]
)
