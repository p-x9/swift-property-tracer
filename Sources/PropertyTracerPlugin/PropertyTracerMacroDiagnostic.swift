//
//  PropertyTracerMacroDiagnostic.swift
//  
//
//  Created by p-x9 on 2023/11/01.
//  
//

import SwiftSyntax
import SwiftDiagnostics

enum PropertyTracerMacroDiagnostic {
    case requiresVariableDeclaration
    case requiredMutableVariableDeclaration
    case multipleVariableDeclarationIsNotSupported
    case getterAndSetterShouldBeNil
    case specifyTypeExplicitly
    case closureIsNotSupported
}

extension PropertyTracerMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case .requiresVariableDeclaration:
            return "This macro must be attached to the property declaration."
        case .requiredMutableVariableDeclaration:
            return "This macro can only be applied to a 'var'"
        case .multipleVariableDeclarationIsNotSupported:
            return """
            Multiple variable declaration in one statement is not supported.
            """
        case .getterAndSetterShouldBeNil:
            return "getter and setter must not be implemented."
        case .specifyTypeExplicitly:
            return "Specify a type explicitly."
        case .closureIsNotSupported:
            return """
            Unsupported closure type argument.　Please specify the function.
            """
        }
    }

    public var severity: DiagnosticSeverity {
        switch self {
        default:
            return .error
        }
    }

    public var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "PropertyTracer.\(self)")
    }
}
