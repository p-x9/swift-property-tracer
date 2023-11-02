//
//  DeclGroupSyntax+.swift
//
//
//  Created by p-x9 on 2023/11/02.
//  
//

import Foundation
import SwiftSyntax

extension DeclGroupSyntax {
    /// A computed property to get the name of the declaration.
    ///
    /// The name is extracted from the declaration syntax node, trimmed of whitespaces, and returned as a string.
    /// If the declaration is not a class, struct, actor, or enum declaration, `nil` is returned.
    var name: String? {
        if let decl = self.as(ClassDeclSyntax.self) {
            return decl.name.trimmed.text
        } else if let decl = self.as(StructDeclSyntax.self) {
            return decl.name.trimmed.text
        } else if let decl = self.as(ActorDeclSyntax.self) {
            return decl.name.trimmed.text
        } else if let decl = self.as(EnumDeclSyntax.self) {
            return decl.name.trimmed.text
        } else {
            return nil
        }
    }

    /// Computed property to check if a declaration is a reference type.
    ///
    /// Returns true if it is a Class or Actor type.
    var isReferenceType: Bool {
        if self.as(ClassDeclSyntax.self) == nil ||
            self.as(ActorDeclSyntax.self) == nil {
            return true
        }
        return false
    }

    /// A computed property to check if the declaration is an extension declaration.
    var isExtension: Bool {
        if self.as(ExtensionDeclSyntax.self) == nil {
            return true
        }
        return false
    }
}
