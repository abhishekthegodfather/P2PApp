//
//  AnimeEpisodeCell.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 03/10/23.
//

import UIKit

class AnimeEpisodeCell: UITableViewCell {

    @IBOutlet weak var episodeLabel: UILabel!
    
    static let cellId = "AnimeEpisodeCell"
    static func nib() -> UINib{
        return UINib(nibName: "AnimeEpisodeCell", bundle: nil)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
