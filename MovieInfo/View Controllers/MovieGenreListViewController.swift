//
//  MovieGenreListViewController.swift
//  MovieInfo
//
//  Created by Innovez One on 09/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MovieGenreListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var movieGenreListViewViewModel: MovieGenreListViewViewModel!
    let disposeBag = DisposeBag()
    var movieGenre: MovieGenre!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let genreRelay = BehaviorRelay<MovieGenre>(value: movieGenre!)
        movieGenreListViewViewModel = MovieGenreListViewViewModel(genre: genreRelay.asDriver(), movieService: MovieStore.shared)
        self.title = movieGenre?.name
        
        movieGenreListViewViewModel.movies.drive(onNext: {[unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        movieGenreListViewViewModel.isFetching.drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    
        movieGenreListViewViewModel.info.drive(onNext: {[unowned self] (info) in
            self.infoLabel.isHidden = !self.movieGenreListViewViewModel.hasInfo
            self.infoLabel.text = info
        }).disposed(by: disposeBag)
        
        tableView.rx
            .willDisplayCell.asDriver()
             .drive(onNext: { [unowned self] cell, indexPath in
                self.movieGenreListViewViewModel.checkInfiniteScroll(indexPath.row)
                })
        .disposed(by: disposeBag)

        self.setupTableView()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
    
}

extension MovieGenreListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieGenreListViewViewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        if let viewModel = movieGenreListViewViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = movieGenreListViewViewModel.viewModelForMovie(at: indexPath.row) {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "movieDetailViewController") as! MovieDetailViewController
            vc.movie = viewModel.getMovie()
            self.navigationController?.pushViewController(vc, animated: true)
         }
    }
        
}

