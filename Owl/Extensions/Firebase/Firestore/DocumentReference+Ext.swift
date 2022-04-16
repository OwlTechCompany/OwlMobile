//
//  DocumentReference+Ext.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

extension DocumentReference {

    func updateData<T: Encodable>(
        from value: T,
        encoder: Firestore.Encoder = Firestore.Encoder()
    ) -> Future<Void, Error> {
        Future { promise in
            do {
                let data = try encoder.encode(value)
                self.updateData(data) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
    }
}
