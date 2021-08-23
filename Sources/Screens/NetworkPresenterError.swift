//
//  NetworkPresenterError.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/31/21.
//

import Foundation

enum NetworkPresenterError {
    case noNetworkAddress
    
    var title: String {
        switch self {
        case .noNetworkAddress:
            return "networkDiscover.error.noNetworkAddress.title".localized
        }
    }
    
    var message: String {
        switch self {
        case .noNetworkAddress:
            return "networkDiscover.error.noNetworkAddress.message".localized
        }
    }
}
