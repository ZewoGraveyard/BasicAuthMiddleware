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

import Base64
import Data
import HTTP
import String

public struct BasicAuthenticationMiddleware: MiddlewareType {
	let authenticate: (username: String, password: String) throws -> (key: String, value: Any)?

	public init(authenticate: (username: String, password: String) throws -> (key: String, value: Any)?) {
		self.authenticate = authenticate
	}
	
	public func respond(request: Request, chain: ChainType) throws -> Response {

		if let authorization = request.headers["authorization"] {
			let tokens = authorization.split(" ")
			
			if tokens.count == 2 && tokens[0] == "Basic" {
				
				let decodedData: Data = try Base64.decode(tokens[1])
				let decodedCredentials: String = try String(data: decodedData)
				let credentials = decodedCredentials.split(":")
				
				if credentials.count == 2 {
					
					let username = credentials[0]
					let password = credentials[1]

					guard let (key, value) = try authenticate(username: username, password: password) else {
						return Response(status: .Unauthorized)
					}
					
					var _request = request
					_request.storage[key] = value
					return try chain.proceed(_request)
				}
			}
		}

		return Response(status: .Unauthorized)
	}
}
