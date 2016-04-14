// BasicAuthMiddleware.swift
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
    case accessDenied
    case authenticated
    case payload(key: String, value: Any)
}

enum AuthenticationType {
    case server(realm: String?, authenticate: (username: String, password: String) throws -> AuthenticationResult)
    case client(username: String, password: String)
}

public struct BasicAuthMiddleware: Middleware {
    let type: AuthenticationType

    public init(realm: String? = nil, authenticate: (username: String, password: String) throws -> AuthenticationResult) {
        self.type = .server(realm: realm, authenticate: authenticate)
    }

    public init(username: String, password: String) {
        self.type = .client(username: username, password: password)
    }

    public func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        switch type {
        case .server(let realm, let authenticate):
            return try serverRespond(request, chain: chain, realm: realm, authenticate: authenticate)
        case .client(let username, let password):
            return try clientRespond(request, chain: chain, username: username, password: password)
        }
    }

    public func serverRespond(_ request: Request, chain: Responder, realm: String? = nil, authenticate: (username: String, password: String) throws -> AuthenticationResult) throws -> Response {
        var deniedResponse : Response
        if let realm = realm {
            deniedResponse = Response(status: .unauthorized, headers: ["WWW-Authenticate": ["Basic realm=\"\(realm)\""]])
        } else {
            deniedResponse = Response(status: .unauthorized)
        }
        
        guard let authorization = request.authorization else {
            return deniedResponse
        }

        let tokens = authorization.split(separator: " ")

        if tokens.count != 2 || tokens[0] != "Basic" {
            return deniedResponse
        }

        let decodedData = try Base64.decode(tokens[1])
        let decodedCredentials = try String(data: decodedData)
        let credentials = decodedCredentials.split(separator: ":")

        if credentials.count != 2 {
            return deniedResponse
        }

        let username = credentials[0]
        let password = credentials[1]

        switch try authenticate(username: username, password: password) {
        case .accessDenied:
            return deniedResponse
        case .authenticated:
            return try chain.respond(to: request)
        case .payload(let key, let value):
            var request = request
            request.storage[key] = value
            return try chain.respond(to: request)
        }
    }

    public func clientRespond(_ request: Request, chain: Responder, username: String, password: String) throws -> Response {
        var request = request
        let credentials = try Base64.encode("\(username):\(password)")
        request.authorization = "Basic \(credentials))"
        return try chain.respond(to: request)
    }
}
