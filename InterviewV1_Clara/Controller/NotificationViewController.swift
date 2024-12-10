//
//  NotificationViewController.swift
//  InterviewV1_Clara
//
//  Created by 小妍寶 on 2024/12/9.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private var notifications: [NotificationMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchNotifications()
        setupBackButton()
    }
    
    private func setupBackButton() {
            let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(named: "iconArrowWTailBack"), for: .normal)
            backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
            
            let backBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = backBarButtonItem
        }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notification"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBack))
        navigationItem.leftBarButtonItem = backButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func didTapBack() {
                navigationController?.popViewController(animated: true)
        }
    
    private func fetchNotifications() {
        NotificationManager.shared.fetchNotifications { [weak self] result in
            switch result {
            case .success(let messages):
                DispatchQueue.main.async {
                    self?.notifications = messages
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch notifications: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }
        let notification = notifications[indexPath.row]
        cell.configure(with: notification)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
