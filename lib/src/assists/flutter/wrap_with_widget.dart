import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yaml/yaml.dart';

import '../../utils/pubspec_extensions.dart';
import '../../utils/type_checker.dart';

class WrapWithWidgetOptions {
  final List<String> singleChildWidgets;
  final List<String> multiChildWidgets;

  WrapWithWidgetOptions({
    required this.singleChildWidgets,
    required this.multiChildWidgets,
  });

  factory WrapWithWidgetOptions.fromJson(Map<String, dynamic>? json) {
    final singleChildWidgets = switch (json?['single_child_widgets']) {
      final YamlList libraries => libraries.cast<String>(),
      _ => <String>[],
    };

    final multiChildWidgets = switch (json?['multi_child_widgets']) {
      final YamlList libraries => libraries.cast<String>(),
      _ => <String>[],
    };

    return WrapWithWidgetOptions(
      singleChildWidgets: singleChildWidgets,
      multiChildWidgets: multiChildWidgets,
    );
  }
}

class WrapWithWidget extends DartAssist {
  WrapWithWidget._(this.options);

  final WrapWithWidgetOptions options;

  static const _name = 'wrap_with_widget';

  factory WrapWithWidget.fromConfig(CustomLintConfigs configs) {
    final options = WrapWithWidgetOptions.fromJson(configs.rules[_name]?.json);

    return WrapWithWidget._(options);
  }

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) async {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final sourceRange = switch (node.keyword) {
        null => node.constructorName.sourceRange,
        final keyword => range.startEnd(
            keyword,
            node.constructorName,
          ),
      };
      if (!sourceRange.covers(target)) return;

      final type = node.staticType;
      if (type == null ||
          expandedOrFlexibleChecker.isExactlyType(type) ||
          !widgetChecker.isSuperTypeOf(type)) return;

      final parentInstanceCreationExpression =
          node.parent?.thisOrAncestorOfType<InstanceCreationExpression>();
      if (parentInstanceCreationExpression == null) return;

      final parentType = parentInstanceCreationExpression.staticType;
      if (parentType == null || !flexChecker.isAssignableFromType(parentType)) {
        return;
      }

      for (final widget in options.singleChildWidgets) {
        _wrapWithSingleChildWidet(reporter, node, widget);
      }
    });
  }

  void _wrapWithSingleChildWidet(
    ChangeReporter reporter,
    InstanceCreationExpression node,
    String widget,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      message: 'Wrap with $widget',
      priority: 27,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleInsertion(
        node.offset,
        '$widget(child: ',
      );

      builder.addSimpleInsertion(
        node.end,
        ',)',
      );
    });
  }
}
