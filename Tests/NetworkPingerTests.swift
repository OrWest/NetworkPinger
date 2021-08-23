//
//  NetworkPingerTests.swift
//  NetworkPingerTests
//
//  Created by Alex Motor on 2/3/21.
//

import XCTest
@testable import NetworkPinger

class NetworkPingerTests: XCTestCase {
    func testPingNetworkSuccess() {
        let ipInt: UInt32 = 0x100A0F01
        let ip = IPAddress(int32: ipInt)
        
        let delegate = NetworkPingerDelegateMock()
        let pinger = NetworkPingerStub()
        pinger.successCount = 1
        pinger.delegate = delegate
        
        pinger.pingNetwork(with: [ip])
        
        XCTAssertTrue(delegate.pingFinishedCalled.called)
        XCTAssertEqual(delegate.pingFinishedCalled.ip, ip)
        XCTAssertTrue(delegate.pingFinishedCalled.isSuccess ?? false)
    }
    
    func testPingNetworkFailed() {
        let ipInt: UInt32 = 0x100A0F01
        let ip = IPAddress(int32: ipInt)
        
        let delegate = NetworkPingerDelegateMock()
        let pinger = NetworkPingerStub()
        pinger.successCount = 0
        pinger.delegate = delegate
        
        pinger.pingNetwork(with: [ip])
        
        XCTAssertTrue(delegate.pingFinishedCalled.called)
        XCTAssertEqual(delegate.pingFinishedCalled.ip, ip)
        XCTAssertFalse(delegate.pingFinishedCalled.isSuccess ?? true)
    }
    
    func testPingNetworkIPs() {
        let ipInt1: UInt32 = 0x100A0F01
        let ipInt2: UInt32 = 0xFFA01781
        let ipInt3: UInt32 = 0x3475092A
        let ip1 = IPAddress(int32: ipInt1)
        let ip2 = IPAddress(int32: ipInt2)
        let ip3 = IPAddress(int32: ipInt3)
        
        let pinger = NetworkPingerStub()
        pinger.successCount = 1
        
        let ips = [ip1, ip2, ip3]
        pinger.pingNetwork(with: ips)
        
        XCTAssertEqual(ips, pinger.calledCreatePingOperationWithIPs)
    }
}

private class NetworkPingerDelegateMock: NetworkPingerDelegate {
    var pingFinishedCalled: (called: Bool, ip: IPAddress?, isSuccess: Bool?) = (false, nil, nil)
    
    func pingFinished(for ip: IPAddress, isSuccess: Bool) {
        pingFinishedCalled = (true, ip, isSuccess)
    }
}

private class NetworkPingerStub: NetworkPinger {
    var calledCreatePingOperationWithIPs: [IPAddress] = []
    
    var successCount = 0
    
    override func createPingOperation(ip: IPAddress) -> PingOperation {
        calledCreatePingOperationWithIPs.append(ip)
        
        let operation = PingOperationStub(ip: ip)
        operation.successAttemptsCount = successCount
        return operation
    }
}

private class PingOperationStub: PingOperation {
    override func task() {
        finish()
    }
}
