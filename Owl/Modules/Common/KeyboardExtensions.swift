//
//  KeyboardExtensions.swift
//  Owl
//
//  Created by Anastasia Holovash on 28.04.2022.
//

import UIKit
import Combine

struct Keyboard: Equatable {
    var height: CGFloat
    var duration: CGFloat

    static let initialValue = Keyboard(height: 0, duration: 0)
}

extension Publishers {

    static var keyboardHeightPublisher: AnyPublisher<Keyboard, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { value -> (NSValue, NSNumber)? in
                    guard
                        let frame = value.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
                        let duration = value.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                    else {
                        return nil
                    }
                    return (frame, duration)
                }
                .map { Keyboard(height: $0.cgRectValue.height, duration: $1.doubleValue) },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .compactMap {
                    $0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                }
                .map { Keyboard(height: 0, duration: $0.doubleValue) }
        )
        .eraseToAnyPublisher()
    }

}
