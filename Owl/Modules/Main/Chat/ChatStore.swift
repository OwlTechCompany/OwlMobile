//
//  ChatStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import ComposableArchitecture
import Firebase
import IdentifiedCollections

struct Chat {

    // MARK: - State

    struct State: Equatable {
        var chatID: String
        var companion: User
        var navigation: ChatNavigation.State
        var newMessages: [ChatMessage.State]
        var oldMessages: [ChatMessage.State]
        var isLoading: Bool = false
        var lastDocumentSnapshot: DocumentSnapshot?
        var messages: IdentifiedArrayOf<ChatMessage.State> {
            IdentifiedArrayOf(uniqueElements: newMessages + oldMessages)
        }

        var model: ChatsListPrivateItem
        
        @BindableState var newMessage: String = ""
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case navigation(ChatNavigation.Action)
        case messages(id: String, action: ChatMessage.Action)

        case binding(BindingAction<State>)
        case onAppear

        case sendMessage
        case sendMessageResult(Result<Bool, NSError>)

        case getMessages(Result<[MessageResponse], NSError>)
        case getLastMessages(Result<GetLastMessagesResponse, NSError>)
        case getPaginatedMessages(Result<GetPaginatedMessagesResponse, NSError>)
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

        case let .messages(id, .onAppear):
            guard
                id == state.messages.last?.id && !state.isLoading,
                let lastDocumentSnapshot = state.lastDocumentSnapshot
            else {
                return .none
            }

            state.isLoading = true
            return environment.chatsClient.getPaginatedMessages(lastDocumentSnapshot)
                .catchToEffect(Action.getPaginatedMessages)

        case .binding(\.$newMessage):
            return .none

        case .binding:
            return .none

        case .onAppear:
            environment.chatsClient.openedChatId.send(state.chatID)
            return environment.chatsClient.getLastMessages()
                .catchToEffect(Action.getLastMessages)
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
            // Subscribe for updates if it is fist message in chat
            guard !state.oldMessages.isEmpty else {
                return environment.chatsClient.getLastMessages()
                    .catchToEffect(Action.getLastMessages)
                    .cancellable(id: Main.ListenersId())
            }
            return .none

        case let .getMessages(.success(messages)):
            state.newMessages = messages.map { ChatMessage.State(message: $0, companion: state.companion) }
            return .none

        case let .getMessages(.failure(error)):
            return .none

        case let .getLastMessages(.success(response)):
            state.oldMessages = response.messageResponse.map { ChatMessage.State(message: $0, companion: state.companion) }
            state.lastDocumentSnapshot = response.lastDocumentSnapshot
            return environment.chatsClient.subscribeForNewMessages(response.subscribeForNewMessagesSnapshot)
                .catchToEffect(Action.getMessages)

        case let .getLastMessages(.failure(error)):
            return .none

        case let .getPaginatedMessages(.success(response)):
            let update = response.messageResponse.map { ChatMessage.State(message: $0, companion: state.companion) }
            state.oldMessages.append(contentsOf: update)
            state.lastDocumentSnapshot = response.lastDocumentSnapshot
            state.isLoading = false
            return .none

        case let .getPaginatedMessages(.failure(error)):
            state.isLoading = false
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
        self.newMessages = []
        self.oldMessages = []
    }

}
