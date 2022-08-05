//
//  GetNextMessagesResponse.swift
//  Owl
//
//  Created by Anastasia Holovash on 05.08.2022.
//

import Foundation
import Firebase

struct GetNextMessagesResponse: Equatable {
    let messageResponse: [MessageResponse]
    let lastDocumentSnapshot: DocumentSnapshot?
}
