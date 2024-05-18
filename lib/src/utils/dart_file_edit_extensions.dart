import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'dart_type_extension.dart';

extension DartFileEditBuilderExtension on DartFileEditBuilder {
  void removeVariableDeclaration(VariableDeclaration declaration) {
    final declarations =
        (declaration.parent! as VariableDeclarationList).variables;
    final index = declarations.indexOf(declaration);
    if (index == -1) return;

    if (index == 0) {
      if (declarations.length == 1) {
        final statement =
            declaration.thisOrAncestorOfType<VariableDeclarationStatement>();
        if (statement == null) return;

        addDeletion(range.deletionRange(statement));
      } else {
        final succeedingComma = declaration.endToken.next;
        if (succeedingComma == null) return;

        addDeletion(range.startEnd(declaration, succeedingComma));
      }
    } else {
      final precedingComma = declaration.beginToken.previous;
      if (precedingComma == null) return;

      addDeletion(range.startEnd(precedingComma, declaration));
    }
  }

  void addPositionalParameter(
    FormalParameterList parameterList,
    DartType parameterType,
    String parameterName,
  ) {
    final positionalParams =
        parameterList.parameters.where((e) => e.isPositional);
    final namedParams = parameterList.parameters.where((e) => e.isNamed);

    switch ((positionalParams.isEmpty, namedParams.isEmpty)) {
      case (true, true):
        final offset = parameterList.leftParenthesis.end;
        addInsertion(offset, (builder) {
          builder.writeType(parameterType);
          builder.write(' $parameterName');
        });
      case (true, false):
        final offset = parameterList.leftParenthesis.end;
        addInsertion(offset, (builder) {
          builder.writeType(parameterType);
          builder.write(' $parameterName, ');
        });
      case (false, true) || (false, false):
        final offset = positionalParams.last.end;
        addInsertion(offset, (builder) {
          builder.write(', ');
          builder.writeType(parameterType);
          builder.write(' $parameterName');
        });
    }
  }

  void addNamedParameter(
    FormalParameterList parameterList,
    DartType parameterType,
    String parameterName,
  ) {
    final namedParams = parameterList.parameters.where((e) => e.isNamed);
    final positionalParams =
        parameterList.parameters.where((e) => e.isPositional);
    final isRequired = !parameterType.isNullable;

    switch ((positionalParams.isEmpty, namedParams.isEmpty)) {
      case (true, true):
        final offset = parameterList.leftParenthesis.end;
        addInsertion(offset, (builder) {
          builder.write('{');
          if (isRequired) builder.write('required ');
          builder.writeType(parameterType);
          builder.write(' $parameterName}');
        });
      case (false, true):
        final offset = positionalParams.last.end;
        final nextToken = positionalParams.last.endToken.next;
        final hasTrailingComma =
            nextToken != null && nextToken.type == TokenType.COMMA;

        if (hasTrailingComma) {
          addInsertion(nextToken.end, (builder) {
            builder.write(' {');
            if (isRequired) builder.write('required ');
            builder.writeType(parameterType);
            builder.write(' $parameterName,}');
          });
        } else {
          addInsertion(offset, (builder) {
            builder.write(', {');
            if (isRequired) builder.write('required ');
            builder.writeType(parameterType);
            builder.write(' $parameterName}');
          });
        }
      case (true, false) || (false, false):
        final offset = namedParams.last.end;
        addInsertion(offset, (builder) {
          builder.write(', ');
          if (isRequired) builder.write('required ');
          builder.writeType(parameterType);
          builder.write(' $parameterName');
        });
    }
  }
}
