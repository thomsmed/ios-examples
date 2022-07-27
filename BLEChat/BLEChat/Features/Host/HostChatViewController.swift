//
//  HostChatViewController.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/01/2022.
//

import UIKit
import Combine

final class HostChatViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()

    private let reactionsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: ["❤️", "🥺", "😱", "👏", "🙂", "🤣"].map { reaction in
            var configuration: UIButton.Configuration = .plain()
            configuration.title = reaction
            return UIButton(configuration: configuration)
        })
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let messageInputTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 8
        return textField
    }()

    private let submitMessageButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedTinted()
        configuration.title = "Send"
        return UIButton(configuration: configuration)
    }()

    private var chatSections: [ChatSection] = [ChatSection(title: "Waiting for guests to join...", messages: [])]
    
    private var stateSub: AnyCancellable?
    private var chatEventsSub: AnyCancellable?
    private var messagesSub: AnyCancellable?
    private var reactionsSub: AnyCancellable?

    override func loadView() {
        super.loadView()

        view.addSubview(tableView)

        tableView.topToSuperview()
        tableView.leadingToSuperview()
        tableView.trailingToSuperview()

        submitMessageButton.setHugging(.defaultHigh, for: .horizontal)
        let horizontalStackView = UIStackView(arrangedSubviews: [messageInputTextField, submitMessageButton])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 8

        let verticalStackView = UIStackView(arrangedSubviews: [reactionsStackView, horizontalStackView])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8

        view.addSubview(verticalStackView)

        verticalStackView.topToBottom(of: tableView)
        verticalStackView.leadingToSuperview(offset: 8)
        verticalStackView.trailingToSuperview(offset: 8)
        verticalStackView.bottomToSuperview(offset: -8, usingSafeArea: true)

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chat (Hosting)"

        navigationItem.setLeftBarButton(UIBarButtonItem(systemItem: .close, primaryAction: UIAction(handler: close(_:))), animated: true)

        tableView.dataSource = self
        tableView.register(ChatBubbleTableViewCell.self, forCellReuseIdentifier: "cell")

        submitMessageButton.addAction(UIAction(handler: submitMessage(_:)), for: .primaryActionTriggered)

        reactionsStackView.arrangedSubviews.forEach { view in
            guard let  button = view as? UIButton else { return }
            button.addAction(UIAction(handler: submitReaction(_:)), for: .primaryActionTriggered)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSubscriptions()
        setupObservers()
        messageInputTextField.becomeFirstResponder()
        Dependencies.chatHost.startBroadcast()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tearDownSubscriptions()
        tearDownObservers()
        Dependencies.chatHost.stopBroadcast()
    }

    private func close(_ action: UIAction) {
        navigationController?.popViewController(animated: true)
    }

    private func setupSubscriptions() {
        stateSub = Dependencies.chatHost.state.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] state in
            guard
                state == .unauthorised,
                let self = self
            else { return }
            let alert = UIAlertController(
                title: "Unauthorised",
                message: "This applications need access to Bluetooth",
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("OK", comment: "Default action"),
                    style: .default
                )
            )
            self.present(alert, animated: true)
        })

        chatEventsSub = Dependencies.chatHost.chatEvents.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] chatEvent in
            guard let self = self else { return }
            switch chatEvent {
            case .guestJoined:
                self.chatSections.append(
                    ChatSection(
                        title: "Guest joined",
                        messages: []
                    )
                )
                self.tableView.insertSections(IndexSet(integer: self.chatSections.count - 1), with: .left)
                self.tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: self.chatSections.count - 1), at: .bottom, animated: true)
            case .guestLeft:
                self.chatSections.append(
                    ChatSection(
                        title: "Guest left",
                        messages: []
                    )
                )
                self.tableView.insertSections(IndexSet(integer: self.chatSections.count - 1), with: .left)
                self.tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: self.chatSections.count - 1), at: .bottom, animated: true)
            }
        })

        messagesSub = Dependencies.chatHost.messages.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] message in
            guard
                let self = self,
                let lastChatSection = self.chatSections.last
            else { return }
            let indexPath = IndexPath(row: lastChatSection.messages.count, section: self.chatSections.count - 1)
            self.chatSections[self.chatSections.count - 1].messages.append(ChatBubbleMessage(message: message, incoming: true))
            self.tableView.insertRows(at: [indexPath], with: .bottom)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })

        reactionsSub = Dependencies.chatHost.reactions.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] reaction in
            self?.animateReceived(reaction: reaction)
        })
    }

    private func tearDownSubscriptions() {
        stateSub = nil
        chatEventsSub = nil
        messagesSub = nil
        reactionsSub = nil
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    private func tearDownObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        let height = keyboardValue.cgRectValue.height - view.safeAreaInsets.bottom
        additionalSafeAreaInsets = .bottom(height)
    }

    private func submitMessage(_ action: UIAction) {
        if let message = messageInputTextField.text, let lastChatSection = chatSections.last {
            let indexPath = IndexPath(row: lastChatSection.messages.count, section: self.chatSections.count - 1)
            chatSections[chatSections.count - 1].messages.append(ChatBubbleMessage(message: message, incoming: false))
            tableView.insertRows(at: [indexPath], with: .bottom)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            Dependencies.chatHost.submit(message: message)
        }
        messageInputTextField.text = nil
    }

    private func submitReaction(_ action: UIAction) {
        guard
            let button = action.sender as? UIButton,
            let reaction = button.configuration?.title
        else { return }
        animateSubmitted(reaction: reaction, from: reactionsStackView.convert(button.center, to: view))
        Dependencies.chatHost.submit(reaction: reaction)
    }

    private func animateSubmitted(reaction: String, from point: CGPoint) {
        let label = UILabel()
        label.text = reaction
        label.font = .systemFont(ofSize: 24)
        label.sizeToFit()
        label.center = point
        label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.addSubview(label)
        UIView.animate(withDuration: 0.5, animations: {
            label.center = CGPoint(x: label.center.x, y: label.center.y - 100)
            label.transform = .identity
        }, completion: { _ in
            label.removeFromSuperview()
        })
    }

    private func animateReceived(reaction: String) {
        let label = UILabel()
        label.text = reaction
        label.font = .systemFont(ofSize: 95)
        label.sizeToFit()
        label.center = CGPoint(x: 0, y: tableView.bounds.height - 20)
        label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        view.addSubview(label)
        UIView.animate(withDuration: 0.5, animations: {
            label.center = CGPoint(x: self.tableView.bounds.width * 0.33, y: label.center.y - 50)
            label.transform = .identity
        }, completion: { _ in
            label.removeFromSuperview()
        })
    }
}

// MARK: UITableViewDataSource

extension HostChatViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        chatSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatSections[section].messages.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        chatSections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatBubbleTableViewCell
        else {
            fatalError("Could not dequeue reusable cell of type \(String(describing: ChatBubbleTableViewCell.self))")
        }
        let message = chatSections[indexPath.section].messages[indexPath.row]
        cell.setup(with: message)
        return cell
    }
}
