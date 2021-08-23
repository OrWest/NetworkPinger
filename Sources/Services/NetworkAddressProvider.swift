//
//  NetworkAddressProvider.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/30/21.
//

import Foundation

typealias SubnetMask = IPAddress

protocol NetworkAddressProviderProtocol {
    var ipAddress: IPAddress? { get }
    var subnetMask: SubnetMask? { get }
}

class NetworkAddressProvider: NetworkAddressProviderProtocol {
    private static let wifiInterfaceName = "en0"
    
    let ipAddress: IPAddress?
    let subnetMask: SubnetMask?
    
    private struct NetInfo {
        let ip: String
        let subnet: String
    }
    
    init() {
        let info = NetworkAddressProvider.getWiFiInfo()
        
        if let ip = info?.ip {
            self.ipAddress = IPAddress(ip)
        } else {
            self.ipAddress = nil
        }
        
        if let subnet = info?.subnet {
            self.subnetMask = IPAddress(subnet)
        } else {
            self.subnetMask = nil
        }
    }
    
    private static func getWiFiInfo() -> NetInfo? {
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }

        var info: NetInfo?
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == wifiInterfaceName {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    let address = String(cString: hostname)
                    
                    var net = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_netmask, socklen_t(interface.ifa_netmask.pointee.sa_len),
                                &net, socklen_t(net.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    let netmask = String(cString: net)

                    info = NetInfo(ip: address, subnet: netmask)
                }
            }
        }
        freeifaddrs(ifaddr)

        return info
    }
}
