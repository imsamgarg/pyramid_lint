import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class ConvertToTextRich extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = node.keywordAndConstructorNameSourceRange;
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;

      if (type == null ||
          !textChecker.isAssignableFromType(type) ||
          node.constructorName.name?.name == 'rich') return;

      _convertToTextRich(node, reporter);
    });

    if (!context.pubspec.dependencies.containsKey('auto_size_text')) return;

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = node.keywordAndConstructorNameSourceRange;
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;

      if (type == null ||
          !autoSizeTextChecker.isAssignableFromType(type) ||
          node.constructorName.name?.name == 'rich') return;

      _convertToTextRich(node, reporter);
    });
  }

  void _convertToTextRich(
    InstanceCreationExpression node,
    ChangeReporter reporter,
  ) {
    final strExpression = node.argumentList.arguments
        .firstWhereOrNull((e) => e is! NamedExpression);

    if (strExpression == null) return;

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Convert to Text.rich',
      priority: 80,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleInsertion(node.constructorName.end, '.rich(');

      builder.addSimpleInsertion(
        strExpression.offset - 1,
        '[TextSpan(text: ',
      );

      builder.addSimpleInsertion(strExpression.end, ')]');
    });
  }
}
