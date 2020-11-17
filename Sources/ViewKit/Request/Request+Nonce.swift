//
//  Request+Nonce.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 11. 17..
//

import Vapor

public extension Request {

    /// returns a nonce session key for a given type and identifier
    private func getNonceSessionKey(for type: String, id: String) -> String {
        "\(type)-\(id)-nonce"
    }

    /// generates a nonce and saves it in the session storage for a given key and identifier
    func generateNonce(for type: String, id: String) -> String {
        let token = [UInt8].random(count: 32).base64
        session.data[getNonceSessionKey(for: type, id: id)] = id
        return token
    }

    /// validates a nonce, then removes a given nonce from the session storage
    func useNonce(for type: String, id: String, token: String) throws {
        let nonceSessionKey = getNonceSessionKey(for: type, id: id)
        guard let existingToken = session.data[nonceSessionKey] else {
            throw Abort(.forbidden)
        }
        session.data[nonceSessionKey] = nil
        guard existingToken == token else {
            throw Abort(.forbidden)
        }
    }
}
