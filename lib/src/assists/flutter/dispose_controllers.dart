import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class DisposeControllers extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addClassDeclaration((node) {
      final members = node.members;

      final controllersToBeDisposed =
          members.fieldDeclarations.expand((e) => e.fields.variables).where(
                (e) => disposableControllerChecker
                    .isAssignableFrom(e.declaredElement!),
              );

      if (controllersToBeDisposed.isEmpty) return;

      final disposeMethod = members.findMethodDeclarationByName('dispose');
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Dispose controller',
        priority: 80,
      );

      for (final field in controllersToBeDisposed) {
        final toBeDisposedControllerName = field.name.lexeme;

        switch (disposeMethod?.body) {
          case null:
            _handleNullFunctionBody(
              node,
              field,
              toBeDisposedControllerName,
              changeBuilder,
            );
          case final BlockFunctionBody body:
            _handleBlockFunctionBody(
              body,
              toBeDisposedControllerName,
              changeBuilder,
            );
          case final ExpressionFunctionBody body:
            _handleExpressionFunctionBody(
              body,
              toBeDisposedControllerName,
              changeBuilder,
            );
          case EmptyFunctionBody() || NativeFunctionBody():
        }
      }
    });
  }

  void _handleNullFunctionBody(
    ClassDeclaration parent,
    VariableDeclaration node,
    String toBeDisposedControllerName,
    ChangeBuilder changeBuilder,
  ) {
    final initStateMethod = parent.members.findMethodDeclarationByName(
      'initState',
    );

    final buildMethod = parent.members.findMethodDeclarationByName('build');

    final (int offset, bool addNewLineAtTheStart, bool addNewLineAtTheEnd) =
        switch ((initStateMethod, buildMethod)) {
      (null, null) => (node.end, true, false),
      (null, final buildMethod?) => (buildMethod.offset, true, true),
      (final initStateMethod?, null) => (initStateMethod.end, true, false),
      (final _?, final buildMethod?) => (buildMethod.offset, false, true),
    };

    changeBuilder.addDartFileEdit((builder) {
      builder.addInsertion(offset, (builder) {
        if (addNewLineAtTheStart) builder.write('\n');
        builder.write('  @override\n');
        builder.write('  void dispose() {\n');
        builder.write('    $toBeDisposedControllerName.dispose();\n');
        builder.write('    super.dispose();\n');
        builder.write('  }\n');
        if (addNewLineAtTheEnd) builder.write('\n');
      });
    });
  }

  void _handleBlockFunctionBody(
    BlockFunctionBody disposeFunctionBody,
    String toBeDisposedControllerName,
    ChangeBuilder changeBuilder,
  ) {
    final statements = disposeFunctionBody.block.statements;
    final disposeStatementTargetNames =
        _getDisposeStatementTargetNames(statements);

    if (!disposeStatementTargetNames.contains(toBeDisposedControllerName)) {
      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(disposeFunctionBody.beginToken.end, (builder) {
          builder.write('\n    $toBeDisposedControllerName.dispose();');
        });
      });
    }
  }

  void _handleExpressionFunctionBody(
    ExpressionFunctionBody disposeFunctionBody,
    String toBeDisposedControllerName,
    ChangeBuilder changeBuilder,
  ) {
    changeBuilder.addDartFileEdit((builder) {
      builder.addReplacement(disposeFunctionBody.sourceRange, (builder) {
        builder.writeln('{');
        builder.writeln('    $toBeDisposedControllerName.dispose();');
        builder.writeln('    ${disposeFunctionBody.expression.toSource()};');
        builder.write('  }');
      });
    });
  }
}

Iterable<String> _getDisposeStatementTargetNames(
  NodeList<Statement> statements,
) {
  return statements.expressionStatements
      .map((e) => e.expression)
      .whereType<MethodInvocation>()
      .map(_getTargetNameOfDisposeMethodInvocation)
      .whereNotNull();
}

String? _getTargetNameOfDisposeMethodInvocation(
  MethodInvocation invocation,
) {
  final target = invocation.target;
  if (target is! SimpleIdentifier) return null;

  final methodName = invocation.methodName.name;
  if (methodName != 'dispose') return null;

  return target.name;
}
