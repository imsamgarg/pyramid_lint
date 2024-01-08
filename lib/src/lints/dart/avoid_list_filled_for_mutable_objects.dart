import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class AvoidListFilledForMutableObjects extends DartLintRule {
  const AvoidListFilledForMutableObjects() : super(code: _code);

  static const name = 'prefer_list_generate_for_mutable_objects';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Using List.filled for possible mutable objects will ',
    correctionMessage: 'Consider using List.generate instead.',
    url: '$docUrl#${AvoidListFilledForMutableObjects.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final conName = node.constructorName;

      const listTypeChecker = TypeChecker.fromName('List');

      if (!listTypeChecker.isExactlyType(node.staticType!)) return;

      if (conName.name?.name != 'filled') {
        return;
      }

      final args = node.argumentList.arguments;

      if (args.length <= 1) return;

      final arg = args.whereNot((e) => e is NamedExpression).elementAtOrNull(1);

      switch (arg) {
        case null:
        case Literal():
        case InstanceCreationExpression() when arg.isConst:
          return;

        case SimpleIdentifier():
          final elem = arg.staticElement;
          if (elem == null) return;

          if (elem is VariableElement && elem.isConst) return;
          if (elem is PropertyAccessorElement && elem.variable.isConst) return;
      }

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [];
}
