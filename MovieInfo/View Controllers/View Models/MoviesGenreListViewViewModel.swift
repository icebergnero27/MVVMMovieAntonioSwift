//
//  MovieGenreListViewController.swift
//  MovieInfo
//
//  Created by Innovez One on 09/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieGenreListViewViewModel {
    
    private let movieService: MovieService
    private let disposeBag = DisposeBag()
    
    init(genre: Driver<MovieGenre>, movieService: MovieService) {
        self.movieService = movieService
        genre.drive(onNext: { [weak self] (genre) in
            self?.searchMovie(genre: genre)
            self?._genre.accept(genre)
        }).disposed(by: disposeBag)
    }
    
    private let _genre = BehaviorRelay<MovieGenre?>(value:nil)
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)
    private let _pages = BehaviorRelay<Int>(value: 0)
    private let _totalPages = BehaviorRelay<Int>(value: 0)
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    
    var info: Driver<String?> {
        return _info.asDriver()
    }
    
    var hasInfo: Bool {
        return _info.value != nil
    }
    
    var numberOfMovies: Int {
        return _movies.value.count
    }
    
    var pages: Int {
        return _pages.value
    }
    
    var nextPages: Int {
        return _pages.value + 1
    }
    
    var totalPages: Int {
        return _totalPages.value
    }
    
    var genreID: Int{
        return _genre.value?.id ?? 0
    }
    
    var genreName: String{
        return _genre.value?.name ?? ""
    }
    
    func viewModelForMovie(at index: Int) -> MovieViewViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        return MovieViewViewModel(movie: _movies.value[index])
    }
    
    private func searchMovie(genre: MovieGenre?) {
        guard let genre = genre else {
            return
        }
        
        self._movies.accept([])
        self._isFetching.accept(true)
        self._info.accept(nil)
        let param = ["with_genres" : String(genre.id)]
        
        movieService.discoverMovie(params: param, successHandler: {[weak self] (response) in
            
            self?._isFetching.accept(false)
            self?._pages.accept(response.page)
            self?._totalPages.accept(response.totalPages)
            if response.totalResults == 0 {
                self?._info.accept("No result for \(genre.name)")
            }
            self?._movies.accept(Array(response.results))
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._info.accept(error.localizedDescription)
        }
    }
    
    public func checkInfiniteScroll(_ row: Int){
        if (row >= (numberOfMovies - 3) && pages < totalPages){
            addMovie()
        }
    }
    
    private func addMovie() {
        self._isFetching.accept(true)
        let param = ["with_genres" : String(self.genreID),
                     "page": String(self.nextPages)]
        
        movieService.discoverMovie(params: param, successHandler: {[weak self] (response) in
            
            self?._isFetching.accept(false)
            self?._pages.accept(response.page)
            self?._totalPages.accept(response.totalPages)
            if response.totalResults == 0 {
                self?._info.accept("No result for \(self?.genreName ?? "")")
            }
            self?._movies.addArray(elements: Array(response.results))
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._info.accept(error.localizedDescription)
        }
    }
}
