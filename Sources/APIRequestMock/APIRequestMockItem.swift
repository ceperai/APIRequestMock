//
//  APIRequestMockItem.swift
//  RestAPIMock
//
//  Created by Sergey Pestov on 10/01/2018.
//  Copyright © 2018 assignment. All rights reserved.
//

import Foundation

/// Contains fields of a single request mock.
public struct APIRequestMockItem {
    /// Array of url-s to be intercepted by this mock item.
    public let uri: [ String ]
    /// Developer commentaries about this mock.
	public let comment: String?
    /// Is this mock item enabled for use.
    public let isEnabled: Bool
    /// Mock data which will be returned in url response.
    public let value: Data
    /// Response headers.
    public let responseHeaders: [String: String]?
}

extension APIRequestMockItem {
	private enum CodingKeys: String, CodingKey {
		case uri
        case comment
        case value
        case enabled
        case headers
	}
	
	public init?( from data: Data ) {
		let json = try? JSONSerialization.jsonObject(with: data, options: [])
		guard let items = json as? [String: Any] else { return nil }
		
		self.init( from: items )
	}

	public init?( from json: [String: Any]) {
		if let uri = json[ CodingKeys.uri.stringValue ] as? String {
			self.uri = [ uri ]
		} else if let uri = json[ CodingKeys.uri.stringValue ] as? [ String ] {
			self.uri = uri
		} else {
			return nil
		}

		self.comment = json[ CodingKeys.comment.stringValue ] as? String

		guard let nestedJSON = json[ CodingKeys.value.stringValue ],
			let data = try? JSONSerialization.data(withJSONObject: nestedJSON, options: []) else {
				return nil
		}
   
		self.value = data
		self.isEnabled = json[ CodingKeys.enabled.stringValue ] as? Bool ?? true
        self.responseHeaders = json[ CodingKeys.headers.stringValue ] as? [String: String]
	}
	
	/// Retrieve array of mocked responses from data.
	public static func decode( from data: Data ) throws -> [ APIRequestMockItem ] {

		let json = try JSONSerialization.jsonObject(with: data, options: [])
		
		guard let result = (json as? [ [String: Any] ])?.compactMap({ APIRequestMockItem( from: $0 ) }) else {
            throw NSError(domain: "APIRequestMock", code: 0, userInfo: nil )
		}

		return result
	}
}

extension APIRequestMockItem {

	/// Возвращает `true` если урла совпадает с одной из урл в шаблонах.
	public func isMatch( to uri: URL ) -> Bool {
		return self.uri.contains { return isMatch( $0, to: uri ) }
	}

	/// Возвращает `true` если урл запроса совпадает с одной из урл в шаблонах.
	public func isMatch( to request: URLRequest ) -> Bool {
		if let url = request.url {
			return isMatch( to: url )
		}
		return false
	}

	private func isMatch( _ scheme: String, to uri: URL ) -> Bool {
		guard scheme.contains("*") else { return scheme == uri.absoluteString }

		let mask = "\\Q" + scheme.replacingOccurrences(of: "*", with: "\\E.*?\\Q") + "\\E"

		return uri.absoluteString.range(
			of: mask,
			options: .regularExpression,
			range: nil,
			locale: nil ) != nil
	}
}
