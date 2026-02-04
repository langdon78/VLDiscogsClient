//
//  OAuthDeepLinkCallbackUrl.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/11/25.
//

import Foundation

public struct OAuthDeepLinkCallbackUrl {
    let scheme: String
    let host: String
    let path: String?
    
    public init(scheme: String, host: String, path: String? = nil) {
        self.scheme = scheme
        self.host = host
        self.path = path
    }
    
    public var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let path {
            components.path = path
        }
        guard let url = components.url else {
            fatalError("Unable to construct URL from scheme: \(scheme) host: \(host) path: \(path ?? "")")
        }
        return url
    }
}
