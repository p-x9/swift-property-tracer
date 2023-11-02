//
//  PropertyTracerMacroPlugin.swift
//
//
//  Created by p-x9 on 2023/11/01.
//  
//

#if canImport(SwiftCompilerPlugin)
import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct PropertyTracerMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PropertyTracerMacro.self,
        _TracedMacro.self,
        NoTracedMacro.self
    ]
}
#endif

