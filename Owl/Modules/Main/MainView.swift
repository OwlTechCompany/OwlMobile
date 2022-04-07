//
//  MainView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct MainState: Equatable {

}

// MARK: - Action

enum MainAction: Equatable {
    case logout
}

// MARK: - Environment

struct MainEnvironment {

}

// MARK: - Reducer

let mainReducer = Reducer<MainState, MainAction, MainEnvironment> { _, action, _ in
    switch action {
    case .logout:
        return .none
    }
}

// MARK: - View

struct MainView: View {

    var store: Store<MainState, MainAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.pink
                    .ignoresSafeArea()

                VStack {
                    Text("Main")
                        .foregroundColor(Colors.test.swiftUIColor)
                        .padding()

                    Button(
                        action: {
                            viewStore.send(.logout)
                        },
                        label: {
                            Text("Logout")
                                .foregroundColor(.white)
                        }
                    )
                }
            }

        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(
            initialState: .init(),
            reducer: mainReducer,
            environment: MainEnvironment()
        ))
    }
}
