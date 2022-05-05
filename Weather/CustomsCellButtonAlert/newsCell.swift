//
//  newsCell.swift
//  Weather
//
//  Created by Илья Синицын on 24.03.2022.
//

import UIKit

class newsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resourceLabel: UILabel!
    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var authorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        cell.layer.cornerRadius = 25
        authorImageView.layer.cornerRadius = 15
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        authorImageView.image = nil
    }
}
