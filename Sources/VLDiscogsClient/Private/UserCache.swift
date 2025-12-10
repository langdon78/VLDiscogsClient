//
//  UserCache.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/2/25.
//

import Foundation

actor UserCache: Cache {
    
    private static let userKey = "com.vldiscogs.cached_user"
    private let userIdentityProvider: () async throws -> UserIdentity
    
    private var cachedUser: UserIdentity? {
        get {
            guard
                let cached = UserDefaults.standard.data(forKey: Self.userKey)
            else {
                return nil
            }
            do {
                let user = try JSONDecoder().decode(UserIdentity.self, from: cached)
                return user
            } catch {
                DiscogsLogger.default.log(error.localizedDescription)
                return nil
            }
        }
        set {
            do {
                let encodedData = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encodedData, forKey: Self.userKey)
            } catch {
                DiscogsLogger.default.log(error.localizedDescription)
            }
        }
    }
    
    var cached: Bool {
        cachedUser != nil
    }
    
    init(userIdentityProvider: @escaping () async throws -> UserIdentity) {
        self.userIdentityProvider = userIdentityProvider
    }
    
    func get() async throws -> UserIdentity {
        if let user = cachedUser {
            return user
        }
        let user = try await userIdentityProvider()
        cachedUser = user
        return user
    }
    
    func clear() {
        if let user = cachedUser {
            UserDefaults.standard.removeObject(forKey: Self.userKey)
            DiscogsLogger.default.debug("\(user.username) removed from cache")
        }
    }
}
