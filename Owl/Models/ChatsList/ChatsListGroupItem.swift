//
//  ChatsListGroupItem.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import Foundation
import Firebase

struct ChatsListGroupItem: Decodable {
    
    let id: String
    let name: String
    let createdAt: Date
    let createdBy: String
    let members: [String]
    let lastMessage: MessageResponse

}
