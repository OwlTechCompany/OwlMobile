//
//  MainView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

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
