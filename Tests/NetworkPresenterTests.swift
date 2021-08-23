//
//  NetworkPresenterTests.swift
//  NetworkPingerTests
//
//  Created by Alex Motor on 2/3/21.
//

import XCTest
@testable import NetworkPinger

class NetworkPresenterTests: XCTestCase {

    private var presenter: NetworkPresenterStub!
    private var view: NetworkViewMock!
    private var pinger: NetworkPingerProtocolMock!
    
    override func setUp() {
        super.setUp()
        
        presenter = NetworkPresenterStub()
        view = NetworkViewMock()
        presenter.view = view
        pinger = NetworkPingerProtocolMock()
        presenter.pinger = pinger
    }
    
    func testLaunchDiscoverNoNetwork() {
        presenter.launchDiscover()
        
        XCTAssertFalse(view.discoverStateUpdatedCalled.isCalled)
        XCTAssertTrue(view.showAlertCalled.isCalled)
        XCTAssertEqual(view.showAlertCalled.title, NetworkPresenterError.noNetworkAddress.title)
        XCTAssertEqual(view.showAlertCalled.message, NetworkPresenterError.noNetworkAddress.message)
    }
    
    func testLaunchDiscoverNoIp() {
        let subnetMask = IPAddress(int32: 0xFFFFFF00)
        
        presenter.networkAddressProviderProtocolStub.subnetMask = subnetMask
        
        presenter.launchDiscover()
        
        XCTAssertFalse(view.discoverStateUpdatedCalled.isCalled)
        XCTAssertTrue(view.showAlertCalled.isCalled)
        XCTAssertEqual(view.showAlertCalled.title, NetworkPresenterError.noNetworkAddress.title)
        XCTAssertEqual(view.showAlertCalled.message, NetworkPresenterError.noNetworkAddress.message)
    }
    
    func testLaunchDiscoverNoSubnetMask() {
        let ipAddress = IPAddress(int32: 0x01010101)

        presenter.networkAddressProviderProtocolStub.ipAddress = ipAddress
        
        presenter.launchDiscover()
        
        XCTAssertFalse(view.discoverStateUpdatedCalled.isCalled)
        XCTAssertTrue(view.showAlertCalled.isCalled)
        XCTAssertEqual(view.showAlertCalled.title, NetworkPresenterError.noNetworkAddress.title)
        XCTAssertEqual(view.showAlertCalled.message, NetworkPresenterError.noNetworkAddress.message)
    }
    
    func testLaunchDiscover() {
        let ipAddress = IPAddress(int32: 0x01010101)
        let subnetMask = IPAddress(int32: 0xFFFFFF00)
        
        presenter.networkAddressProviderProtocolStub.ipAddress = ipAddress
        presenter.networkAddressProviderProtocolStub.subnetMask = subnetMask
        
        presenter.launchDiscover()
        
        XCTAssertTrue(view.discoverStateUpdatedCalled.isCalled)
        XCTAssertEqual(view.discoverStateUpdatedCalled.state, .inProgress)
        view.discoverStateUpdatedCalled = (false, nil)
        
        XCTAssertTrue(view.updateDataCalled.isCalled)
        XCTAssertEqual(view.updateDataCalled.addresses?.count, 254)
        XCTAssertEqual(view.updateDataCalled.addresses?.last?.ip.int32, 0x010101FE)
        XCTAssertTrue(view.updateDataCalled.pingInProgress ?? false)

        let exp = expectation(description: "Waiting for ping finishing")
        
        // Should be performed after main.async block in pingNetwork method
        DispatchQueue.main.async {
            XCTAssertTrue(self.pinger.pingNetworkCalled.isCalled)
            XCTAssertEqual(self.pinger.pingNetworkCalled.addresses, self.view.updateDataCalled.addresses?.map(\.ip))

            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.3)
        
        XCTAssertTrue(view.discoverStateUpdatedCalled.isCalled)
        XCTAssertEqual(view.discoverStateUpdatedCalled.state, .standby)
    }
    
    func testStopDiscover() {
        let ipAddress = IPAddress(int32: 0x01010101)
        let subnetMask = IPAddress(int32: 0xFFFFFF00)
        
        presenter.networkAddressProviderProtocolStub.ipAddress = ipAddress
        presenter.networkAddressProviderProtocolStub.subnetMask = subnetMask

        presenter.launchDiscover()
        view.discoverStateUpdatedCalled = (false, nil)
        view.updateDataCalled = (false, nil, nil)
        presenter.stopDiscover()
        
        XCTAssertTrue(pinger.cancelPingCalled)
        XCTAssertTrue(view.discoverStateUpdatedCalled.isCalled)
        XCTAssertEqual(view.discoverStateUpdatedCalled.state, .standby)
        
        XCTAssertTrue(view.updateDataCalled.isCalled)
        XCTAssertEqual(view.updateDataCalled.addresses?.count, 254)
        XCTAssertEqual(view.updateDataCalled.addresses?.last?.ip.int32, 0x010101FE)
        XCTAssertFalse(view.updateDataCalled.pingInProgress ?? true)
    }
    
