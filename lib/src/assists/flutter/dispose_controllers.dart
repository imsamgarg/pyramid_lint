import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
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
      final sourceRange = node.name.sourceRange;
      if (!sourceRange.covers(target)) return;

      final members = node.members;

      final superClass = node.extendsClause?.superclass;

      if (superClass == null) return;

      if (!(disposableControllerChecker
              .isAssignableFromType(superClass.type!) ||
          widgetStateChecker.isAssignableFromType(superClass.type!))) {
        return;
      }

      final controllersToBeDisposed =
          members.fieldDeclarations.expand((e) => e.fields.variables).where(
        (e) {
          return disposableControllerChecker
              .isAssignableFromType(e.declaredElement!.type);
        },
      );

      if (controllersToBeDisposed.isEmpty) return;

      final disposeMethod = members.findMethodDeclarationByName('dispose');
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Dispose all controllers',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        switch (disposeMethod?.body) {
          case null:
            _handleNullFunctionBody(
              node,
              controllersToBeDisposed.toList(),
              builder,
            );
          case final BlockFunctionBody body:
            _handleBlockFunctionBody(
              body,
              controllersToBeDisposed.toList(),
              builder,
            );
          case final ExpressionFunctionBody body:
            _handleExpressionFunctionBody(
              body,
              controllersToBeDisposed.toList(),
              builder,
            );
          case EmptyFunctionBody() || NativeFunctionBody():
        }
      });
    });
  }

  void _handleNullFunctionBody(
    ClassDeclaration parent,
    List<VariableDeclaration> node,
    DartFileEditBuilder builder,
  ) {
    final initStateMethod = parent.members.findMethodDeclarationByName(
      'initState',
    );

    final buildMethod = parent.members.findMethodDeclarationByName('build');

    final (int offset, bool addNewLineAtTheStart, bool addNewLineAtTheEnd) =
        switch ((initStateMethod, buildMethod)) {
      (null, null) => (node.last.end, true, false),
      (null, final buildMethod?) => (buildMethod.offset, true, true),
      (final initStateMethod?, null) => (initStateMethod.end, true, false),
      (final _?, final buildMethod?) => (buildMethod.offset, false, true),
    };

    final toBeDisposedControllers =
        node.map((e) => '${e.name.lexeme}.dispose()').join(';\n ');

    builder.addInsertion(offset, (builder) {
      if (addNewLineAtTheStart) builder.write('\n');
      builder.write('  @override\n');
      builder.write('  void dispose() {\n');
      builder.write('    $toBeDisposedControllers;\n');
      builder.write('    super.dispose();\n');
      builder.write('  }\n');
      if (addNewLineAtTheEnd) builder.write('\n');
    });
  }

  void _handleBlockFunctionBody(
    BlockFunctionBody disposeFunctionBody,
    List<VariableDeclaration> variables,
    DartFileEditBuilder builder,
  ) {
    final statements = disposeFunctionBody.block.statements;
    final disposeStatementTargetNames =
        _getDisposeStatementTargetNames(statements);

    for (final variable in variables) {
      if (!disposeStatementTargetNames.contains(variable.name.lexeme)) {
        builder.addInsertion(disposeFunctionBody.beginToken.end, (builder) {
          builder.write('\n    ${variable.name.lexeme}.dispose();');
        });
      }
    }
  }

  void _handleExpressionFunctionBody(
    ExpressionFunctionBody disposeFunctionBody,
    List<VariableDeclaration> variables,
    DartFileEditBuilder builder,
  ) {
    final toBeDisposedControllers =
        variables.map((e) => '${e.name.lexeme}.dispose()').join(';\n ');

    builder.addReplacement(disposeFunctionBody.sourceRange, (builder) {
      builder.writeln('{');
      builder.writeln('    $toBeDisposedControllers;\n');
      builder.writeln('    ${disposeFunctionBody.expression.toSource()};');
      builder.write('  }');
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
