//
//  DetailViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 17/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var pickedStatusesHome: [Status] = []
    var allPrevious: [Status] = []
    var allReplies: [Status] = []
    let detailPrev = UIButton()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Table
        let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Detail".localized
        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "arrow.up.arrow.down", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.sortTapped), for: .touchUpInside)
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        
        // Table
        self.tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
        self.tableView.register(DetailImageCell.self, forCellReuseIdentifier: "DetailImageCell")
        self.tableView.register(DetailActionsCell.self, forCellReuseIdentifier: "DetailActionsCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "PrevCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "PrevImageCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "RepliesCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "RepliesImageCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        self.detailPrev.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.detailPrev.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.detailPrev.backgroundColor = UIColor(named: "baseWhite")
        self.detailPrev.layer.cornerRadius = 19
        self.detailPrev.alpha = 0
        self.detailPrev.addTarget(self, action: #selector(self.didTouchDetailPrev), for: .touchUpInside)
        self.view.addSubview(self.detailPrev)
        
        self.fetchReplies()
    }
    
    func fetchReplies() {
        let request = Statuses.context(id: self.pickedStatusesHome[0].id)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.allPrevious = (stat.ancestors)
                    self.allReplies = (stat.descendants)
                    self.tableView.reloadData()
                    if self.allPrevious.count == 0 {} else {
                        self.detailPrev.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            self.detailPrev.alpha = 1
                            self.detailPrev.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        var zCount = 0
                        var zHeights: CGFloat = 0
                        for _ in self.allReplies {
                            zHeights = CGFloat(zHeights) + CGFloat(self.tableView.rectForRow(at: IndexPath(row: zCount, section: 3)).height)
                            zCount += 1
                        }
                        let footerHe0 = self.tableView.bounds.height - self.tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - self.tableView.rectForRow(at: IndexPath(row: 0, section: 2)).height
                        var footerHe = footerHe0 - zHeights
                        if footerHe < 0 {
                            footerHe = 0
                        }
                        let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHe))
                        self.tableView.tableFooterView = customViewFooter
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                    }
                }
            }
        }
    }
    
    @objc func didTouchDetailPrev() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.detailPrev.alpha = 0
            self.detailPrev.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.detailPrev.alpha = 0
            self.detailPrev.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    @objc func sortTapped() {
        
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allPrevious.count
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        } else {
            return self.allReplies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if self.allPrevious[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevCell", for: indexPath) as! TootCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevImageCell", for: indexPath) as! TootImageCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else if indexPath.section == 1 {
            if self.pickedStatusesHome[0].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                if self.pickedStatusesHome.isEmpty {} else {
                    cell.configure(self.pickedStatusesHome[0])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailImageCell", for: indexPath) as! DetailImageCell
                if self.pickedStatusesHome.isEmpty {} else {
                    cell.configure(self.pickedStatusesHome[0])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActionsCell", for: indexPath) as! DetailActionsCell
            if self.pickedStatusesHome.isEmpty {} else {
                cell.configure(self.pickedStatusesHome[0])
            }
            cell.button1.addTarget(self, action: #selector(self.replyTapped), for: .touchUpInside)
            cell.backgroundColor = UIColor(named: "baseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            if self.allReplies[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepliesCell", for: indexPath) as! TootCell
                if self.allReplies.isEmpty {} else {
                    cell.configure(self.allReplies[indexPath.row])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepliesImageCell", for: indexPath) as! TootImageCell
                if self.allReplies.isEmpty {} else {
                    cell.configure(self.allReplies[indexPath.row])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        }
    }
    
    @objc func replyTapped() {
        let vc = TootViewController()
        vc.replyStatus = self.pickedStatusesHome
        self.show(UINavigationController(rootViewController: vc), sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.allPrevious[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            
        } else {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.allReplies[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
