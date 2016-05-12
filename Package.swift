import PackageDescription

let package = Package(
    name: "BasicAuthMiddleware",
    dependencies: [
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/Base64.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 5),
    ]
)
