//
//  MovieYoutubeCell.swift
//  MovieInfo
//
//  Created by Innovez One on 10/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import UIKit
import YouTubePlayer

class MovieYoutubeCell: UITableViewCell {

    @IBOutlet var videoPlayer: YouTubePlayerView!
    
    func configure(key: String?) {
        if let key = key{
            videoPlayer.loadVideoID(key)
        }
    }
}
