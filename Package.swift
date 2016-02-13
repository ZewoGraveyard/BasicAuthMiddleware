import PackageDescription

let package = Package(
	name: "BasicAuthMiddleware",
	dependencies: [
		.Package(url: "https://github.com/ZewoFlux/HTTP.git", majorVersion: 0, minor: 2),
		.Package(url: "https://github.com/ZewoFlux/Base64.git", majorVersion: 0, minor: 2),
		.Package(url: "https://github.com/ZewoFlux/String.git", majorVersion: 0, minor: 2)
	]
)
