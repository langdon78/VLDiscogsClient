//
//  Cache.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/3/25.
//

import Foundation

protocol Cache<Object>: Actor {
    associatedtype Object
    var cached: Bool { get }
    func get() async throws -> Object
    func clear()
}
