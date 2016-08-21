//
//  AddBtns.swift
//  PokeFinder
//
//  Created by Meagan McDonald on 8/20/16.
//  Copyright © 2016 Skyla Apps. All rights reserved.
//

import UIKit

class AddBtns: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setTitleColor(self.titleColor(for: .normal)?.withAlphaComponent(0.5), for: .disabled)
        
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }

}
