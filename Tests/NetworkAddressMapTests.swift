//
//  NetworkAddressMapTests.swift
//  NetworkPingerTests
//
//  Created by Alex Motor on 2/3/21.
//

import XCTest
@testable import NetworkPinger

class NetworkAddressMapTests: XCTestCase {

    func testAllIPAddressesTwoIpNetwork() {
        let ipAddress = IPAddress("10.10.10.4")!
        let subnetMask = IPAddress("255.255.255.244")!
        
        let map = NetworkAddressMap(ipAddress: ipAddress, subnetMask: subnetMask)
        
        XCTAssertEqual(map.allIPAddresses, [
            IPAddress("10.10.10.5")!,
            IPAddress("10.10.10.6")!
        ])
    }
    
    func testAllIPAddressesNoOne() {
        let ipAddress = IPAddress("10.10.10.0")!
        let subnetMask = IPAddress("255.255.255.254")!
        
        let map = NetworkAddressMap(ipAddress: ipAddress, subnetMask: subnetMask)
        
        XCTAssertEqual(map.allIPAddresses.count, 0)

    }
    
    func testAllIPAddressesHugeCount() {
        let ipAddress = IPAddress("192.168.128.100")!
        let subnetMask = IPAddress("255.255.128.0")!
        
        let map = NetworkAddressMap(ipAddress: ipAddress, subnetMask: subnetMask)
        
        XCTAssertEqual(map.allIPAddresses.count, 32_766)

    }

}
