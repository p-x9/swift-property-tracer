//
//  CallStackInfo.swift
//
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation

/// A structure representing information about a particular frame in a call stack.
public struct CallStackInfo: Equatable {

    /// The file path of the library in which the symbol is defined, if available.
    public let libraryPath: String?

    /// The base address of the library, if available.
    public let libraryBaseAddress: UnsafeMutableRawPointer?

    /// The name of the symbol at the call stack frame, if available.
    public let symbolName: String?

    /// The address of the symbol, if available.
    public let symbolAddress: UnsafeMutableRawPointer?

    /// The return address of the call stack frame.
    public let returnAddress: NSNumber
}

extension CallStackInfo {

    /// The demangled name of the symbol, if available.
    ///
    /// This computed property attempts to demangle the symbol name, returning `nil` if the symbol name is not available or cannot be demangled.
    public var demangledSymbolName: String? {
        symbolName.map {
            stdlib_demangleName($0)
        }
    }
}
