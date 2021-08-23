//
//  IPAddress.swift
//  NetworkPinger
//
//  Created by Alex Motor on 1/31/21.
//

import Foundation

struct IPAddress {
    private static let octetsSeparator = "."
    
    let octets: (UInt8, UInt8, UInt8, UInt8)
    
    init?(_ string: String) {
        let octetsArray = string.split(separator: Character(IPAddress.octetsSeparator))
            .compactMap { UInt8($0) }
        
        guard octetsArray.count == 4 else { return nil }
        
        octets = (octetsArray[0], octetsArray[1], octetsArray[2], octetsArray[3])
    }
    
    init(int32: UInt32) {
        let octet4 = UInt8(int32 & 0xFF)
        let octet3 = UInt8((int32 >> 8) & 0xFF)
        let octet2 = UInt8((int32 >> 16) & 0xFF)
        let octet1 = UInt8((int32 >> 24) & 0xFF)
        
        octets = (octet1, octet2, octet3, octet4)
    }
    
    var humanReadableString: String {
        return [octets.0, octets.1, octets.2, octets.3]
            .map(String.init)
            .joined(separator: IPAddress.octetsSeparator)
    }
    
    var int32: UInt32 {
        return UInt32(octets.0) << 24 +
            UInt32(octets.1) << 16 +
            UInt32(octets.2) << 8 +
            UInt32(octets.3)
    }
}

extension IPAddress: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.int32 == rhs.int32
    }
}
