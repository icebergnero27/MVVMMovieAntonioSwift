//
//  MovieDetailViewViewModel.swift
//  MovieInfo
//
//  Created by Innovez One on 10/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailViewViewModel {
    
    private let movieService: MovieService
    private let disposeBag = DisposeBag()
    
    init(movie: Driver<Movie>, movieService: MovieService) {
        self.movieService = movieService
        movie.drive(onNext: { [weak self] (movie) in
            self?._movie.accept(movie)
            self?.searchVideo(movie: movie)
            self?.searchReviews(movie: movie)
        }).disposed(by: disposeBag)
    }
    
    private let _movie = BehaviorRelay<Movie?>(value:nil)
    private let _reviews = BehaviorRelay<[MovieReview]>(value: [])
    private let _videos = BehaviorRelay<[MovieVideo]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)
    private let _pages = BehaviorRelay<Int>(value: 0)
    private let _totalPages = BehaviorRelay<Int>(value: 0)
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var reviews: Driver<[MovieReview]> {
        return _reviews.asDriver()
    }
    
    var videos: Driver<[MovieVideo]> {
        return _videos.asDriver()
    }
    
    var info: Driver<String?> {
        return _info.asDriver()
    }
    
    var hasInfo: Bool {
        return _info.value != nil
    }
    
    var numberOfReviews: Int {
        return _reviews.value.count
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
    
    var youtubeKey: String?{
        if let trailer = _videos.value.first {
            if trailer.site == "YouTube" {
                return trailer.key
            }
        }
        return nil
    }
    
    func viewModelForMovie(at index: Int) -> MovieReview? {
        guard index < _reviews.value.count else {
            return nil
        }
        return _reviews.value[index]
    }
    
    private func searchVideo(movie: Movie) {
        movieService.getMovieVideo(id: String(movie.id), successHandler: {[weak self] (response) in
            self?._videos.accept(response.results)
        }) {(error) in
        }
    }
    
    private func searchReviews(movie: Movie) {
        self._reviews.accept([])
        self._isFetching.accept(true)
        self._info.accept(nil)
        let id = String(self._movie.value?.id ?? 0)
        let param = ["page": "1"]
        
        movieService.getMovieReview(id: id, params: param , successHandler: {[weak self] (response) in
            
            self?._isFetching.accept(false)
            self?._pages.accept(response.page)
            self?._totalPages.accept(response.totalPages)
            if response.totalResults == 0 {
                self?._info.accept("No reviews yet")
            }
            self?._reviews.accept(Array(response.results))
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._info.accept(error.localizedDescription)
        }
    }
    
    public func checkInfiniteScroll(_ index: IndexPath){
        if(index.section == 1){
            if (index.row >= (numberOfReviews - 1) && pages < totalPages){
                addReview()
            }
        }
    }
    
    private func addReview() {
        self._isFetching.accept(true)
        let param = ["page": String(self.nextPages)]
        let id = String(self._movie.value?.id ?? 0)
        
        movieService.getMovieReview(id: id, params: param, successHandler: {[weak self] (response) in
            
            self?._isFetching.accept(false)
            self?._pages.accept(response.page)
            self?._totalPages.accept(response.totalPages)
            self?._reviews.addArray(elements: Array(response.results))
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._info.accept(error.localizedDescription)
        }
    }
}
