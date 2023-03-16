//
//  TableViewCell.swift
//  GetContacts
//
//  Created by Apple iMac on 15/3/23.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUPUI()
    }
    
    private func setUPUI() {
        profileImage.setRounded()
        contactView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}

extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}
