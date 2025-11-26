//
//  Logger.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import VLNetworkingClient

final class DiscogsLogger: Logger {}

extension DiscogsLogger {
    static let `default`: Logger = DefaultLogger()
}
