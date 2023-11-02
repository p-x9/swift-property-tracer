//
//  NoTracedMacro.swift
//  
//
//  Created by p-x9 on 2023/11/02.
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// This macro is a mark for members of the type to which the `@PropertyTraced` macro is added that should not be traced
struct NoTracedMacro {}

extension NoTracedMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(VariableDeclSyntax.self) != nil else {
            context.diagnose(
                PropertyTracerMacroDiagnostic.requiresVariableDeclaration.diagnose(at: declaration)
            )
            return []
        }
        return []
    }
    
}
