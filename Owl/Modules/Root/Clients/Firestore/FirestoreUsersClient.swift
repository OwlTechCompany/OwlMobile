//
//  FirestoreUsersClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Combine
import ComposableArchitecture
import FirebaseFirestoreCombineSwift
import Firebase

struct FirestoreUsersClient {

    static let collection = Firestore.firestore().collection("users")
    static var cancellables = Set<AnyCancellable>()

    var setMeIfNeeded: () -> Effect<SetMeSuccess, NSError>
    var updateUser: (UpdateUser) -> Effect<Bool, NSError>
}

// MARK: - Live

extension FirestoreUsersClient {

    static let live = FirestoreUsersClient(
        setMeIfNeeded: {
            .future { result in
                guard let authUser = Auth.auth().currentUser else {
                    result(.failure(NSError(domain: "No current user", code: 1)))
                    return
                }
                let user = User(
                    uid: authUser.uid,
                    phoneNumber: authUser.phoneNumber,
                    firstName: nil,
                    lastName: nil
                )
                let documentRef = collection.document(authUser.uid)
                documentRef.getDocument()
                    .catch { error -> AnyPublisher<DocumentSnapshot, Never> in
                        result(.failure(error as NSError))
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
                    .flatMap { snapshot -> AnyPublisher<Void, Error> in
                        if !snapshot.exists {
                            return documentRef.setData(from: user)
                                .eraseToAnyPublisher()
                        } else {
                            result(.success(.userExists))
                            return Empty(completeImmediately: true)
                                .eraseToAnyPublisher()
                        }
                    }
                    .on(
                        value: { _ in result(.success(.newUser)) },
                        error: { error in result(.failure(error as NSError)) }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        },
        updateUser: { userUpdate in
            .future { result in
                guard let authUser = Auth.auth().currentUser else {
                    result(.failure(NSError(domain: "No current user", code: 1)))
                    return
                }
                collection.document(authUser.uid).updateData(from: userUpdate)
                    .on(
                        value: { result(.success(true)) },
                        error: { error in result(.failure(error as NSError)) }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        }
    )
}

extension Encodable {

    func toParameters(with encoder: JSONEncoder = JSONEncoder()) -> [String: Any]? {

        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

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

extension Publisher {

    func on(
        value: ((Output) -> Void)? = nil,
        error: ((Failure) -> Void)? = nil,
        finished: (() -> Void)? = nil
    ) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveOutput: { output in
                value?(output)
            },
            receiveCompletion: { completion in
                switch completion {
                case .failure(let failure):
                    error?(failure)
                case .finished:
                    finished?()
                }
            }
        )
        .eraseToAnyPublisher()
    }

    func sink() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
