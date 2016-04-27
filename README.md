# BasicAuthMiddleware

[![Swift][swift-badge]][swift-url]
[![Zewo][zewo-badge]][zewo-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]
[![Travis][travis-badge]][travis-url]
[![Codebeat][codebeat-badge]][codebeat-url]

**BasicAuthMiddleware** provides basic authentication for server and client.

## Usage

### Server

```swift
import BasicAuthMiddleware
import HTTPServer
import Router

let basicAuth = BasicAuthMiddleware { username, password in
	if username == "admin" && password == "password" {
		return .Authenticated
	}

	return .AccessDenied
}

let router = Router(middleware: basicAuth) { route in
	route.get("/") { _ in
		return Response(status: .OK, body: "Authenticated")
	}
}

try Server(responder: router).start()
```

If you want to pass forward any custom data in the `Request` storage, you can return a `Payload` with a key and a value.

```swift
let basicAuth = BasicAuthMiddleware { username, password in
	if let user = User.withUsername(username, password: password) {
		return .Payload(key: "user", value: user)
	}

	return .AccessDenied
}
```

Then you can retrieve the value in the route.

```swift
let router = Router(middleware: basicAuth) { route in
	route.get("/") { request in
		let user = request.storage["user"]!
		// Do what you want with the user
		return Response(status: .OK, body: "Authenticated")
	}
}
```

If you want the browser to show a login prompt after receiving `Access Denied`, you can set an optional `Basic realm` for the `WWW-Authenticate` header.

```swift
let basicAuth = BasicAuthMiddleware(realm: "Password Protected Realm") { username, password in
    if username == "admin" && password == "password" {
        return .Authenticated
    }

    return .AccessDenied
}
```

### Client

```swift
import BasicAuthMiddleware
import HTTPClient

let basicAuth = BasicAuthMiddleware(
	username: "API_KEY",
	password: "API_SECRET"
)

let client = try Client(host: "your.api.com", port: 80)
let response = try client.get("/", middleware: basicAuth)
```

## Installation

- Add `BasicAuthMiddleware` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
	dependencies: [
		.Package(url: "https://github.com/Zewo/BasicAuthMiddleware.git", majorVersion: 0, minor: 5)
	]
)
```

## Support

If you need any help you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel. Or you can create a Github [issue](https://github.com/Zewo/Zewo/issues/new) in our main repository. When stating your issue be sure to add enough details, specify what module is causing the problem and reproduction steps.

## Community

[![Slack][slack-image]][slack-url]

The entire Zewo code base is licensed under MIT. By contributing to Zewo you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[zewo-badge]: https://img.shields.io/badge/Zewo-0.5-FF7565.svg?style=flat
[zewo-url]: http://zewo.io
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-badge]: https://travis-ci.org/Zewo/BasicAuthMiddleware.svg?branch=master
[travis-url]: https://travis-ci.org/Zewo/BasicAuthMiddleware
[codebeat-badge]: https://codebeat.co/badges/a8045316-e11c-4d46-adbb-c887742d6c6e
[codebeat-url]: https://codebeat.co/projects/github-com-zewo-basicauthmiddleware