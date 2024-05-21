import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/type_checker.dart';

class ConvertToTextRich extends DartAssist {
  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    context.registry.addInstanceCreationExpression((node) {
      if (!node.sourceRange.covers(target)) return;

      final type = node.staticType;

      if (type == null ||
          !textChecker.isAssignableFromType(type) ||
          node.constructorName.name?.name == 'rich') return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to Text.rich',
        priority: 80,
      );

      final strExpression = node.argumentList.arguments
          .firstWhereOrNull((e) => e is! NamedExpression);

      if (strExpression == null) return;

      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(node.constructorName), (builder) {
          builder.write('Text.rich');
        });

        builder.addReplacement(range.node(strExpression), (builder) {
          // final str = switch (strExpression) {
          //   SimpleIdentifier(:final name) => name,
          //   MethodInvocation(:) => name,
          // };

          builder.write(
            'TextSpan(children: [TextSpan(text:${strExpression.toSource()},),],)',
          );
        });
      });
    });
  }
}
