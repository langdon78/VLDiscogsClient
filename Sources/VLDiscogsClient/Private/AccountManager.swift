//
//  AccountManager.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/25/25.
//

import Foundation

/// Manages multiple Discogs accounts and switching between them
@MainActor
public class AccountManager: ObservableObject {
    @Published public var accounts: [StoredAccount] = []
    @Published public var activeAccount: AccountIdentifier?
    
    private var discogsClients: [AccountIdentifier: VLDiscogsClient] = [:]
    private let callbackUrl: URL
    private let accountStore: AccountStore
    
    public init(callbackUrl: URL, accountStore: AccountStore = UserDefaultsAccountStore()) {
        self.callbackUrl = callbackUrl
        self.accountStore = accountStore
        self.accounts = accountStore.loadAccounts()
        self.activeAccount = accountStore.loadActiveAccount()
    }
    
    /// Get the currently active Discogs client, or nil if no account is active
    public var activeClient: VLDiscogsClient? {
        get async {
            guard let activeAccount else { return nil }
            return await client(for: activeAccount)
        }
    }
    
    /// Get or create a client for the specified account
    public func client(for account: AccountIdentifier) async -> VLDiscogsClient? {
        // Return existing client if already created
        if let existingClient = discogsClients[account] {
            return existingClient
        }
        
        // Create new client for this account
        do {
            let client = try await VLDiscogsClient(
                oauthCallbackUrl: callbackUrl,
                accountIdentifier: account
            )
            discogsClients[account] = client
            return client
        } catch {
            print("Failed to create client for account \(account.username): \(error)")
            return nil
        }
    }
    
    /// Add a new account (typically after successful OAuth)
    public func addAccount(_ userIdentity: UserIdentity) async throws {
        let identifier = AccountIdentifier(username: userIdentity.username)
        let storedAccount = StoredAccount(identifier: identifier, userIdentity: userIdentity)
        
        // Add to accounts if not already present
        if !accounts.contains(where: { $0.identifier == identifier }) {
            accounts.append(storedAccount)
            accountStore.saveAccounts(accounts)
        }
        
        // Set as active account
        try await switchToAccount(identifier)
    }
    
    /// Switch to a different account
    public func switchToAccount(_ identifier: AccountIdentifier) async throws {
        guard accounts.contains(where: { $0.identifier == identifier }) else {
            throw AccountManagerError.accountNotFound
        }
        
        activeAccount = identifier
        accountStore.saveActiveAccount(identifier)
        
        // Update last active timestamp
        if let index = accounts.firstIndex(where: { $0.identifier == identifier }) {
            accounts[index] = StoredAccount(
                identifier: identifier,
                userIdentity: accounts[index].userIdentity,
                lastActive: Date()
            )
            accountStore.saveAccounts(accounts)
        }
    }
    
    /// Remove an account and its associated data
    public func removeAccount(_ identifier: AccountIdentifier) async throws {
        // Log out the client if it exists
        if let client = discogsClients[identifier] {
            try await client.clearTokens()
            discogsClients.removeValue(forKey: identifier)
        }
        
        // Remove from stored accounts
        accounts.removeAll { $0.identifier == identifier }
        accountStore.saveAccounts(accounts)
        
        // Clear active account if this was it
        if activeAccount == identifier {
            activeAccount = accounts.first?.identifier
            if let newActive = activeAccount {
                accountStore.saveActiveAccount(newActive)
            } else {
                accountStore.clearActiveAccount()
            }
        }
    }
    
    /// Authenticate a new account
    public func authenticateNewAccount() async throws -> UserIdentity {
        // Create a temporary client without an account identifier
        let tempClient = try await VLDiscogsClient(oauthCallbackUrl: callbackUrl)
        // Clear any temporary access token to trigger reauthentication
        try await tempClient.clearTokens()
        // Get the user identity after OAuth completes
        let identity = try await tempClient.identity()
        
        // Add this account
        try await addAccount(identity)
        
        // Store the client under the new account
        let identifier = AccountIdentifier(username: identity.username)

        let client = try await VLDiscogsClient(
            oauthCallbackUrl: callbackUrl,
            accountIdentifier: identifier
        )
        try await client.copyAndClearTemporaryTokens()
        discogsClients[identifier] = client
        
        return identity
    }
}

public enum AccountManagerError: Error {
    case accountNotFound
    case noActiveAccount
}

// MARK: - Account Storage Protocol

/// Protocol for persisting account data
public protocol AccountStore {
    func loadAccounts() -> [StoredAccount]
    func saveAccounts(_ accounts: [StoredAccount])
    func loadActiveAccount() -> AccountIdentifier?
    func saveActiveAccount(_ identifier: AccountIdentifier)
    func clearActiveAccount()
}

// MARK: - UserDefaults Implementation

public class UserDefaultsAccountStore: AccountStore {
    private let accountsKey = "discogs_stored_accounts"
    private let activeAccountKey = "discogs_active_account"
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func loadAccounts() -> [StoredAccount] {
        guard let data = defaults.data(forKey: accountsKey) else { return [] }
        return (try? JSONDecoder().decode([StoredAccount].self, from: data)) ?? []
    }
    
    public func saveAccounts(_ accounts: [StoredAccount]) {
        let data = try? JSONEncoder().encode(accounts)
        defaults.set(data, forKey: accountsKey)
    }
    
    public func loadActiveAccount() -> AccountIdentifier? {
        guard let data = defaults.data(forKey: activeAccountKey) else { return nil }
        return try? JSONDecoder().decode(AccountIdentifier.self, from: data)
    }
    
    public func saveActiveAccount(_ identifier: AccountIdentifier) {
        let data = try? JSONEncoder().encode(identifier)
        defaults.set(data, forKey: activeAccountKey)
    }
    
    public func clearActiveAccount() {
        defaults.removeObject(forKey: activeAccountKey)
    }
}
