//
//  GetPaginatedMessagesResponse.swift
//  Owl
//
//  Created by Anastasia Holovash on 05.08.2022.
//

import Foundation
import Firebase

struct GetPaginatedMessagesResponse: Equatable {
    let messageResponse: [MessageResponse]
    let lastDocumentSnapshot: DocumentSnapshot?
}
