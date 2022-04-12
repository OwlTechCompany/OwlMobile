//
//  EnterCodeView.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct EnterCodeState: Equatable {
    @BindableState var verificationCode: String
    var phoneNumber: String
}

// MARK: - Action

enum EnterCodeAction: Equatable, BindableAction {
    case sendCode
    case binding(BindingAction<EnterCodeState>)
}

// MARK: - Environment

struct EnterCodeEnvironment {

}

// MARK: - Reducer

let enterCodeReducer = Reducer<EnterCodeState, EnterCodeAction, Void> { state, action, environment in
    switch action {
    case .binding(\.$verificationCode):
        return .none

    case .sendCode:
        return .none

    case .binding:
        return .none
    }
}
.binding()

struct EnterCodeView: View {

    // MARK: - Properties

    var store: Store<EnterCodeState, EnterCodeAction>

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
                    action: { print("Resend Code") },
                    label: {
                        Text("Resend Code")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    }
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    withAnimation {
                        focusedField = true
                    }
                }
            }
        }
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
                initialState: EnterCodeState(verificationCode: "123", phoneNumber: "+380992177560"),
                reducer: enterCodeReducer,
                environment: ()
            )
        )
    }
}
