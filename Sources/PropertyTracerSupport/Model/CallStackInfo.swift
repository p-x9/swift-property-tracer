//
//  CallStackInfo.swift
//
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation


public struct CallStackInfo: Equatable {
    public let libraryPath: String?
    public let libraryBaseAddress: UnsafeMutableRawPointer?

    public let symbolName: String?
    public let symbolAddress: UnsafeMutableRawPointer?

    public let returnAddress: NSNumber
}

extension CallStackInfo {
    public var demangledSymbolName: String? {
        symbolName.map {
            stdlib_demangleName($0)
        }
    }
}
