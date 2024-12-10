//
//  InterviewV1_ClaraUITests.swift
//  InterviewV1_ClaraUITests
//
//  Created by 小妍寶 on 2024/12/9.
//

import Foundation
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    private let tableView = UITableView()
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView!
    private var favoriteCollectionView: UICollectionView!
    private let tabBarContainer = UIView()
    let pageControl = UIPageControl()
    let scrollView = UIScrollView()
    let accountManager = AccountManager()
    private var isAmountHidden = true
    private let collectionData = ["Transfer", "Payment", "Utility", "QR pay scan", "My QR code", "Top up"]
    private let tabBarItems = ["Home", "Account", "Location", "Service"]
    private var totalUSDBalance = Double()
    private var totalKHRBalance = Double()
    private let notificationViewController = NotificationViewController()
    private var notifications: [NotificationMessage] = []
    private var refreshControl = UIRefreshControl()
    private var autoScrollTimer: Timer?
    private var favoriteItems: [FavoriteItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        setupUI()
        setupRefreshControl()
        accountManager.fetchAndCalculateBalances(isRefresh: false) { [weak self] totalUSDBalance, totalKHRBalance in
            DispatchQueue.main.async {
                self?.totalUSDBalance = totalUSDBalance
                self?.totalKHRBalance = totalKHRBalance
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        tableView.backgroundColor = .systemGray6
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
        
        setupTableHeaderView()
        setupTableFooterView()
        setupCustomTabBar()
    }
    
    private func setupCustomTabBar() {
        let tabBarHeight: CGFloat = view.frame.height * 0.07
        let tabBarView = UIView()
        tabBarView.backgroundColor = .white
        tabBarView.layer.cornerRadius = view.frame.height * 0.035
        tabBarView.layer.shadowColor = UIColor.black.cgColor
        tabBarView.layer.shadowOpacity = 0.1
        tabBarView.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBarView.layer.shadowRadius = 5
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tabBarView.heightAnchor.constraint(equalToConstant: tabBarHeight)
        ])
        
        setupTabBarButtons(in: tabBarView)
    }
    
    private func setupTabBarButtons(in tabBarView: UIView) {
        let items = [("Home", "icTabbarHomeActive"),
                     ("Account", "icTabbarAccountDefault"),
                     ("Location", "icTabbarLocationActive"),
                     ("Service", "people")]
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor)
        ])
        
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: item.1)
            imageView.contentMode = .scaleAspectFill
            imageView.tintColor = index == 0 ? .orange : .gray
            imageView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: button.topAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            let titleLabel = UILabel()
            titleLabel.text = item.0
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = index == 0 ? .orange : .gray
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4)
            ])
            
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func tabBarButtonTapped(_ sender: UIButton) {
        for view in sender.superview?.subviews ?? [] {
            if let button = view as? UIButton {
                button.tintColor = .gray
                button.setTitleColor(.gray, for: .normal)
            }
        }
        sender.tintColor = .orange
        sender.setTitleColor(.orange, for: .normal)
        
        switch sender.tag {
        case 0:
            print("Home tapped")
        case 1:
            print("Account tapped")
        case 2:
            print("Location tapped")
        case 3:
            print("Service tapped")
        default:
            break
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshBalances), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshBalances() {
        fetchNotifications()
        fetchFavoriteList()
        accountManager.fetchAndCalculateBalances(isRefresh: true) { [weak self] totalUSDBalance, totalKHRBalance in
            DispatchQueue.main.async {
                self?.updateNotificationBadge()
                self?.totalUSDBalance = totalUSDBalance
                self?.totalKHRBalance = totalKHRBalance
                self?.updateBalanceDisplay()
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            let numberOfItemsPerRow: CGFloat = 3
            let spacing: CGFloat = 16
            let cellWidth = (tableView.frame.width - (numberOfItemsPerRow - 1) * spacing) / numberOfItemsPerRow
            let cellHeight = cellWidth * 0.85
            let rows = ceil(CGFloat(collectionData.count) / numberOfItemsPerRow)
            let totalHeight = rows * cellHeight + (rows - 1) * spacing
            return totalHeight
        } else if indexPath.section == 1 && indexPath.row == 1 {
            
            return 110
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .systemGray6
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let headerView = UIView()
                let accountLabel = UILabel()
                accountLabel.text = "My Account Balance"
                accountLabel.font = UIFont.boldSystemFont(ofSize: 18)
                accountLabel.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview(accountLabel)
                
                let eyeIconButton = UIButton()
                let imageName = isAmountHidden ? "iconEye02Off" : "iconEye01On"
                eyeIconButton.setImage(UIImage(named: imageName), for: .normal)
                eyeIconButton.tintColor = .orange
                eyeIconButton.addTarget(self, action: #selector(toggleAmountVisibility), for: .touchUpInside)
                eyeIconButton.translatesAutoresizingMaskIntoConstraints = false
                eyeIconButton.tag = 1002
                headerView.addSubview(eyeIconButton)
                
                cell.contentView.addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    headerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    headerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    
                    accountLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
                    accountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                    
                    eyeIconButton.centerYAnchor.constraint(equalTo: accountLabel.centerYAnchor),
                    eyeIconButton.leadingAnchor.constraint(equalTo: accountLabel.trailingAnchor, constant: 8),
                    eyeIconButton.widthAnchor.constraint(equalToConstant: 20),
                    eyeIconButton.heightAnchor.constraint(equalToConstant: 20),
                ])
            } else if indexPath.row == 1 {
                let accountBalanceView = createAccountBalanceSection()
                cell.contentView.addSubview(accountBalanceView)
                accountBalanceView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    accountBalanceView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    accountBalanceView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    accountBalanceView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    accountBalanceView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
            } else if indexPath.row == 2 {
                setupCollectionView(in: cell.contentView)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let favoriteLabel = UILabel()
                favoriteLabel.text = "My Favorite"
                favoriteLabel.font = UIFont.boldSystemFont(ofSize: 18)
                favoriteLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(favoriteLabel)
                
                let moreLabel = UILabel()
                moreLabel.text = "More"
                moreLabel.font = UIFont.systemFont(ofSize: 16)
                moreLabel.textColor = .gray
                moreLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(moreLabel)
                
                let moreIconButton = UIButton()
                moreIconButton.setImage(UIImage(named: "iconArrow01Next"), for: .normal)
                moreIconButton.tintColor = .gray
                moreIconButton.translatesAutoresizingMaskIntoConstraints = false
                moreIconButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
                cell.contentView.addSubview(moreIconButton)
                
                NSLayoutConstraint.activate([
                    favoriteLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
                    favoriteLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    
                    moreLabel.centerYAnchor.constraint(equalTo: favoriteLabel.centerYAnchor),
                    moreLabel.trailingAnchor.constraint(equalTo: moreIconButton.leadingAnchor, constant: -4),
                    
                    moreIconButton.centerYAnchor.constraint(equalTo: favoriteLabel.centerYAnchor),
                    moreIconButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    moreIconButton.widthAnchor.constraint(equalToConstant: 20),
                    moreIconButton.heightAnchor.constraint(equalToConstant: 20)
                ])
            } else if indexPath.row == 1 {
                if favoriteItems.isEmpty {
                    let placeholderIcon = UIImageView()
                    placeholderIcon.image = UIImage(named: "button00ElementScrollEmpty")
                    placeholderIcon.tintColor = .lightGray
                    placeholderIcon.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(placeholderIcon)
                    
                    let placeholderMessage = UILabel()
                    placeholderMessage.text = "You can add a favorite through the transfer or payment function."
                    placeholderMessage.font = UIFont.systemFont(ofSize: 14)
                    placeholderMessage.textColor = .darkGray
                    placeholderMessage.numberOfLines = 0
                    placeholderMessage.textAlignment = .left
                    placeholderMessage.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(placeholderMessage)
                    
                    let dottedLineLabel = UILabel()
                    dottedLineLabel.text = "- - -"
                    dottedLineLabel.font = UIFont.systemFont(ofSize: 16)
                    dottedLineLabel.textColor = .lightGray
                    dottedLineLabel.textAlignment = .center
                    dottedLineLabel.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(dottedLineLabel)
                    
                    NSLayoutConstraint.activate([
                        
                        placeholderIcon.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                        placeholderIcon.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
                        placeholderIcon.widthAnchor.constraint(equalToConstant: 56),
                        placeholderIcon.heightAnchor.constraint(equalToConstant: 56),
                        
                        placeholderMessage.centerYAnchor.constraint(equalTo: placeholderIcon.centerYAnchor),
                        placeholderMessage.leadingAnchor.constraint(equalTo: placeholderIcon.trailingAnchor, constant: 16),
                        placeholderMessage.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                        
                        dottedLineLabel.topAnchor.constraint(equalTo: placeholderIcon.bottomAnchor),
                        dottedLineLabel.centerXAnchor.constraint(equalTo: placeholderIcon.centerXAnchor),
                        dottedLineLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16)
                    ])
                } else {
                    setupFavoriteCollectionView(in: cell.contentView)
                }
            }
        }
        return cell
    }
    
    private func iconName(for transType: String) -> String {
        switch transType {
        case "CUBC": return "button00ElementScrollTree"
        case "Mobile": return "button00ElementScrollMobile"
        case "PMF": return "button00ElementScrollBuilding"
        case "CreditCard": return "button00ElementScrollCreditCard"
        default: return ""
        }
    }
    
    private func setupFavoriteCollectionView(in containerView: UIView) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 4
        
        favoriteCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        favoriteCollectionView.backgroundColor = .clear
        favoriteCollectionView.showsHorizontalScrollIndicator = false
        favoriteCollectionView.delegate = self
        favoriteCollectionView.dataSource = self
        favoriteCollectionView.tag = 1
        favoriteCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "FavoriteCell")
        favoriteCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(favoriteCollectionView)
        NSLayoutConstraint.activate([
            favoriteCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            favoriteCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            favoriteCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            favoriteCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func setupCollectionView(in containerView: UIView) {
        collectionViewLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.tag = 0
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        collectionView.backgroundColor = .systemGray6
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
                
                return collectionData.count
            } else if collectionView.tag == 1 {
                
                return favoriteItems.count
            }
            return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            let imageView = UIImageView()
            let imageNames = [
                "button00ElementMenuTransfer",
                "button00ElementMenuPayment",
                "button00ElementMenuUtility",
                "button01Scan",
                "button00ElementMenuQRcode",
                "button00ElementMenuTopUp"
            ]
            imageView.image = UIImage(named: imageNames[indexPath.item])
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(imageView)
            
            let label = UILabel()
            label.text = collectionData[indexPath.item]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                imageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 50),
                imageView.heightAnchor.constraint(equalToConstant: 50),
                
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 4),
                label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -4),
                label.bottomAnchor.constraint(lessThanOrEqualTo: cell.contentView.bottomAnchor, constant: -8)
            ])
            
            cell.contentView.backgroundColor = .systemGray6
            return cell
        } else if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath)
                    for subview in cell.contentView.subviews {
                        subview.removeFromSuperview()
                    }

            let iconImageView = UIImageView()
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.image = UIImage(named: iconName(for: favoriteItems[indexPath.item].transType))
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(iconImageView)

                let nicknameLabel = UILabel()
                nicknameLabel.text = favoriteItems[indexPath.item].nickname
                nicknameLabel.font = UIFont.systemFont(ofSize: 12)
                nicknameLabel.textColor = .darkGray
                nicknameLabel.textAlignment = .center
                nicknameLabel.numberOfLines = 1
                nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(nicknameLabel)

                NSLayoutConstraint.activate([
                    iconImageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                    iconImageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    iconImageView.widthAnchor.constraint(equalToConstant: 50),
                    iconImageView.heightAnchor.constraint(equalToConstant: 50),

                    nicknameLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                    nicknameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
                    nicknameLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 4),
                    nicknameLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -4)
                ])

                return cell
                }
                return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let width = (collectionView.frame.width - 32) / 3
            return CGSize(width: width, height: width * 0.85)
        } else {
            let width = (collectionView.frame.width - 24) / 4
            return CGSize(width: width, height: width * 0.85)
        }
    }
    
    @objc private func didTapMoreButton() {
        print("More button tapped")
    }
    
    private func createAccountBalanceSection() -> UIView {
        let accountBalanceView = UIView()
        
        let usdLabel = UILabel()
        usdLabel.text = "USD"
        usdLabel.font = UIFont.systemFont(ofSize: 16)
        usdLabel.textColor = .darkGray
        usdLabel.tag = 2001
        usdLabel.translatesAutoresizingMaskIntoConstraints = false
        accountBalanceView.addSubview(usdLabel)
        
        let usdBalanceLabel = UILabel()
        usdBalanceLabel.text = isAmountHidden ? "********" : String(totalUSDBalance)
        usdBalanceLabel.font = UIFont.boldSystemFont(ofSize: 18)
        usdBalanceLabel.textColor = .black
        usdBalanceLabel.tag = 2002
        usdBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        accountBalanceView.addSubview(usdBalanceLabel)
        
        let khrLabel = UILabel()
        khrLabel.text = "KHR"
        khrLabel.font = UIFont.systemFont(ofSize: 16)
        khrLabel.textColor = .darkGray
        khrLabel.tag = 2003
        khrLabel.translatesAutoresizingMaskIntoConstraints = false
        accountBalanceView.addSubview(khrLabel)
        
        let khrBalanceLabel = UILabel()
        khrBalanceLabel.text = isAmountHidden ? "********" : String(totalKHRBalance)
        khrBalanceLabel.font = UIFont.boldSystemFont(ofSize: 18)
        khrBalanceLabel.textColor = .black
        khrBalanceLabel.tag = 2004
        khrBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        accountBalanceView.addSubview(khrBalanceLabel)
        
        NSLayoutConstraint.activate([
            usdLabel.topAnchor.constraint(equalTo: accountBalanceView.topAnchor, constant: 16),
            usdLabel.leadingAnchor.constraint(equalTo: accountBalanceView.leadingAnchor, constant: 16),
            
            usdBalanceLabel.topAnchor.constraint(equalTo: usdLabel.bottomAnchor, constant: 8),
            usdBalanceLabel.leadingAnchor.constraint(equalTo: usdLabel.leadingAnchor),
            usdBalanceLabel.trailingAnchor.constraint(equalTo: accountBalanceView.trailingAnchor, constant: -16),
            
            khrLabel.topAnchor.constraint(equalTo: usdBalanceLabel.bottomAnchor, constant: 16),
            khrLabel.leadingAnchor.constraint(equalTo: usdLabel.leadingAnchor),
            
            khrBalanceLabel.topAnchor.constraint(equalTo: khrLabel.bottomAnchor, constant: 8),
            khrBalanceLabel.leadingAnchor.constraint(equalTo: khrLabel.leadingAnchor),
            khrBalanceLabel.trailingAnchor.constraint(equalTo: usdBalanceLabel.trailingAnchor),
            
            accountBalanceView.bottomAnchor.constraint(equalTo: khrBalanceLabel.bottomAnchor, constant: 16)
        ])
        
        return accountBalanceView
    }
    
    @objc private func toggleAmountVisibility() {
        isAmountHidden.toggle()
        updateBalanceDisplay()
        
        if let eyeIconButton = self.view.viewWithTag(1002) as? UIButton {
            let imageName = isAmountHidden ? "iconEye02Off" : "iconEye01On"
            let tintColor: UIColor = .orange
            eyeIconButton.setImage(UIImage(named: imageName), for: .normal)
            eyeIconButton.tintColor = tintColor
        }
    }
    
    private func updateBalanceDisplay() {
        if let usdLabel = self.view.viewWithTag(2002) as? UILabel,
           let khrLabel = self.view.viewWithTag(2004) as? UILabel {
            usdLabel.text = isAmountHidden ? "********" : String(totalUSDBalance)
            khrLabel.text = isAmountHidden ? "********" : String(totalKHRBalance)
        }
    }
    
    private func setupTableHeaderView() {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .gray
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "avatar")
        profileImageView.tintColor = .gray
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(profileImageView)
        
        let notificationButton = UIButton()
        notificationButton.setImage(UIImage(named: "iconBell01Nomal"), for: .normal)
        notificationButton.tintColor = .black
        notificationButton.tag = 1001
        notificationButton.addTarget(self, action: #selector(pushToNotificationList), for: .touchUpInside)
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(notificationButton)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            notificationButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            notificationButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 30),
            notificationButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupTableFooterView() {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        footerView.backgroundColor = .systemGray6
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layer.cornerRadius = 10
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(scrollView)
        
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(pageControl)
        
        let scrollViewWidth = view.frame.width - 48
        let scrollViewHeight = view.frame.height * 0.1
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalToConstant: scrollViewWidth),
            scrollView.topAnchor.constraint(equalTo: footerView.topAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight),
            
            pageControl.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10)
        ])
        
        tableView.tableFooterView = footerView
        
        fetchBannerData()
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    @objc private func scrollToNextPage() {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        let nextPage = (currentPage + 1) % pageControl.numberOfPages
        let nextOffset = CGFloat(nextPage) * scrollView.frame.width
        
        scrollView.setContentOffset(CGPoint(x: nextOffset, y: 0), animated: true)
        pageControl.currentPage = nextPage
    }
    
    private func fetchBannerData() {
        NotificationManager.shared.fetchBannerData { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let banners):
                        self?.setupScrollViewContent(with: banners)
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
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
    
    private func fetchFavoriteList() {
        NotificationManager.shared.fetchFavoriteList { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let favoriteList):
                        self?.favoriteItems = favoriteList
                        self?.tableView.reloadData()
                        self?.refreshControl.endRefreshing()
                    case .failure(let error):
                        print("Error fetching favorite list: \(error.localizedDescription)")
                        self?.refreshControl.endRefreshing()
                    }
                }
            }
        }
    
    private func updateNotificationBadge() {
        guard let notificationButton = self.view.viewWithTag(1001) as? UIButton else {
            return
        }
        
        let hasUnreadNotifications = notifications.contains { !$0.status }
        
        let imageName = hasUnreadNotifications ? "iconBell02Active" : "iconBell01Nomal"
        let tintColor: UIColor = hasUnreadNotifications ? .red : .black
        notificationButton.setImage(UIImage(named: imageName), for: .normal)
        notificationButton.tintColor = tintColor
    }
    
    private func setupScrollViewContent(with banners: [Banner]) {
        let scrollViewWidth = view.frame.width - 48
        let scrollViewHeight = view.frame.height * 0.1
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(banners.count), height: scrollViewHeight)
        
        pageControl.numberOfPages = banners.count
        pageControl.currentPage = 0
        
        for (index, banner) in banners.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .lightGray
            
            scrollView.addSubview(imageView)
            
            let xPosition = scrollViewWidth * CGFloat(index)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            
            if let url = URL(string: banner.linkUrl) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data, let img = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        imageView.image = img
                    }
                }.resume()
            }
        }
    }
    
    @objc private func pushToNotificationList() {
        let notificationViewController = NotificationViewController()
        self.navigationController?.pushViewController(notificationViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.currentPage = page
        }
    }
}
