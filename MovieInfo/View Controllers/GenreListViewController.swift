//
//  GenreListViewController.swift
//  MovieInfo
//
//  Created by Innovez One on 09/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class GenreListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var genreListViewViewModel: GenreListViewViewModel!
    let disposeBag = DisposeBag()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genreListViewViewModel = GenreListViewViewModel(movieService: MovieStore.shared)
        
        genreListViewViewModel.genres.drive(onNext: {[unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        genreListViewViewModel.isFetching.drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        genreListViewViewModel.error.drive(onNext: {[unowned self] (error) in
            self.infoLabel.isHidden = !self.genreListViewViewModel.hasError
            self.infoLabel.text = error
        }).disposed(by: disposeBag)
        
        setupTableView()
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
    }
    
}

extension GenreListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genreListViewViewModel.numberOfGenres
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        if let viewModel = genreListViewViewModel.viewModelForGenre(at: indexPath.row) {
            cell.textLabel?.text = viewModel.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = genreListViewViewModel.viewModelForGenre(at: indexPath.row) {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "movieGenreListViewController") as! MovieGenreListViewController
            vc.movieGenre = viewModel.genre
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
