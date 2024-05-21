import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/type_checker.dart';

class ConvertToCustomScrollView extends DartAssist {
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
          !(listViewChecker.isAssignableFromType(type) ||
              columnChecker.isAssignableFromType(type))) return;

      final childrenArg = node.argumentList.namedArguments
          .firstWhereOrNull((element) => element.name.label.name == 'children');

      if (childrenArg == null) return;

      final childrenExpression = childrenArg.expression;

      if (childrenExpression is! ListLiteral) return;
      if (childrenExpression.elements.isEmpty) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to CustomScrollView',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(node.constructorName), (builder) {
          builder.write('CustomScrollView');
        });

        builder.addReplacement(range.node(childrenArg.name), (builder) {
          builder.write('slivers:');
        });

        for (final node in childrenExpression.elements) {
          if (node is! Expression) continue;

          builder.addSimpleInsertion(node.offset, 'SliverToBoxAdapter(child: ');
          builder.addSimpleInsertion(node.end, ')');
        }
      });
    });
  }
}
