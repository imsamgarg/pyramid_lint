import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/dart_file_edit_extensions.dart';

class ExtractVariableToParameter extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addVariableDeclaration((node) {
      if (!node.sourceRange.covers(target)) return;

      final paramList = _getParameterList(node);
      if (paramList == null) return;

      final variableName = node.name.lexeme;

      final paramAlreadyExists =
          paramList.parameters.any((e) => e.name?.lexeme == variableName);
      if (paramAlreadyExists) return;

      final positionalParamChangeBuilder = reporter.createChangeBuilder(
        message: 'Extract variable as parameter',
        priority: 79,
      );

      final namedParamChangeBuilder = reporter.createChangeBuilder(
        message: 'Extract variable as named parameter',
        priority: 80,
      );

      final variableType = node.declaredElement!.type;

      positionalParamChangeBuilder.addDartFileEdit((builder) {
        builder.addPositionalParameter(
          paramList,
          variableType,
          variableName,
        );

        builder.removeVariableDeclaration(node);
      });

      namedParamChangeBuilder.addDartFileEdit((builder) {
        builder.addNamedParameter(paramList, variableType, variableName);
        builder.removeVariableDeclaration(node);
      });
    });
  }

  FormalParameterList? _getParameterList(VariableDeclaration node) {
    final elem = node.declaredElement;
    if (elem == null || elem is! LocalVariableElement) return null;

    final declaration = node.thisOrAncestorMatching(
      (e) => e is MethodDeclaration || e is FunctionDeclaration,
    );

    return switch (declaration) {
      MethodDeclaration(:final parameters) => parameters,
      FunctionDeclaration(:final functionExpression) =>
        functionExpression.parameters,
      _ => null
    };
  }
}
