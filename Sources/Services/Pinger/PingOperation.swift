//
//  PingOperation.swift
//  NetworkPinger
//
//  Created by Alex Motor on 2/1/21.
//

import Foundation
import SwiftAsyncOp
import SwiftyPing

class PingOperation: AsyncOperation {
    static let attemptsCount = 3
    private static let config = PingConfiguration(interval: 0.3, with: 3)
    
    private let pinger: SwiftyPing?
    private var attemptsFinished = 0
    
    let ip: IPAddress
    var successAttemptsCount = 0
    var failedAttemptsCount = 0
    var underlyingError: Error?
    
    var completion: ((PingOperation) -> Void)?
    
    init(ip: IPAddress) {
        do {
            self.ip = ip
            self.pinger = try SwiftyPing(ipv4Address: ip.humanReadableString, config: PingOperation.config, queue: DispatchQueue.global(qos: .userInitiated))
        } catch {
            self.pinger = nil
            self.underlyingError = error
        }
    }
    
    override func task() {
        guard let pinger = pinger else {
            finish()
            return
        }
        
        pinger.observer = { [weak self] response in
            self?.pingResponseReceived(response)
        }
        
        do {
            try pinger.startPinging()
        } catch {
            underlyingError = error
        }
    }
    
    override func finish() {
        completion?(self)
        
        super.finish()
    }
    
    override func cancel() {
        super.cancel()
        
        guard isExecuting else { return }
        
        pinger?.stopPinging()
        finish()
    }
    
    private func pingResponseReceived(_ response: PingResponse) {
        guard !isCancelled else { return }
        
        if response.error != nil {
            failedAttemptsCount += 1
        } else {
            successAttemptsCount += 1
        }
        
        attemptsFinished += 1
        
        if attemptsFinished == PingOperation.attemptsCount {
            finish()
            pinger?.stopPinging()
        }
    }
}
