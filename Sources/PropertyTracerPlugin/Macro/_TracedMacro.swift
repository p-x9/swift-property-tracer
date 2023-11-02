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

struct _TracedMacro {
    struct Arguments {
        let callbackExpr: ExprSyntax

        init(
            callbackExpr: ExprSyntax
        ) {
            self.callbackExpr = callbackExpr
        }
    }

    static func arguments(
        of node: AttributeSyntax,
        context: some MacroExpansionContext
    ) -> Arguments? {
        guard case let .argumentList(arguments) = node.arguments,
              let firstElement = arguments.first?.expression else {
            return nil
        }

        if let closureExpr = firstElement.as(ClosureExprSyntax.self) {
            context.diagnose(
                PropertyTracerMacroDiagnostic.closureIsNotSupported.diagnose(at: closureExpr)
            )
            return nil
        }

        return .init(
            callbackExpr: firstElement
        )
    }
}

extension _TracedMacro: AccessorMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            context.diagnose(
                PropertyTracerMacroDiagnostic.requiresVariableDeclaration.diagnose(at: declaration)
            )
            return []
        }

        guard variableDecl.isVar else {
            context.diagnose(
                PropertyTracerMacroDiagnostic.requiredMutableVariableDeclaration.diagnose(at: declaration)
            )
            return []
        }

        guard let binding = variableDecl.bindings.first else {
            context.diagnose(
                PropertyTracerMacroDiagnostic.multipleVariableDeclarationIsNotSupported.diagnose(at: declaration)
            )
            return []
        }

        guard binding.isStored else {
            context.diagnose(
                PropertyTracerMacroDiagnostic.getterAndSetterShouldBeNil.diagnose(at: declaration)
            )
            return []
        }

        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            return []
        }

        guard let type = binding.typeAnnotation?.type.trimmed else {
            context.diagnose(
                PropertyTracerMacroDiagnostic.specifyTypeExplicitly.diagnose(at: declaration)
            )
            return []
        }

        let argument = arguments(of: node, context: context)


        let setCallback = """
            _\(identifier).setCallback(\(argument?.callbackExpr.description ?? "nil"))
            """

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
                \(raw: setCallback)
                return _\(identifier).wrappedValue
            }
            set {
                _\(identifier).setParent(self)
                \(raw: setCallback)
                _\(identifier).wrappedValue = newValue
            }
            """
        ]
    }


}
