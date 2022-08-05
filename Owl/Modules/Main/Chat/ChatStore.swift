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

        case getMessagesResult(Result<[MessageResponse], NSError>)
        case getLastMessagesResult(Result<GetLastMessagesResponse, NSError>)
        case getOldMessagesResult(Result<GetNextMessagesResponse, NSError>)
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

        case let .messages(id, .wasShown):
            guard
                id == state.messages.last?.id && !state.isLoading,
                let lastDocumentSnapshot = state.lastDocumentSnapshot
            else {
                return .none
            }

            state.isLoading = true
            return environment.chatsClient.getNextMessages(lastDocumentSnapshot)
                .catchToEffect(Action.getOldMessagesResult)

        case .binding(\.$newMessage):
            return .none

        case .binding:
            return .none

        case .onAppear:
            environment.chatsClient.openedChatId.send(state.chatID)
            return environment.chatsClient.getLastMessages()
                .catchToEffect(Action.getLastMessagesResult)
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

        case let .getMessagesResult(.success(messages)):
            state.newMessages = messages.map { ChatMessage.State(message: $0, companion: state.companion) }
            return .none

        case let .getMessagesResult(.failure(error)):
            return .none

        case let .getLastMessagesResult(.success(response)):
            state.oldMessages = response.messageResponse.map { ChatMessage.State(message: $0, companion: state.companion) }
            state.lastDocumentSnapshot = response.lastDocumentSnapshot
            return environment.chatsClient.subscribeForNewMessages(response.subscribeForNewMessagesSnapshot)
                .catchToEffect(Action.getMessagesResult)

        case let .getLastMessagesResult(.failure(error)):
            return .none

        case let .getOldMessagesResult(.success(response)):
            let update = response.messageResponse.map { ChatMessage.State(message: $0, companion: state.companion) }
            state.oldMessages.append(contentsOf: update)
            state.lastDocumentSnapshot = response.lastDocumentSnapshot
            state.isLoading = false
            return .none

        case let .getOldMessagesResult(.failure(error)):
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
        if let lastMessage = model.lastMessage {
            self.newMessages = [
                ChatMessage.State(
                    message: lastMessage,
                    companion: model.companion
                )
            ]
        } else {
            self.newMessages = []
        }
        self.oldMessages = []
    }

}
