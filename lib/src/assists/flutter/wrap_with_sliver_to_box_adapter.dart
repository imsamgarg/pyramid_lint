import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/ast_node_extensions.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class WrapWithSliverToBoxAdapter extends DartAssist {
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

      if (type == null) return;
      if (!widgetChecker.isAssignableFromType(type)) return;

      final name = node.constructorName.staticElement?.displayName;
      if (name?.startsWith('Sliver') ?? true) return;

      final parent = node.parent;

      if (parent is! ListLiteral) return;
      final parentWidget =
          parent.thisOrAncestorOfType<InstanceCreationExpression>();

      if (parentWidget == null || parentWidget.staticType == null) return;

      if (!customScrolViewChecker
          .isAssignableFromType(parentWidget.staticType!)) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with SliverToBoxAdapter',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(node.offset, 'SliverToBoxAdapter(child:');
        builder.addSimpleInsertion(node.end, ')');
      });
    });
  }
}
