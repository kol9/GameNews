//
//  SettingsViewController.swift
//  GameNews
//
//  Created by Nikolay Yarlychenko on 03.04.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    static var closure: (()->(Void))?
    
    public static var prefferedGames: [Int: String] = [
        570: "Dota 2",
        440: "Team Fortress",
        730: "Counter-Strike: Global Offensive",
        620: "Portal 2",
        10: "Counter-Strike",
        70: "Half-Life",
        220: "Half-Life 2",
        240: "Counter-Strike: Source",
        9050: "Doom 3",
        17390: "Spore",
        220240: "Far Cry 3",
        43110: "Metro 2033",
        298110: "Far Cry 4",
        20510: "S.T.A.L.K.E.R.: Clear Sky",
        41700: "S.T.A.L.K.E.R.: Call of Pripyat",
        4500: "S.T.A.L.K.E.R.: Shadow of Chernobyl",
        782330: "DOOM Eternal",
        397540: "Borderlands 3",
        546560: "Half-Life: Alyx",
        578080: "PLAYERUNKNOWN'S BATTLEGROUNDS",
        381210: "Dead by Daylight",
        221100: "DayZ",
        32500: "STAR WARS™: The Force Unleashed™ II",
        1172380: "STAR WARS Jedi: Fallen Order™",
        2270: "Wolfenstein 3D",
        1056960: "Wolfenstein: Youngblood",
        612880: "Wolfenstein II: The New Colossus",
        250820: "SteamVR"
    ]
    func getNames()->[String] {
        return SettingsViewController.prefferedGames.values.sorted()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .white
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        SettingsViewController.self.closure!()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsViewController.prefferedGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell")
        cell?.textLabel?.text = getNames()[indexPath.row]
        let defaults = UserDefaults.standard
        let savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
        if savedArray.firstIndex(of: getNames()[indexPath.row]) != nil {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func addGame(str: String) {
        let defaults = UserDefaults.standard
        var savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
        savedArray.append(str)
        defaults.set(savedArray.sorted(), forKey: "SavedArray")
    }
    
    
    func removeGame(str: String) {
        let defaults = UserDefaults.standard
        var savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
        savedArray.remove(at: savedArray.firstIndex(of: str)!)
        defaults.set(savedArray.sorted(), forKey: "SavedArray")
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                removeGame(str: (cell.textLabel?.text)!)
                cell.accessoryType = .none
            } else {
                addGame(str: (cell.textLabel?.text)!)
                cell.accessoryType = .checkmark
            }
            
        }
    }
    
   
    
    
    
    
    
}
