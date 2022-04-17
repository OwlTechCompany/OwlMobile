//
//  Message.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import Foundation

struct Message: Codable, Equatable {

    let messageText: String
    let sentAt: Date
    let sentBy: String
    
}
