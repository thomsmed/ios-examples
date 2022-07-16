//
//  ViewController.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 15/07/2022.
//

import UIKit

class ViewController: UIViewController {

    private var dataArray: [SomeData] = []

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    let dataTableTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Data table (loaded from UserDefaults)"
        return label
    }()

    let addDataButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add data", for: .normal)
        return button
    }()

    let dataTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()

    let beginBackgroundTaskButton: UIButton = {
        let button = UIButton()
        button.setTitle("Begin background task", for: .normal)
        return button
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    override func loadView() {
        view = UIView()

        view.addSubview(dataTableTitleLabel)
        view.addSubview(addDataButton)
        view.addSubview(dataTableView)
        view.addSubview(beginBackgroundTaskButton)
        view.addSubview(messageLabel)

        dataTableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addDataButton.translatesAutoresizingMaskIntoConstraints = false
        dataTableView.translatesAutoresizingMaskIntoConstraints = false
        beginBackgroundTaskButton.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dataTableTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dataTableTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            dataTableView.topAnchor.constraint(equalTo: dataTableTitleLabel.bottomAnchor, constant: 16),
            dataTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dataTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dataTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            addDataButton.topAnchor.constraint(equalTo: dataTableView.bottomAnchor, constant: 16),
            addDataButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            beginBackgroundTaskButton.topAnchor.constraint(equalTo: addDataButton.bottomAnchor, constant: 64),
            beginBackgroundTaskButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: beginBackgroundTaskButton.bottomAnchor, constant: 32)
        ])

        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        dataTableView.dataSource = self

        addDataButton.addTarget(self, action: #selector(addData), for: .primaryActionTriggered)
        beginBackgroundTaskButton.addTarget(self, action: #selector(beginBackgroundTask), for: .primaryActionTriggered)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        defer {
            dataTableView.reloadSections(.init(integer: 0), with: .automatic)
        }

        guard let data = UserDefaults.standard.data(forKey: "data") else {
            dataArray = []

            return
        }

        dataArray = (try? jsonDecoder.decode([SomeData].self, from: data)) ?? []
    }

    @objc private func addData(_ target: UIButton) {
        dataArray.append(.init(content: "Data item \(dataArray.count)", timestamp: .now))

        defer {
            dataTableView.reloadSections(.init(integer: 0), with: .automatic)
        }

        guard let data = try? jsonEncoder.encode(dataArray) else {
            dataArray = []

            return
        }

        UserDefaults.standard.set(data, forKey: "data")
    }

    @objc private func beginBackgroundTask(_ target: UIButton) {
        let application = UIApplication.shared

        // Call this as fast as possible (before the app might go into background).
        // It allows the app process to continue execution for a short while even after the app goes into background.
        // The app process is normally paused while the app is in background otherwise.

        var taskIdentifier: UIBackgroundTaskIdentifier?
        taskIdentifier = application.beginBackgroundTask() {
            // This is a good time to inform the user about the failed task, and ask the user to try again.
            print("Ups! Requested background execution expired, the system is likely to kill the app process if you do not make a call to .endBackgroundTask")

            guard let identifier = taskIdentifier else {
                return
            }

            application.endBackgroundTask(identifier)

            taskIdentifier = nil
        }

        messageLabel.text = "Work began"

        // NOTE: Dispatch Queue work will always be run. If the app goes into background,
        // the work will be executed when the app process is back to running in the foreground
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(until: Date().addingTimeInterval(16))

            print("Time left of allowed background execution (in seconds):", application.backgroundTimeRemaining)

            DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
                print("Time left of allowed background execution (in seconds):", application.backgroundTimeRemaining)

                self.messageLabel.text = "Work ended"

                guard let identifier = taskIdentifier else {
                    return
                }

                // And always pair up with a call to this:
                application.endBackgroundTask(identifier)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let dataItem = dataArray[indexPath.row]
        cell.textLabel?.text = "\(dataItem.content) (created \(dataItem.timestamp.formatted())"

        return cell
    }
}
