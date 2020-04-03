//
//  InfoCell.swift
//  GameNews
//
//  Created by Nikolay Yarlychenko on 02.04.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit


class InfoCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var safariButton: UIButton!
    var url: String?
    
    var closure: ((String)->Void)?
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        closure!(url!)
    }
    
    
    func configureCell(_ str1: String, _ str2: String, _ str3: String) {
        titleLabel.text = str1
        contentLabel.text = str2
        url = str3
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
}
