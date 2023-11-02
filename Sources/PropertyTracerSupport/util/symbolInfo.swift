//
//  symbolInfo.swift
//  
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation

func symbolInfo(for address: UInt) -> Dl_info? {
    var info = Dl_info()
    let ptr: UnsafeRawPointer = UnsafeRawPointer(bitPattern: address)!
    let result = dladdr(ptr, &info)
    return result == 0 ? nil : info
}
