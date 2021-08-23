//
//  NetworkAddressMap.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/31/21.
//

import Foundation

struct NetworkAddressMap {
    let allIPAddresses: [IPAddress]
    
    init(ipAddress: IPAddress, subnetMask: SubnetMask) {
        let subnetMask = subnetMask.int32
        let networkAddress = ipAddress.int32 & subnetMask
        
        var addresses: [IPAddress] = []
        var currentAddress = networkAddress + 1
        repeat {
            addresses.append(IPAddress(int32: currentAddress))
            
            currentAddress += 1
        } while currentAddress & subnetMask == networkAddress
        
        // Remove broadcast address
        addresses.removeLast()
        
        allIPAddresses = addresses
    }
}
