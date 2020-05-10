//
//  GenreListViewViewModel.swift
//  MovieInfo
//
//  Created by Innovez One on 09/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GenreListViewViewModel {
    
    private let movieService: MovieService
    private let disposeBag = DisposeBag()
    
    init(movieService: MovieService) {
        self.movieService = movieService
        self.fetchGenre()
    }
    
    private let _genre = BehaviorRelay<[MovieGenre]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _error = BehaviorRelay<String?>(value: nil)
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var genres: Driver<[MovieGenre]> {
        return _genre.asDriver()
    }
    
    var error: Driver<String?> {
        return _error.asDriver()
    }
    
    var hasError: Bool {
        return _error.value != nil
    }
    
    var numberOfGenres: Int {
        return _genre.value.count
    }
    
    func viewModelForGenre(at index: Int) -> GenreViewViewModel? {
        guard index < _genre.value.count else {
            return nil
        }
        return GenreViewViewModel(genre: _genre.value[index])
    }
    
    private func fetchGenre() {
        self._genre.accept([])
        self._isFetching.accept(true)
        self._error.accept(nil)
        
        movieService.fetchGenres(successHandler: {[weak self] (response) in
            self?._isFetching.accept(false)
            self?._genre.accept(response.genres)
            
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._error.accept(error.localizedDescription)
        }
    }

}
