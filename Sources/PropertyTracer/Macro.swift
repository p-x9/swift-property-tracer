//
//  Macro.swift
//
//
//  Created by p-x9 on 2023/11/02.
//  
//

import Foundation
import PropertyTracerSupport

@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro PropertyTraced(
    _ callback: ((AnyPropertyAccess) -> Void)? = nil
) = #externalMacro(
    module: "PropertyTracerPlugin",
    type: "PropertyTracerMacro"
)

@attached(accessor, names: named(init), named(get), named(set))
public macro _Traced(
    _ callback: ((AnyPropertyAccess) -> Void)? = nil
) = #externalMacro(
    module: "PropertyTracerPlugin",
    type: "_TracedMacro"
)

@attached(peer)
public macro NoTraced() = #externalMacro(
    module: "PropertyTracerPlugin",
    type: "NoTracedMacro"
)
