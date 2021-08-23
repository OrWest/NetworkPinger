//
//  ReusableCell.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/30/21.
//

import UIKit

protocol ReusableCell: UITableViewCell {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension ReusableCell {
    static var reuseIdentifier: String { String(describing: self) }
    static var nib: UINib? { UINib(nibName: String(describing: self), bundle: nil) }
}
