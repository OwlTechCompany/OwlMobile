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

extension Publisher where Output == Never {
    public func setOutputType<NewOutput>(to _: NewOutput.Type) -> AnyPublisher<NewOutput, Failure> {
        func absurd<A>(_ never: Never) -> A {}
        return self.map(absurd).eraseToAnyPublisher()
    }
}

extension Publisher {
    public func ignoreOutput<NewOutput>(
        setOutputType: NewOutput.Type
    ) -> AnyPublisher<NewOutput, Failure> {
        return
        self
            .ignoreOutput()
            .setOutputType(to: NewOutput.self)
    }

    public func ignoreFailure<NewFailure>(
        setFailureType: NewFailure.Type
    ) -> AnyPublisher<Output, NewFailure> {
        self
            .catch { _ in Empty() }
            .setFailureType(to: NewFailure.self)
            .eraseToAnyPublisher()
    }

    public func ignoreFailure() -> AnyPublisher<Output, Never> {
        self
            .catch { _ in Empty() }
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }
}
