//
//  VariableDeclSyntax+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//
//

import Foundation
import SwiftSyntax

extension VariableDeclSyntax {
    /// A computed property to check if the variable declaration is a constant (`let`).
    ///
    /// Returns `true` if the variable declaration uses the `let` keyword, and `false` otherwise.
    public var isLet: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }

    /// A computed property to check if the variable declaration is a variable (`var`).
    ///
    /// Returns `true` if the variable declaration uses the `var` keyword, and `false` otherwise.
    public var isVar: Bool {
        bindingSpecifier.tokenKind == .keyword(.var)
    }
}

extension VariableDeclSyntax {
    /// A computed property to check if the variable declaration is static.
    ///
    /// Returns `true` if the variable declaration includes the `static` keyword among its modifiers, and `false` otherwise.
    public var isStatic: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }

    /// A computed property to check if the variable declaration is class-scoped.
    ///
    /// Returns `true` if the variable declaration includes the `class` keyword among its modifiers, and `false` otherwise.
    public var isClass: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.class)
        }
    }

    // A computed property to check if the variable declaration is instance-scoped.
    ///
    /// Returns `true` if the variable declaration is neither static nor class, and `false` otherwise.
    public var isInstance: Bool {
        !isClass && !isStatic
    }
}
