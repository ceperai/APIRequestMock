//
//  APIRequestMock.swift
//  APIRequestMock
//
//  Created by Sergey Pestov on 10/01/2018.
//  Copyright © 2018 assignment. All rights reserved.
//
//	Основные источники знаний:
//	https://yahooeng.tumblr.com/post/141143817861/using-nsurlprotocol-for-testing
//	https://github.com/ksteigerwald/MockAlamofire/blob/master/MockAlamofire/MockingProtocol.swift
//	https://github.com/Alamofire/Alamofire/blob/master/Tests/URLProtocolTests.swift
//

import Foundation

public final class APIRequestMockURLProtocol: URLProtocol {
	
	public override class func canInit( with request: URLRequest ) -> Bool {
		if let url = request.url {
			return items.contains { $0.isMatch(to: url) }
		}
		return false
	}
	
	public override class func canonicalRequest( for request: URLRequest ) -> URLRequest {
		return request
	}
	
	public override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest ) -> Bool {
		return false
	}
	
	public override func startLoading() {
		
		defer {
			client?.urlProtocolDidFinishLoading( self )
		}
		
		guard
			let url = request.url,
			let item = items.first(where: { $0.isEnabled && $0.isMatch(to: url) }),
			let response = HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: "HTTP/1.1",
				headerFields: nil
			) else {
				return
		}
		
		
		client?.urlProtocol( self, didReceive: response, cacheStoragePolicy: .notAllowed )
		client?.urlProtocol( self, didLoad: item.value )
	}
	
	public override func stopLoading() {
		// empty
	}
}

/// APIRequestMock namespace.
public enum APIRequestMock {
	
    /// Add mocks for URLSession configuration.
    /// - parameter resoureNames: Array of json files to be load from Bundle.
    /// - parameter configuration: Configuration where mockup will be inserted.
    public static func register( resourceNames: [ String ], in configuration: URLSessionConfiguration ) {
        var protocolClasses = configuration.protocolClasses ?? []
        loadItems( resourceNames: resourceNames )
        protocolClasses.insert(APIRequestMockURLProtocol.self, at: 0)
        configuration.protocolClasses = protocolClasses
    }
    
    private static func loadItems( resourceNames: [ String ] ) {
        guard items.isEmpty else { return }
		items = resourceNames
			.compactMap { self.loadItem(named: $0) }
			.flatMap { $0 }
	}
	
    /// Load mock items from separate resource file.
	public static func loadItem( named resourceName: String, extension ext: String = "json" ) -> [ APIRequestMockItem ]? {
		let bundle = Foundation.Bundle.main
		let url = bundle.url( forResource: resourceName, withExtension: ext )!
		
		do {
			let data = try Data( contentsOf: url )
			let item = try APIRequestMockItem.decode( from: data )
            print("✅ Load item with url \(url.absoluteString)")
            return item
		} catch let error as NSError {
			print("🤬🤬🤬 Load mock error \( error.localizedDescription )")
			return nil
		}
	}
}

private var items: [ APIRequestMockItem ] = []
