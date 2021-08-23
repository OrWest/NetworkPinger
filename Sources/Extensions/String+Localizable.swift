//
//  String+Localizable.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/31/21.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
