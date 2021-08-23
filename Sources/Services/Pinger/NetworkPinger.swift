//
//  NetworkPinger.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/31/21.
//

import Foundation
import SwiftyPing

protocol NetworkPingerProtocol {
    var delegate: NetworkPingerDelegate? { get set }
    
    func pingNetwork(with addresses: [IPAddress])
    func cancelPing()
}

protocol NetworkPingerDelegate: AnyObject {
    func pingFinished(for ip: IPAddress, isSuccess: Bool)
}

class NetworkPinger: NetworkPingerProtocol {
    static let maxConcurrentPingOperationCount: Int? = nil
    
    weak var delegate: NetworkPingerDelegate?
    
    private let pingerQueue: OperationQueue = {
        let queue = OperationQueue()
        if let maxConcurrentPingOperationCount = maxConcurrentPingOperationCount {
            queue.maxConcurrentOperationCount = maxConcurrentPingOperationCount
        }
        return queue
    }()
    
    func cancelPing() {
        pingerQueue.cancelAllOperations()        
    }
    
    func pingNetwork(with addresses: [IPAddress]) {
        for ip in addresses {
            let pingOperation = createPingOperation(ip: ip)
            pingOperation.completion = { [weak self] operation in
                guard !operation.isCancelled else { return }
                
                self?.delegate?.pingFinished(for: operation.ip, isSuccess: operation.successAttemptsCount > 0)
            }
            pingerQueue.addOperation(pingOperation)
        }
        
        pingerQueue.waitUntilAllOperationsAreFinished()
    }
    
    // Opened for testing
    func createPingOperation(ip: IPAddress) -> PingOperation {
        return PingOperation(ip: ip)
    }
}
