//
//  MessageResponse.swift
//  Owl
//
//  Created by Anastasia Holovash on 02.05.2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessageResponse: Decodable, Equatable, Identifiable {

    let id: String
    let messageText: String
    let sentAt: Date?
    let sentBy: String

}
