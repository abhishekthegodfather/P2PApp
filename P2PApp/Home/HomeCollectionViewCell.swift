//
//  HomeCollectionViewCell.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageAnimePreview: UIImageView!
    @IBOutlet weak var animeName: UILabel!
    
    
    static let cellID = "HomeCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "HomeCollectionViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
