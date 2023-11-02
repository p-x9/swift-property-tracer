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

    var isReferenceType: Bool {
        if self.as(ClassDeclSyntax.self) == nil ||
            self.as(ActorDeclSyntax.self) == nil {
            return true
        }
        return false
    }

    var isExtension: Bool {
        if self.as(ExtensionDeclSyntax.self) == nil {
            return true
        }
        return false
    }
}
