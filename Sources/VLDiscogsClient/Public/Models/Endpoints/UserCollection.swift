//
//  UserCollection.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/6/25.
//

import Foundation

extension Endpoints {
    
    enum UserCollection {
        case collection(username: String)
        case collectionFolder(username: String, folderId: Int)
        case collectionItemsByRelease(username: String, releaseId: Int)
        
        static let resourceDescription = "User Collection"
    }
}
extension Endpoints.UserCollection: CustomStringConvertible {
    var description: String {
        switch self {
        case .collection:
            "Collection"
        case .collectionFolder:
            "Collection Folder"
        case .collectionItemsByRelease:
            "Collection Items By Release"
        }
    }
}

extension Endpoints.UserCollection {
    typealias Ref = Endpoints.Reference
    
    var pathTemplate: String {
        switch self {
        case .collection:
            "/users/\(Ref.username)/collection/folders"
        case .collectionFolder:
            "/users/\(Ref.username)/collection/folders/\(Ref.folderId)"
        case .collectionItemsByRelease:
            "/users/\(Ref.username)/collection/releases/{release_id}"
        }
    }
}
