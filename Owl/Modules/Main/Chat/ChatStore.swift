//
//  ChatStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import ComposableArchitecture

var openedChatId: String?

struct Chat {

    // MARK: - State

    struct State: Equatable {
        var chatID: String
        var companion: User
        var navigation: ChatNavigation.State
        var messages: IdentifiedArrayOf<ChatMessage.State>

        var model: ChatsListPrivateItem
        
        @BindableState var newMessage: String = ""
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case navigation(ChatNavigation.Action)
        case messages(id: String, action: ChatMessage.Action)

        case getMessagesResult(Result<[MessageResponse], NSError>)
        case binding(BindingAction<State>)
        case onAppear
        case sendMessage
        case sendMessageResult(Result<Bool, NSError>)
    }

    // MARK: - Environment

    struct Environment {
        let chatsClient: FirestoreChatsClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .navigation:
            return .none

        case let .getMessagesResult(.success(messages)):
            state.messages = .init(uniqueElements: messages.map {
                ChatMessage.State(message: $0, companion: state.companion)
            })
            return .none

        case let .getMessagesResult(.failure(error)):
            return .none

        case .binding(\.$newMessage):
            return .none

        case .binding:
            return .none

        case .onAppear:
            openedChatId = state.chatID
            return environment.chatsClient.getMessages(state.chatID)
                .catchToEffect(Action.getMessagesResult)
                .cancellable(id: Main.ListenersId())

        case .sendMessage:
            let newMessage = NewMessage(
                chatId: state.model.id,
                message: MessageRequest(
                    messageText: state.newMessage,
                    sentBy: state.model.me.uid
                )
            )
            state.newMessage = ""
            return environment.chatsClient.sendMessage(newMessage)
                .catchToEffect(Action.sendMessageResult)

        case .sendMessageResult:
            return .none
        }
    }
    .binding()

    static let reducer = Reducer<State, Action, Environment>.combine(
        ChatNavigation.reducer
            .pullback(
                state: \State.navigation,
                action: /Action.navigation,
                environment: { _ in ChatNavigation.Environment() }
            ),
        reducerCore
    )

}

extension Chat.State {

    init(model: ChatsListPrivateItem) {
        self.chatID = model.id
        self.companion = model.companion
        self.navigation = .init(model: model)
        self.model = model
        if let lastMessage = model.lastMessage {
            self.messages = .init(
                uniqueElements: [
                    ChatMessage.State(
                        message: lastMessage,
                        companion: model.companion
                    )
                ]
            )
        } else {
            self.messages = []
        }
    }

}
