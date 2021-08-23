//
//  IPAddressTests.swift
//  NetworkPingerTests
//
//  Created by Alex Motor on 2/3/21.
//

import XCTest
@testable import NetworkPinger

class IPAddressTests: XCTestCase {

    func testInitString() {
        let ip = IPAddress("213.184.224.254")
        
        XCTAssertEqual(ip?.octets.0, 213)
        XCTAssertEqual(ip?.octets.1, 184)
        XCTAssertEqual(ip?.octets.2, 224)
        XCTAssertEqual(ip?.octets.3, 254)
    }
    
    func testInitStringIncorrect() {
        let ip = IPAddress("213.184.224.256")
        
        XCTAssertNil(ip)
    }

    func testInitInt32() {
        let ip = IPAddress(int32: 0x0011AAFF)
        
        XCTAssertEqual(ip.octets.0, 0x00)
        XCTAssertEqual(ip.octets.1, 0x11)
        XCTAssertEqual(ip.octets.2, 0xAA)
        XCTAssertEqual(ip.octets.3, 0xFF)
    }
    
    func testHumanReadableString() throws {
        let ipString = "192.168.100.12"
        
        let ip = try XCTUnwrap(IPAddress(ipString))
        
        let result = ip.humanReadableString
        XCTAssertEqual(result, ipString)
    }
    
    func testInt32() {
        let int32: UInt32 = 0xAFEC0132
        let ip = IPAddress(int32: int32)
        
        XCTAssertEqual(ip.int32, int32)
    }
    
    func testEquatable() {
        let ip1 = IPAddress("1.10.15.0")
        let ip2 = IPAddress(int32: 0x010A0F00)
        
        XCTAssertEqual(ip1, ip2)
    }
}
