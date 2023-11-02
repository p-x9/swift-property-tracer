//
//  _TracedMacro.swift
//
//
//  Created by p-x9 on 2023/11/02.
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct _TracedMacro {}

extension _TracedMacro: AccessorMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            return []
        }

        guard variableDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
            return []
        }

        guard let binding = variableDecl.bindings.first else {
            return []
        }

        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            return []
        }
        //        guard let type = binding.typeAnnotation?.type.trimmed else {
        //            return []
        //        }

        return [
            """
            @storageRestrictions(initializes: _\(identifier))
            init(initialValue)  {
                _\(identifier) = Traced(wrappedValue: initialValue,
                                        keyPath: \\.\(identifier))
            }
            """,
            """
            get {
                _\(identifier).setParent(self)
                return _\(identifier).wrappedValue
            }
            set {
                _\(identifier).setParent(self)
                _\(identifier).wrappedValue = newValue
            }
            """
        ]
    }


}
