//
//  Publisher+Ext.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Foundation
import Combine

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
