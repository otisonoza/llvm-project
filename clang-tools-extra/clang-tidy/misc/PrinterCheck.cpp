//===--- PrinterCheck.cpp - clang-tidy ------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "PrinterCheck.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"

#include <sstream>

using namespace clang::ast_matchers;

namespace clang::tidy::misc {

void PrinterCheck::registerMatchers(MatchFinder *Finder) {
  Finder->addMatcher(typeLoc().bind("typeLoc"), this);
}

void PrinterCheck::check(const MatchFinder::MatchResult &Result) {
  if (const auto *typeLoc = Result.Nodes.getNodeAs<TypeLoc>("typeLoc")) {
    const auto *type = typeLoc->getTypePtr();

    if (!type->isBuiltinType() && !type->isCanonicalUnqualified()) {
      if (const auto *recordType = type->getAs<clang::RecordType>()) {
        const clang::RecordDecl *typeDecl = recordType->getDecl();

        if (!typeDecl->isImplicit()) {
          PrintingPolicy print_policy(Result.Context->getLangOpts());
          print_policy.FullyQualifiedName = 1;
          print_policy.SuppressScope = 0;
          print_policy.PrintCanonicalTypes = 1;
          print_policy.IncludeNewlines = 0;
          print_policy.Indentation = 0;
          print_policy.TerseOutput = 1;

          std::string fully_qualified_name;
          llvm::raw_string_ostream stream(fully_qualified_name);
          typeDecl->print(stream, print_policy);

          llvm::outs() << fully_qualified_name << "\n";
        }
      }
    }
  }
}

} // namespace clang::tidy::misc
