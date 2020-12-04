//
//  FormInput.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 11. 17..
//

/// used to validate form token (nonce) values
struct FormInput: Decodable {

    /// identifier of the form
    let formId: String
    /// associated token for the form
    let formToken: String
}
