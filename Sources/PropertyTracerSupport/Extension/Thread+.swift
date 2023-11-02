//
//  Thread+.swift
//  
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation

extension Thread {
    package class func callStackDLInfos(addresses: [NSNumber]) -> [Dl_info] {
        addresses.compactMap { symbolInfo(for: $0.uintValue) }
    }

    package class func callStackInfos(addresses: [NSNumber]) -> [CallStackInfo] {
        addresses
            .lazy
            .compactMap { address -> (NSNumber, Dl_info)? in
                guard let info = symbolInfo(for: address.uintValue) else {
                    return nil
                }
                return (address, info)
            }
            .map { address, info in
                return CallStackInfo(
                    libraryPath: info.dli_fname.map { String(cString: $0) },
                    libraryBaseAddress: info.dli_fbase,
                    symbolName: info.dli_sname.map { String(cString: $0) },
                    symbolAddress: info.dli_saddr,
                    returnAddress: address
                )
            }
    }

    package class func callStackNames(addresses: [NSNumber]) -> [String] {
        Self.callStackDLInfos(addresses: addresses).compactMap {
            if let cname = $0.dli_sname {
                let name = String(cString: cname)
                return stdlib_demangleName(name)
            }
            return nil
        }
    }
}
