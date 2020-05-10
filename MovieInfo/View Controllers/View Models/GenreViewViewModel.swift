//
//  GenreViewViewModel.swift
//  MovieInfo
//
//  Created by Innovez One on 09/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import Foundation


struct GenreViewViewModel {

    private var _genre: MovieGenre

    init(genre : MovieGenre) {
        self._genre = genre
    }
    
    var id: Int {
        return _genre.id
    }
    
    var name: String {
        return _genre.name
    }
    
    var genre: MovieGenre{
        return _genre
    }
}
