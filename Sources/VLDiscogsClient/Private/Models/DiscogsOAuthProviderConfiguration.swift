//
//  DiscogsOAuthProviderConfiguration.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/24/25.
//

import VLOAuthFlowCoordinator

struct DiscogsOAuthProvider: OAuthProviderConfiguration {
    var apiHost = "https://api.discogs.com"
    var requestTokenPath = "oauth/request_token"
    var accessTokenPath = "oauth/access_token"
    var authorizationUrl = "https://discogs.com/oauth/authorize"
}
