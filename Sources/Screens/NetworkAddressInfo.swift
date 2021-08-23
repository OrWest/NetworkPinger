//
//  NetworkAddressInfo.swift
//  NetworkPinger
//
//  Created by Alex Motor on 2/2/21.
//

import Foundation

enum NetworkAddressReachability {
    case undefined
    case reachable
    case unreachable
}

class NetworkAddressInfo {
    let ip: IPAddress
    var reachability: NetworkAddressReachability
    
    init(ip: IPAddress, reachability: NetworkAddressReachability = .undefined) {
        self.ip = ip
        self.reachability = reachability
    }
}
