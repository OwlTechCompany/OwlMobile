//
//  EnterCodeView.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct EnterCodeView: View {

    // MARK: - ViewState

    struct ViewState: Equatable {
        @BindableState var verificationCode: String
        let phoneNumber: String
    }

    // MARK: - ViewAction

    enum ViewAction: Equatable, BindableAction {
        case sendCode
        case binding(BindingAction<ViewState>)
    }

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    @FocusState private var focusedField: Bool

    var body: some View {

        WithViewStore(store.scope(state: \LoginState.view, action: LoginAction.view)) { viewStore in
            VStack(spacing: 48.0) {
                VStack(spacing: 16.0) {
                    Text("Enter Code")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))

                    VStack(spacing: 8.0) {
                        Text("We have sent you an SMS with the code to")
                        Text(viewStore.phoneNumber)
                    }
                    .font(.system(size: 14, weight: .regular, design: .default))
                }

                ZStack {
                    HStack(spacing: 24.0) {
                        ForEach(Constants.codeSizeRange) { index in
                            ZStack {
                                Circle()
                                    .frame(width: Constants.circleSize, height: Constants.circleSize)
                                    .foregroundColor(
                                        Color.gray.opacity(
                                            Array(viewStore.verificationCode)[safe: index] != nil ? 0 : 0.3
                                        )
                                    )
                                if Array(viewStore.verificationCode)[safe: Int(index)] != nil {
                                     Text(String(Array(viewStore.verificationCode)[safe: Int(index)]!))
                                        .font(.system(size: Constants.circleSize, weight: .bold, design: .monospaced))

                                }
                            }
                        }
                    }

                    TextField("", text: viewStore.binding(\.$verificationCode))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .tint(.clear)
                        .accentColor(.clear)
                        .foregroundColor(.clear)
                        .keyboardType(.numberPad)
                        .focused($focusedField)
                        .frame(width:
                                CGFloat((Constants.codeSize * 2 - 1)) * Constants.circleSize
                        )
                }

                Button(
                    action: { print("Resend Code") },
                    label: {
                        Text("Resend Code")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    }
                )
            }
            .onAppear {
                focusedField = true
            }
        }
    }

    enum Constants {
        static let codeSize = 6
        static let codeSizeRange: Range<Int> = 0 ..< Constants.codeSize
        static let circleSize: CGFloat = 24
    }
}

// MARK: - LoginState + ViewState

private extension LoginState {
    var view: EnterCodeView.ViewState {
        get {
            EnterCodeView.ViewState(
                verificationCode: verificationCode,
                phoneNumber: phoneNumber
            )
        }
        set {
            verificationCode = newValue.verificationCode
        }
    }
}

// MARK: - LoginAction + ViewAction

private extension LoginAction {
    static func view(_ viewAction: EnterCodeView.ViewAction) -> Self {
        switch viewAction {
        case let .binding(action):
            return .binding(action.pullback(\.view))

        case .sendCode:
            return .sendCode
        }
    }
}

// MARK: - Preview

struct EnterCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterCodeView(
            store: Store(
                initialState: LoginState(),
                reducer: loginReducer,
                environment: AppEnvironment.live.login
            )
        )
    }
}
