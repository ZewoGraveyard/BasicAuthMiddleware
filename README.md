BasicAuthMiddleware
=============================

[![Zewo 0.3](https://img.shields.io/badge/Zewo-0.3-FF7565.svg?style=flat)](http://zewo.io)
[![Swift 3](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org)
[![Platform Linux](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

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
		.Package(url: "https://github.com/Zewo/BasicAuthMiddleware.git", majorVersion: 0, minor: 4)
	]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**BasicAuthMiddleware** is released under the MIT license. See LICENSE for details.
