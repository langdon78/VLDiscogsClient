//
//  Untitled.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 3/7/26.
//

import Foundation

extension Data {
    func parseJSON<T: Decodable>() throws -> T {
        let decoder: JSONDecoder = JSONDecoder()
        return try decoder.decode(T.self, from: self)
    }
}
