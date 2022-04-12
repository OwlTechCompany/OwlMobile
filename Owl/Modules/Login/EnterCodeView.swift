//
//  EnterCodeView.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct EnterCode {

    // MARK: - State

    struct State: Equatable {
        @BindableState var verificationCode: String
        var phoneNumber: String

        // For some very strange reasons TextField Binding<String> is setting its value two time
        // To fix this (not to send code twice) i decided to use this variable
        var isCodeSent: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)

        enum DelegateAction {
            case sendCode
            case resendCode
        }
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .binding(\.$verificationCode):
            if state.verificationCode.count == 6 && !state.isCodeSent {
                state.isCodeSent = true
                return Effect(value: .delegate(.sendCode))
            } else {
                return .none
            }

        case .delegate(.resendCode):
            state.isCodeSent = false
            return .none

        case .delegate:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}

// MARK: - View

struct EnterCodeView: View {

    var store: Store<EnterCode.State, EnterCode.Action>

    @FocusState private var focusedField: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
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
                        ForEach(Constants.codeSizeRange, id: \.self) { index in
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
                        .textContentType(.oneTimeCode)
                        .accentColor(.clear)
                        .foregroundColor(.clear)
                        .keyboardType(.numberPad)
                        .frame(
                            width: CGFloat((Constants.codeSize * 2 - 1)) * Constants.circleSize
                        )
                        .focused($focusedField)

                }

                Button(
                    action: { viewStore.send(.delegate(.resendCode)) },
                    label: {
                        Text("Resend Code")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                    }
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation {
                        focusedField = true
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    enum Constants {
        static let codeSize = 6
        static let codeSizeRange: Range<Int> = 0 ..< Constants.codeSize
        static let circleSize: CGFloat = 24
    }
}

// MARK: - Preview

struct EnterCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterCodeView(
            store: Store(
                initialState: EnterCode.State(
                    verificationCode: "123",
                    phoneNumber: "+380992177560"
                ),
                reducer: EnterCode.reducer,
                environment: EnterCode.Environment()
            )
        )
    }
}
