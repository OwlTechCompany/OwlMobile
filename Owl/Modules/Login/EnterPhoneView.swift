//
//  EnterPhoneView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginState + ViewState

private extension LoginState {
    var view: EnterPhoneView.ViewState {
        get {
            EnterPhoneView.ViewState(
                phoneNumber: phoneNumber,
                route: (/LoginState.Route.enterPhone).extract(from: route)
            )
        }
        set {
            phoneNumber = newValue.phoneNumber
            route = (/LoginState.Route.enterPhone).embed(newValue.route)
        }
    }
}

// MARK: - LoginAction + ViewAction

private extension LoginAction {
    static func view(_ viewAction: EnterPhoneView.ViewAction) -> Self {
        switch viewAction {
        case let .binding(action):
            return .binding(action.pullback(\.view))

        case let .setRoute(route):
            return .setRoute(.enterPhone(route))

        case .sendPhoneNumber:
            return .sendPhoneNumber
        }
    }
}

// MARK: - View

struct EnterPhoneView: View {

    // MARK: - ViewState

    struct ViewState: Equatable {
        @BindableState var phoneNumber: String
        var route: Route?
    }

    // MARK: - ViewAction

    enum ViewAction: Equatable, BindableAction {
        case sendPhoneNumber
        case setRoute(Route?)
        case binding(BindingAction<ViewState>)
    }

    enum Route: Equatable {


        case enterCode
    }

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    var body: some View {
//        print(store.sta)
//        print("EnterPhoneView.body = \(ViewStore(store.scope(state: \LoginState.view, action: LoginAction.view)).state.route)")
        return WithViewStore(store.scope(state: \LoginState.view, action: LoginAction.view)) { viewStore in
            VStack(spacing: 16) {
                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                    .textFieldStyle(PlainTextFieldStyle())
//                    .foregroundColor(viewStore.state.route == .enterCode ? Color.red : Color.blue)

//                NavigationLink(
//                    isActive: viewStore.binding(get: \.route, send: ViewAction.setRoute).isPresent(),
//                    destination: {
//                        Text("Enter code")
//                            .foregroundColor(.red)
//                    },
////                    onNavigate: { value in print("ON navigate \(value)") },
//                    label: { Text("Link") }
//                )

                NavigationLink(
                    unwrapping: viewStore.binding(get: {
                        print("$0.route \($0.route)")
                        return $0.route

                    }, send: {

                        ViewAction.setRoute($0)
                    }),
                    case: /Route.enterCode,
                    destination: { _ in
                        Text("Enter code")
                            .background(Color.orange)
                            .navigationBarTitle("Enter code")
                            .zIndex(100)

                    }, onNavigate: { _ in

                    }, label: {
                        Button(
                            action: { viewStore.send(.sendPhoneNumber) },
                            label: { Text("Next") }
                        )
                    }
                )
//                NavigationLink(
//                    isActive: viewStore.binding(get: \.route, send: ViewAction.setRoute).isPresent(/Route.enterCode),
//                    destination: {
//                        Text("Enter code")
//                            .background(Color.orange)
//                            .navigationBarTitle("Enter code")
//                    },
//                    label: {
//                        Text("Link")
//                    }
//                )
            }
            .padding()
//            .sheet(item: <#T##SwiftUI.Binding<Item?>#>) { <#Item#> in
//                <#code#>
//            }
//            .sheet(unwrapping: viewStore.binding(get: \.route, send: ViewAction.setRoute)) {_ in
//                Text("Enter code")
//            }
//            .sheet(isPresented: viewStore.binding(get: \.route, send: ViewAction.setRoute).isPresent(/Route.enterCode), content: {
//                Text("Enter code")
//                    .background(Color.orange)
//            })
        }
    }
}

// MARK: - Preview

struct EnterPhoneNumber_Previews: PreviewProvider {
    static var previews: some View {
        EnterPhoneView(store: Store(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: AppEnvironment.live.login
        ))
    }
}
