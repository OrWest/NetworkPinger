//
//  NetworkTableDataSource.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/30/21.
//

import UIKit

class NetworkTableDataSource: NSObject {
    
    var models: [NetworkCellModel] = []
    
    func configure(tableView: UITableView) {
        tableView.dataSource = self
        tableView.register(HostReachabilityCell.nib, forCellReuseIdentifier: HostReachabilityCell.reuseIdentifier)
        
        tableView.tableFooterView = UIView()
    }
    
    func setEmptyState(tableView: UITableView) {
        tableView.backgroundView = getEmptyStateLabel()
    }
    
    func removeEmptyState(tableView: UITableView) {
        tableView.backgroundView = nil
    }
    
    private func getEmptyStateLabel() -> UILabel {
        let attributedString = NSMutableAttributedString(string: "networkDiscover.emptyState".localized)
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "play.circle")
        let imageAttributedString = NSAttributedString(attachment: imageAttachment)
        let range = (attributedString.string as NSString).range(of: "{play}")
        if range.location != NSNotFound {
            attributedString.replaceCharacters(in: range, with: imageAttributedString)
        }
        
        let label = UILabel()
        label.attributedText = attributedString
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }
}

extension NetworkTableDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HostReachabilityCell.reuseIdentifier, for: indexPath)
        
        if let hostCell = cell as? HostReachabilityCell {
            let model = models[indexPath.row]
            hostCell.hostLabel.text = model.ip
            hostCell.statusImageView.image = model.reachabilityImage
            hostCell.statusImageView.tintColor = model.tintColor
            
            hostCell.activityIndicatorView.isHidden = model.reachabilityImage != nil
        }
        
        return cell
    }
}
