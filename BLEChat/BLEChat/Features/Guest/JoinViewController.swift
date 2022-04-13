//
//  JoinViewController.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/01/2022.
//

import UIKit
import Combine

final class JoinViewController: UITableViewController {

    private let lastSeenFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        return dateFormatter
    }()

    private var chatHosts: [DiscoveredChatHost] = []

    private var stateSub: AnyCancellable?
    private var chatHostsSub: AnyCancellable?

    override func loadView() {
        super.loadView()

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Who to chat with?"

        navigationItem.setLeftBarButton(UIBarButtonItem(systemItem: .close, primaryAction: UIAction(handler: close(_:))), animated: true)

        refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: refresh(_:)))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSubscriptions()
        Dependencies.chatHostScanner.startScan()
        refreshControl?.beginRefreshing()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tearDownSubscriptions()
        Dependencies.chatHostScanner.stopScan()
    }

    private func setupSubscriptions() {
        stateSub = Dependencies.chatHostScanner.state.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] state in
            guard let self = self else { return }
            if state == .ready {
                self.chatHosts = []
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                Dependencies.chatHostScanner.startScan()
            } else if state == .unauthorised {
                let alert = UIAlertController(
                    title: "Unauthorised",
                    message: "This applications need access to Bluetooth",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("OK", comment: "Default action"),
                    style: .default
                ))
                self.present(alert, animated: true)
            }
        })

        chatHostsSub = Dependencies.chatHostScanner.discoveries.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] discovery in
            guard let self = self else { return }
            switch discovery {
            case let .discovered(discoveredChatHost):
                if self.refreshControl?.isRefreshing ?? false {
                    self.chatHosts = [discoveredChatHost]
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    self.refreshControl?.endRefreshing()
                } else {
                    self.chatHosts.append(discoveredChatHost)
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            case let .rediscovered(rediscoveredChatHost):
                guard
                    let index = self.chatHosts.firstIndex(where: { chatHost in chatHost.uuid == rediscoveredChatHost.uuid })
                else { return }
                self.chatHosts[index] = rediscoveredChatHost
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        })
    }

    private func tearDownSubscriptions() {
        stateSub = nil
        chatHostsSub = nil
    }

    private func close(_ action: UIAction) {
        navigationController?.popViewController(animated: true)
    }

    private func refresh(_ action: UIAction) {
        refreshControl?.beginRefreshing()
        Dependencies.chatHostScanner.stopScan() // Triggers a state update (which then again triggers a new scan)
    }
}

// MARK: UITableViewDelegate

extension JoinViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatHost = chatHosts[indexPath.row]
        navigationController?.pushViewController(GuestChatViewController(chatHost: chatHost), animated: true)
    }
}

// MARK: UITableViewDataSource

extension JoinViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let chatHost = chatHosts[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = chatHost.name
        configuration.secondaryText = "Last seen \(lastSeenFormatter.string(from: chatHost.lastSeen))"
        cell.contentConfiguration = configuration
        return cell
    }
}
