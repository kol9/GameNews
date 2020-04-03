//
//  ViewController.swift
//  GameNews
//
//  Created by Nikolay Yarlychenko on 01.04.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}

class ViewController: UIViewController {
    var prefferedGames: [String] {
        let defaults = UserDefaults.standard
        let savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
        print(savedArray.sorted())
        return savedArray.sorted()
        
    }
    var prefferedGameOrder: [Int] {
        var ans: [Int] = []
        prefferedGames.forEach({s in
            ans.append(SettingsViewController.prefferedGames.key(forValue: s)!)
        })
        return ans
    }
    var data: [GameInfo] = []
    private let refreshControl = UIRefreshControl()
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    

    @objc func fetchNews() {
        
        DispatchQueue.global().async {
            var tmp = Array(repeating: GameInfo(appid: 730, newsitems: [NewsItem(title: "Loading...", url: URL(string: "steam")!, contents: "Loading...")]), count: self.prefferedGames.count)
            
            //            self.data = Array(repeating: GameInfo(appid: 730, newsitems: [NewsItem(title: "Loading...", url: URL(string: "steam")!, contents: "Loading...")]), count: prefferedGames.count)
            //
            
            
            if(tmp.isEmpty) {
                self.data = []
                DispatchQueue.main.async {
                    print("reloading data...")
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    
                }
            }
            let sem = DispatchSemaphore(value: 0)
            let sem2 = DispatchSemaphore(value: 1)
            var cnt = 0
            for (i, gameid) in self.prefferedGameOrder.enumerated() {
                guard let url = URL(string: "https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=\(gameid)&count=10&maxlength=100") else {
                    print("Error")
                    return
                }
                
                print("Fetch")
                let task = URLSession.shared.dataTask(with: url) {
                    (data, response, error) in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "Error")
                        return
                    }
                    guard let data = data else {
                        print("Error")
                        return
                    }
                    
                    guard let gamesInfo = try? JSONDecoder().decode(GamesInfo.self, from: data) else {
                        print("Error: parsing error")
                        return
                    }
                    sem2.wait()
                    cnt += 1
                    sem2.signal()
                    print(" \(i) is ready")
                    tmp[i] = gamesInfo.appnews
                    if(cnt == self.prefferedGames.count) {
                        sem.signal()
                    }
                }
                task.resume()
            }
            sem.wait()
            self.data = []
            self.data = tmp
            print("assigning")
            DispatchQueue.main.async {
                print("reloading data...")
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    override func loadView() {
        super.loadView()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchNews), for: .valueChanged)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        SettingsViewController.closure = {
            self.fetchNews()
            self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 133
        tableView.allowsSelection = false
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        refreshControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNews()
    }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .black
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.isEmpty {
            return 1
        } else {
            return data[section].newsitems.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if data.isEmpty {
            return nil
        } else {
            return SettingsViewController.prefferedGames[data[section].appid]
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !data.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! InfoCell
            cell.configureCell(data[indexPath.section].newsitems[indexPath.row].title, data[indexPath.section].newsitems[indexPath.row].contents,
                               data[indexPath.section].newsitems[indexPath.row].url.absoluteString)
            cell.closure = { url in
                
                let alertController = UIAlertController(title: "\(url)", message: "Open \(url) in Safari?", preferredStyle: .alert)
                
                let action1 = UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
                    
                    if UIApplication.shared.canOpenURL(URL(string: url)!) {
                        UIApplication.shared.open(URL(string : url)!, options: [:], completionHandler: nil)
                    } else {
                        let googleSearchURL =  "https://www.google.co.in/search?q=" + url
                        UIApplication.shared.open(URL(string: googleSearchURL)!, options: [:], completionHandler: {_ in
                            alertController.dismiss(animated: true, completion: nil)
                        })
                    }
                    
                })
                
                let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)
                
                alertController.addAction(action1)
                alertController.addAction(action2)
                self.present(alertController, animated: true, completion: nil)
            }
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Select in the Settings games for which you want to receive news"
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
            cell.heightAnchor.constraint(equalToConstant: 60).isActive = true
            return cell
        }
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if data.isEmpty {
            return 1
        } else {
            return data.count
        }
    }
    
    
}


