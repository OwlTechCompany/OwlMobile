//
//  MessageRequest.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessageRequest: Encodable, Equatable, Identifiable {

    var id: String?
    let messageText: String
    @ServerTimestamp var sentAt: Timestamp?
    let sentBy: String
    
}
