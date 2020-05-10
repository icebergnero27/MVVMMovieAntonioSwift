//
//  MovieDetail.swift
//  MovieInfo
//
//  Created by Innovez One on 10/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import UIKit
import YouTubePlayer
import RxCocoa
import RxSwift

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var movieDetailViewViewModel: MovieDetailViewViewModel!
    let disposeBag = DisposeBag()
    var movie: Movie!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movieRelay = BehaviorRelay<Movie>(value: movie)
        movieDetailViewViewModel = MovieDetailViewViewModel(movie: movieRelay.asDriver(), movieService: MovieStore.shared)
        self.title = "\(movie.title)"
        
        movieDetailViewViewModel.videos.drive(onNext: {[unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        movieDetailViewViewModel.reviews.drive(onNext: {[unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        movieDetailViewViewModel.isFetching.drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    
        movieDetailViewViewModel.info.drive(onNext: {[unowned self] (info) in
            self.infoLabel.isHidden = !self.movieDetailViewViewModel.hasInfo
            self.infoLabel.text = info
        }).disposed(by: disposeBag)
        
        tableView.rx
            .willDisplayCell.asDriver()
             .drive(onNext: { [unowned self] cell, indexPath in
                self.movieDetailViewViewModel.checkInfiniteScroll(indexPath)
                })
        .disposed(by: disposeBag)

        self.setupTableView()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(UINib(nibName: "MovieYoutubeCell", bundle: nil), forCellReuseIdentifier: "MovieYoutubeCell")
        tableView.register(UINib(nibName: "MovieReviewCell", bundle: nil), forCellReuseIdentifier: "MovieReviewCell")
    }
    
}

extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            if movieDetailViewViewModel.youtubeKey != nil{
                return 1
            }else{
                return 0
            }
        }else if (section == 1){
            return movieDetailViewViewModel.numberOfReviews
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieYoutubeCell", for: indexPath) as! MovieYoutubeCell
                cell.configure(key: movieDetailViewViewModel.youtubeKey)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieReviewCell", for: indexPath) as! MovieReviewCell
            if let viewModel = movieDetailViewViewModel.viewModelForMovie(at: indexPath.row) {
                cell.configure(modelView: viewModel)
            }
            return cell
        }
    }
        
}

