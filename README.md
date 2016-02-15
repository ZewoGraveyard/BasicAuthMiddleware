
[![Header](http://s29.postimg.org/hb2rhwfw7/twitter_header.png)](http://new.zewo.io)

Basic Auth Middleware
======
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platform Linux](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

**Basic Auth Middleware** for **Swift 2.2** provides a fast way to authenticate your endpoints.

## Usage

```swift
import Base64
import String 
import Data
import HTTPServer
import Router

let basicAuth = BasicAuthMiddleware { username, password in
	guard let user = (username == "admin" && password == "password") else {
		return nil
	}
	
	return ("user", user)
}

let router = Router(middleware: basicAuth) { route in
	route.get("/") { request in
	
		return Response(status: .OK, body: "User authenticated")
	}
}

try HTTPServer(port: 8081, responder: router).start()
```

## Installation

- Add `Basic Auth Middleware` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
	dependencies: [
		.Package(url: "https://github.com/ZewoFlux/BasicAuthMiddleware.git", majorVersion: 0, minor: 0),
		.Package(url: "https://github.com/ZewoFlux/HTTPServer.git", majorVersion: 0, minor: 2),
		.Package(url: "https://github.com/ZewoFlux/Router.git", majorVersion: 0, minor: 2)
	]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**Basic Auth Middleware** is released under the MIT license. See LICENSE for details.