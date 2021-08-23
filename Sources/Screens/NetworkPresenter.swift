//
//  NetworkPresenter.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/30/21.
//

import Foundation

protocol NetworkView: AnyObject {
    func discoverStateUpdated(_ state: NetworkPresenter.DiscoverState)
    func showAlert(title: String, message: String)
    func updateData(addresses: [NetworkAddressInfo], pingInProgress: Bool)
}

class NetworkPresenter {
    enum DiscoverState {
        case standby
        case inProgress
    }
    
    enum SortType {
        case ip
        case reachability
    }

    weak var view: NetworkView?
    var pinger: NetworkPingerProtocol = NetworkPinger()
    
    var addressProvider: NetworkAddressProviderProtocol { NetworkAddressProvider() }
    
    var addressesInfo: [NetworkAddressInfo] = []
    private var discoverState: DiscoverState = .standby {
        didSet {
            view?.discoverStateUpdated(discoverState)
        }
    }
    private var sortType: SortType = .ip {
        didSet {
            applySorting()
            view?.updateData(addresses: addressesInfo, pingInProgress: discoverState == .inProgress)
        }
    }
    
    func launchDiscover() {
        guard discoverState == .standby else { return }
        
        guard let ipAddress = addressProvider.ipAddress, let subnetMask = addressProvider.subnetMask else {
            showAlert(.noNetworkAddress)
            return
        }
        
        discoverState = .inProgress
        
        pingNetwork(ip: ipAddress, subnetMask: subnetMask)
    }
    
    func stopDiscover() {
        guard discoverState == .inProgress else { return }
        
        pinger.cancelPing()
        discoverState = .standby
        
        view?.updateData(addresses: addressesInfo, pingInProgress: false)
    }
    
    func sortingUpdated(_ type: SortType) {
        sortType = type
    }
    
    private func showAlert(_ error: NetworkPresenterError) {
        view?.showAlert(title: error.title, message: error.message)
    }
    
    private func pingNetwork(ip: IPAddress, subnetMask: SubnetMask) {
        let map = NetworkAddressMap(ipAddress: ip, subnetMask: subnetMask)
        addressesInfo = map.allIPAddresses.map { NetworkAddressInfo(ip: $0) }
        view?.updateData(addresses: addressesInfo, pingInProgress: true)
        
        pinger.delegate = self
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.pinger.pingNetwork(with: map.allIPAddresses)
            
            DispatchQueue.main.async {
                self?.discoverState = .standby
            }
        }
    }
    
    private func applySorting() {
        addressesInfo.sort(by: { lhs, rhs in
            switch sortType {
            case .ip:
                return lhs.ip.int32 < rhs.ip.int32
            case .reachability:
                
                // OK: R-R, R-U, R-Undef, U-U, U-Undef, Undef-Undef
                var reachabilityCorrectOrder = lhs.reachability == .reachable ||
                    lhs.reachability == .unreachable && (rhs.reachability != .reachable) ||
                    lhs.reachability == .undefined && rhs.reachability == .undefined
                
                // Inside the same status should be ip sorting
                if lhs.reachability == rhs.reachability {
                    reachabilityCorrectOrder = reachabilityCorrectOrder && (lhs.ip.int32 < rhs.ip.int32)
                }
                
                return reachabilityCorrectOrder
            }
        })
    }
}

extension NetworkPresenter: NetworkPingerDelegate {
    func pingFinished(for ip: IPAddress, isSuccess: Bool) {        
        guard let info = addressesInfo.first(where: { $0.ip == ip }) else {
            return
        }
        
        info.reachability = isSuccess ? .reachable : .unreachable
        
        // Re-sort it for reachability sorting, because order can be changed
        if sortType == .reachability {
            applySorting()
        }
        
        view?.updateData(addresses: addressesInfo, pingInProgress: true)
    }
}
