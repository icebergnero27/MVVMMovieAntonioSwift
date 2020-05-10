//
//  MovieReviewCell.swift
//  MovieInfo
//
//  Created by Innovez One on 11/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import UIKit

class MovieReviewCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var content: UILabel!
    
    func configure(modelView: MovieReview) {
        name.text = modelView.author
        content.text = modelView.content
    }
}
