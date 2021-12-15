//
//  SearchPhotoTableViewCell.swift
//  FlickrFindr
//
//  Created by Dominick Hera on 12/15/21.
//

import UIKit

class SearchPhotoTableViewCell: UITableViewCell
{

    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultImageTitleLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse()
    {
        resultImageView.image = nil
        resultImageTitleLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
