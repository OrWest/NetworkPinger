//
//  HostReachabilityCell.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/30/21.
//

import UIKit

class HostReachabilityCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityIndicatorView.startAnimating()
    }
}
