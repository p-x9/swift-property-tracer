//
//  Thread+.swift
//  
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation

extension Thread {
    /// Retrieves the dynamic linking information for a given set of addresses.
    ///
    /// - Parameter addresses: An array of addresses for which to retrieve dynamic linking information.
    /// - Returns: An array of `Dl_info` structures containing the dynamic linking informat
    package class func callStackDLInfos(addresses: [NSNumber]) -> [Dl_info] {
        addresses.compactMap { symbolInfo(for: $0.uintValue) }
    }

    /// Retrieves the call stack information for a given set of addresses.
    ///
    /// - Parameter addresses: An array of addresses for which to retrieve call stack information.
    /// - Returns: An array of `CallStackInfo` structures containing the call stack information for each address.
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

    /// Retrieves the symbol names for a given set of addresses.
    ///
    /// - Parameter addresses: An array of addresses for which to retrieve symbol names.
    /// - Returns: An array of strings containing the symbol names for each address.
    ///
    /// Symbol names are returned demangled
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
