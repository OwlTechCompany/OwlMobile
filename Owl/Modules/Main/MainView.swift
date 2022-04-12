//
//  MainView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct Main {

    // MARK: - State

    struct State: Equatable {

        static let initialState = State()
    }

    // MARK: - Action

    enum Action: Equatable {
        case logout
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .logout:
            return .none
        }
    }

}

// MARK: - View

struct MainView: View {

    var store: Store<Main.State, Main.Action>

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
                        action: { viewStore.send(.logout) },
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

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(
            initialState: Main.State(),
            reducer: Main.reducer,
            environment: Main.Environment()
        ))
    }
}
