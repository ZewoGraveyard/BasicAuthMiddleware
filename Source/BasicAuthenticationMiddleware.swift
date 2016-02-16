// BasicAuthenticationMiddleware.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import Base64
@_exported import HTTP

public enum AuthenticationResult {
	case AccessDenied
	case Authenticated
	case Payload(key: String, value: Any)
}

enum AuthenticationType {
    case Server(authenticate: (username: String, password: String) throws -> AuthenticationResult)
    case Client(username: String, password: String)
}

public struct BasicAuthenticationMiddleware: MiddlewareType {
	let type: AuthenticationType

    public init(authenticate: (username: String, password: String) throws -> AuthenticationResult) {
        self.type = .Server(authenticate: authenticate)
    }

    public init(username: String, password: String) {
        self.type = .Client(username: username, password: password)
    }

    public func respond(request: Request, chain: ChainType) throws -> Response {
        switch type {
        case .Server(let authenticate):
            return try serverRespond(request, chain: chain, authenticate: authenticate)
        case .Client(let username, let password):
            return try clientRespond(request, chain: chain, username: username, password: password)
        }
    }

    public func serverRespond(request: Request, chain: ChainType, authenticate: (username: String, password: String) throws -> AuthenticationResult) throws -> Response {
        guard let authorization = request.authorization else {
            return Response(status: .Unauthorized)
        }

		let tokens = authorization.split(" ")

        if tokens.count != 2 || tokens[0] != "Basic" {
            return Response(status: .Unauthorized)
        }

		let decodedData = try Base64.decode(tokens[1])
		let decodedCredentials = try String(data: decodedData)
		let credentials = decodedCredentials.split(":")

        if credentials.count != 2 {
            return Response(status: .Unauthorized)
        }

		let username = credentials[0]
		let password = credentials[1]

		switch try authenticate(username: username, password: password) {
        case .AccessDenied:
			return Response(status: .Unauthorized)
        case .Authenticated:
            return try chain.proceed(request)
        case .Payload(let key, let value):
            var request = request
            request.storage[key] = value
            return try chain.proceed(request)
		}
    }

    public func clientRespond(request: Request, chain: ChainType, username: String, password: String) throws -> Response {
        return try chain.proceed(request)
    }
}
