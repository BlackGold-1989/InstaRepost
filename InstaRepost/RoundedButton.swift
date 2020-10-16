//
//  RoundedButton.swift
//  InstaRepost
//
//  Created by Jamie Nguyen on 9/18/17.
//  Copyright © 2017 FPT. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.clipsToBounds = true;
        self.layer.cornerRadius = 5;
    }
}