    func testSortingUpdatedIP() throws {
        let ip1 = "192.168.0.10"
        let ip2 = "192.168.0.100"
        let ip3 = "192.168.0.1"
        
        presenter.addressesInfo = [
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress(ip1))),
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress(ip2))),
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress(ip3)))
        ]
        
        presenter.sortingUpdated(.ip)
        
        XCTAssertEqual(presenter.addressesInfo.map(\.ip.humanReadableString), [ip3, ip1, ip2])
    }
    
    func testSortingUpdatedReachability() throws {
        presenter.addressesInfo = [
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress("192.168.0.1")), reachability: .undefined),
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress("192.168.0.2")), reachability: .unreachable),
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress("192.168.0.3")), reachability: .undefined),
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress("192.168.0.4")), reachability: .reachable),
            NetworkAddressInfo(ip: try XCTUnwrap(IPAddress("192.168.0.5")), reachability: .unreachable),
        ]
        
        presenter.sortingUpdated(.reachability)
        
        XCTAssertEqual(presenter.addressesInfo.map(\.reachability), [
            .reachable,
            .unreachable,
            .unreachable,
            .undefined,
            .undefined
        ])
        XCTAssertEqual(presenter.addressesInfo.map(\.ip.humanReadableString), [
            "192.168.0.4",
            "192.168.0.2",
            "192.168.0.5",
            "192.168.0.1",
            "192.168.0.3"
        ])
    }
    
    func testPingFinishedUnknownIp() {
        presenter.addressesInfo = [
            NetworkAddressInfo(ip: IPAddress(int32: 0))
        ]
        
        presenter.pingFinished(for: IPAddress(int32: 1), isSuccess: true)
        
        XCTAssertFalse(view.updateDataCalled.isCalled)
    }
    
    func testPingFinishedReachableSortTypeReachability() {
        let info1 = NetworkAddressInfo(ip: IPAddress(int32: 1), reachability: .undefined)
        let info2 = NetworkAddressInfo(ip: IPAddress(int32: 2), reachability: .undefined)

        presenter.sortingUpdated(.reachability)
        presenter.addressesInfo = [info1, info2]
        
        presenter.pingFinished(for: IPAddress(int32: 2), isSuccess: true)

        XCTAssertEqual(info2.reachability, .reachable)
        XCTAssertTrue(view.updateDataCalled.isCalled)
        XCTAssertEqual(view.updateDataCalled.addresses, [info2, info1])
        XCTAssertTrue(view.updateDataCalled.pingInProgress ?? false)
    }
    
    func testPingFinishedReachableSortTypeIp() {
        let info1 = NetworkAddressInfo(ip: IPAddress(int32: 1), reachability: .undefined)
        let info2 = NetworkAddressInfo(ip: IPAddress(int32: 2), reachability: .undefined)

        presenter.addressesInfo = [info1, info2]
        
        presenter.pingFinished(for: IPAddress(int32: 2), isSuccess: true)

        XCTAssertEqual(info2.reachability, .reachable)
        XCTAssertTrue(view.updateDataCalled.isCalled)
        XCTAssertEqual(view.updateDataCalled.addresses, [info1, info2])
        XCTAssertTrue(view.updateDataCalled.pingInProgress ?? false)
    }
    
    func testPingFinishedUnreachable() {
        let info1 = NetworkAddressInfo(ip: IPAddress(int32: 1), reachability: .undefined)
        let info2 = NetworkAddressInfo(ip: IPAddress(int32: 2), reachability: .undefined)

        presenter.addressesInfo = [info1, info2]
        
        presenter.pingFinished(for: IPAddress(int32: 1), isSuccess: false)

        XCTAssertEqual(info1.reachability, .unreachable)
        XCTAssertTrue(view.updateDataCalled.isCalled)
        XCTAssertEqual(view.updateDataCalled.addresses, [info1, info2])
        XCTAssertTrue(view.updateDataCalled.pingInProgress ?? false)
    }
}

private class NetworkViewMock: NetworkView {
    var discoverStateUpdatedCalled: (isCalled: Bool, state: NetworkPresenter.DiscoverState?) = (false, nil)
    var showAlertCalled: (isCalled: Bool, title: String?, message: String?) = (false, nil, nil)
    var updateDataCalled: (isCalled: Bool, addresses: [NetworkAddressInfo]?, pingInProgress: Bool?) = (false, nil, nil)
    
    func discoverStateUpdated(_ state: NetworkPresenter.DiscoverState) {
        discoverStateUpdatedCalled = (true, state)
    }
    
    func showAlert(title: String, message: String) {
        showAlertCalled = (true, title, message)
    }
    
    func updateData(addresses: [NetworkAddressInfo], pingInProgress: Bool) {
        updateDataCalled = (true, addresses, pingInProgress)
    }
}

private class NetworkAddressProviderProtocolStub: NetworkAddressProviderProtocol {
    var ipAddress: IPAddress?
    var subnetMask: SubnetMask?
}

private class NetworkPresenterStub: NetworkPresenter {
    var networkAddressProviderProtocolStub = NetworkAddressProviderProtocolStub()
    
    override var addressProvider: NetworkAddressProviderProtocol { networkAddressProviderProtocolStub }
}

class NetworkPingerProtocolMock: NetworkPingerProtocol {
    var pingNetworkCalled: (isCalled: Bool, addresses: [IPAddress]?) = (false, nil)
    var cancelPingCalled: Bool = false
    
    var delegate: NetworkPingerDelegate?
    
    func pingNetwork(with addresses: [IPAddress]) {
        pingNetworkCalled = (true, addresses)
    }
    
    func cancelPing() {
        cancelPingCalled = true
    }
}

extension NetworkAddressInfo: Equatable {
    public static func == (lhs: NetworkAddressInfo, rhs: NetworkAddressInfo) -> Bool {
        return lhs.ip == rhs.ip && lhs.reachability == rhs.reachability
    }
}
