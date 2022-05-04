//
//  JSONDecoder.swift
//  Owl
//
//  Created by Denys Danyliuk on 03.05.2022.
//

import Foundation
import FirebaseFirestore

extension JSONDecoder {

    static var customFirestore: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            enum CodingKeys: String, CodingKey {
                case nanoseconds = "_nanoseconds"
                case seconds = "_seconds"
            }
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let nano = try container.decode(Int32.self, forKey: .nanoseconds)
                let sec = try container.decode(Int64.self, forKey: .seconds)
                let timestamp = Timestamp(seconds: sec, nanoseconds: nano)
                return timestamp.dateValue()
            } catch {
                assertionFailure("Can't parse date")
                return Date()
            }
        })
        return decoder
    }

}
