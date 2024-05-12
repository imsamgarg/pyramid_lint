import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/dart/invert_boolean_expression.dart';
import 'src/assists/dart/swap_then_else_expression.dart';
import 'src/assists/flutter/dispose_controllers.dart';
import 'src/assists/flutter/use_edge_insets_zero.dart';
import 'src/assists/flutter/wrap_all_children_with_expanded.dart';
import 'src/assists/flutter/wrap_with_expanded.dart';
import 'src/assists/flutter/wrap_with_layout_builder.dart';
import 'src/assists/flutter/wrap_with_sliver_to_box_adapter.dart';
import 'src/assists/flutter/wrap_with_stack.dart';
import 'src/assists/flutter/wrap_with_value_listenable_builder.dart';
import 'src/lints/flutter/prefer_dedicated_media_query_method.dart';
import 'src/lints/flutter/prefer_text_rich.dart';
import 'src/lints/flutter/proper_controller_dispose.dart';
import 'src/lints/flutter/proper_expanded_and_flexible.dart';
import 'src/lints/flutter/proper_super_dispose.dart';
import 'src/lints/flutter/proper_super_init_state.dart';

/// This is the entry point of Pyramid Linter.
PluginBase createPlugin() => _PyramidLinter();

class _PyramidLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        // Flutter lints
        const PreferDedicatedMediaQueryMethod(),
        const PreferTextRich(),
        const ProperControllerDispose(),
        const ProperExpandedAndFlexible(),
        const ProperSuperDispose(),
        const ProperSuperInitState(),
      ];

  @override
  List<Assist> getAssists() => [
        // Dart assists
        InvertBooleanExpression(),
        SwapThenElseExpression(),
        // Flutter assists
        UseEdgeInsetsZero(),
        WrapWithExpanded(),
        WrapAllChildrenWithExpanded(),
        WrapWithLayoutBuilder(),
        WrapWithStack(),
        WrapWithValueListenableBuilder(),
        WrapWithSliverToBoxAdapter(),
        DisposeControllers(),
      ];
}
