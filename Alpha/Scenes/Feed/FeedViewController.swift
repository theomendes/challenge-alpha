//
//  MainViewController.swift
//  Alpha
//
//  Created by Theo Mendes on 14/10/19.
//  Copyright © 2019 Hurb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class FeedViewController: BaseViewController {
    let disposeBag = DisposeBag()
    let headerRefreshTrigger = PublishSubject<Void>()

    internal lazy var dataSource: RxTableViewSectionedReloadDataSource<FeedSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<FeedSection>(configureCell: { (_, tableView, indexPath, feedSection) -> UITableViewCell in
            switch feedSection {
            case .Star(let hotels):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: feedSection.identifier)
                as? StarTableViewCell else { fatalError("Unknown identifier") }
                cell.currentDataSource = HotelsDataSource(with: hotels)
                return cell
            case .Package(let packages):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: feedSection.identifier)
                as? PackageTableViewCell else { fatalError("Unknown identifier") }
                cell.currentDataSource = PackageDataSource(with: packages)
                return cell
            }
        })

        return dataSource
    }()

    internal var feedTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.register(StarTableViewCell.self, forCellReuseIdentifier: Identifiers.Star.rawValue)
        view.register(PackageTableViewCell.self, forCellReuseIdentifier: Identifiers.Package.rawValue)
        view.register(StarTableViewHeader.self, forHeaderFooterViewReuseIdentifier: Identifiers.FeedSection.rawValue)
        view.tableFooterView = UIView(frame: .zero)
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = false
        view.rowHeight = UITableView.automaticDimension
        view.sectionHeaderHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 140.0
        view.estimatedSectionHeaderHeight = 55.0
        view.layoutMargins = .zero
        return view
    }()

    internal var loadingView: LoadingUIView = {
        let view = LoadingUIView(frame: .zero)
        view.isHidden = false
        view.backgroundColor = .white
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupUI() {
        self.view.backgroundColor = .white

        feedTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.view.addSubview(feedTableView)
        self.view.addSubview(loadingView)
    }

    override func bindViewModel() {
        guard let viewModel = viewModel as? FeedViewModel else { return }

        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = FeedViewModel.Input(headerRefresh: refresh)

        let output = viewModel.transform(input: input)

        output.isLoading.subscribe(onNext: { event in
            if !event {
                self.loadingView.isHidden = true
            } else {
                self.loadingView.isHidden = false
            }
            }).disposed(by: disposeBag)

        output.feed.asDriver(onErrorJustReturn: [])
            .drive(feedTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    override func setupConstraints() {
        super.setupConstraints()

        feedTableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailingMargin)
        }
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        activity.snp.makeConstraints { (make) in
//            make.centerX.centerY.equalTo(loadingView)
//        }
//        loadingLabel.snp.makeConstraints { (make) in
//            make.centerX.equalTo(activity.snp.centerX)
//            make.top.equalTo(activity.snp.top).offset(20)
//        }
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: Identifiers.FeedSection.rawValue)
            as? StarTableViewHeader else { return nil }

        view.titleLabel.text = dataSource.sectionModels[section].header
        view.subTitle.text = dataSource.sectionModels[section].subTitle

        return view
    }
    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 55.0
    }
}