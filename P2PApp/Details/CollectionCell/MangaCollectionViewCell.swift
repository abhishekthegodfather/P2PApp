//
//  MnagaImagesCollectionViewCell.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 03/10/23.
//

import UIKit

class MangaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageManga: UIImageView!
    
    static let cellID = "MangaCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "MangaCollectionViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
