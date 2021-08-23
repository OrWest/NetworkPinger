//
//  NetworkVC.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/30/21.
//

import UIKit

struct NetworkCellModel {
    let ip: String
    let reachabilityImage: UIImage?
    let tintColor: UIColor?
}

class NetworkVC: UIViewController {
    var presenter = NetworkPresenter()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource = NetworkTableDataSource()
    
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var playBarItem = UIBarButtonItem(image: UIImage(systemName: "play.circle"), style: .plain, target: self, action: #selector(playAction(_:)))
    private lazy var stopBarItem = UIBarButtonItem(image: UIImage(systemName: "stop.circle"), style: .plain, target: self, action: #selector(stopAction(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        dataSource.configure(tableView: tableView)
        dataSource.setEmptyState(tableView: tableView)
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        let leftBarItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = playBarItem
    }
    
    @IBAction func sortingControlAction(_ sender: UISegmentedControl) {
        let sorting: NetworkPresenter.SortType
        if sender.selectedSegmentIndex == 0 {
            sorting = .ip
        } else {
            sorting = .reachability
        }
        presenter.sortingUpdated(sorting)
    }
    
    @objc
    private func playAction(_ sender: UIBarButtonItem) {
        dataSource.removeEmptyState(tableView: tableView)

        presenter.launchDiscover()
    }
    
    @objc
    private func stopAction(_ sender: UIBarButtonItem) {
        presenter.stopDiscover()
    }
    
    private func setModelsToDataSource(addresses: [NetworkAddressInfo], showActivityIndicator: Bool) {
        var models: [NetworkCellModel] = []
        
        for address in addresses {
            let image: UIImage?
            let tintColor: UIColor?
            switch address.reachability {
            case .undefined:
                if showActivityIndicator {
                    image = nil
                    tintColor = nil
                } else {
                    image = UIImage(systemName: "questionmark.diamond.fill")
                    tintColor = .gray
                }
            case .reachable:
                image = UIImage(systemName: "checkmark.circle.fill")
                tintColor = .green
            case .unreachable:
                image = UIImage(systemName: "xmark.circle.fill")
                tintColor = .red
            }
                        
            models.append(NetworkCellModel(ip: address.ip.humanReadableString, reachabilityImage: image, tintColor: tintColor))
        }
        
        dataSource.models = models
        tableView.reloadData()
    }
}

extension NetworkVC: NetworkView {
    func discoverStateUpdated(_ state: NetworkPresenter.DiscoverState) {
        switch state {
        case .standby:
            activityIndicator.stopAnimating()
            navigationItem.rightBarButtonItem = playBarItem
        case .inProgress:
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItem = stopBarItem
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "alert.ok".localized, style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
    
    func updateData(addresses: [NetworkAddressInfo], pingInProgress: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.setModelsToDataSource(addresses: addresses, showActivityIndicator: pingInProgress)
        }
    }
}
