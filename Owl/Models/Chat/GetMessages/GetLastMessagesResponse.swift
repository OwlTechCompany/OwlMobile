//
//  GetLastMessagesResponse.swift
//  Owl
//
//  Created by Anastasia Holovash on 05.08.2022.
//

import Foundation
import Firebase

struct GetLastMessagesResponse: Equatable {
    let messageResponse: [MessageResponse]
    let lastDocumentSnapshot: DocumentSnapshot
    let subscribeForNewMessagesSnapshot: DocumentSnapshot
}
