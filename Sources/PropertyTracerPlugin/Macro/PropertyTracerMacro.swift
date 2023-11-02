//
//  PropertyTracerMacro.swift
//
//
//  Created by p-x9 on 2023/11/01.
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PropertyTracerMacro {
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

extension PropertyTracerMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let variableDecl = member.as(VariableDeclSyntax.self),
              variableDecl.isVar,
              let binding = variableDecl.bindings.first,
              binding.isStored,
              binding.typeAnnotation != nil else {
            return []
        }

        if variableDecl.attributes.contains(where: { element in
            guard case let .attribute(attribute) = element,
                  let name = attribute.attributeName.as(IdentifierTypeSyntax.self),
                  ["Traced", "NoTraced"].contains(name.name.trimmed.text) else {
                return false
            }
            return true
        }) {
            return []
        }

        let argument = arguments(of: node, context: context)

        return [
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier("_Traced")
                ),
                leftParen: .leftParenToken(),
                arguments: .argumentList(
                    LabeledExprListSyntax {
                        if let argument {
                            LabeledExprSyntax(
                                expression: argument.callbackExpr
                            )
                        }
                    }
                ),
                rightParen: .rightParenToken()
            )
        ]
    }
}

extension PropertyTracerMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let groupName = declaration.name else { return [] }

        let variables = declaration.memberBlock.members
            .lazy
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.isVar }
            .filter { $0.bindings.count == 1 }
            .filter {
                !$0.attributes.contains { element in
                    guard case let .attribute(attribute) = element,
                          let name = attribute.attributeName.as(IdentifierTypeSyntax.self),
                          ["Traced", "NoTraced"].contains(name.name.trimmed.text) else {
                        return false
                    }
                    return true
                }
            }

        let decls = variables
            .lazy
            .compactMap { variable -> PatternBindingSyntax? in
                variable.bindings.first
            }
            .filter { $0.typeAnnotation != nil }
            .filter { $0.isStored }
            .map {
                DeclSyntax("var _\($0.pattern): Traced<\(raw: groupName),\($0.typeAnnotation!.type.trimmed)>")
            }


        return Array(decls)
    }
}


