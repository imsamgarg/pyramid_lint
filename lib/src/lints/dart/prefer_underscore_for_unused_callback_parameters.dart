import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/visitors.dart';

class PreferUnderscoreForUnusedCallbackParameters extends DartLintRule {
  const PreferUnderscoreForUnusedCallbackParameters() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_underscore_for_unused_callback_parameters',
    problemMessage: 'The callback parameter is not used.',
    correctionMessage: 'Consider using underscores for the unused parameter.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionExpression((node) {
      final parameters = node.parameters?.parameters;
      if (parameters == null) return;

      for (final parameter in parameters) {
        final parameterElement = parameter.declaredElement;
        if (parameterElement == null) continue;

        final parameterName = parameterElement.name;
        if (containsOnlyUnderscores(parameterName)) continue;

        var isParameterReferenced = false;
        final v = RecursiveSimpleIdentifierVisitor(
          onVisitSimpleIdentifier: (node) {
            if (node.staticElement == parameterElement) {
              isParameterReferenced = true;
            }
          },
        );

        node.body.accept(v);

        if (isParameterReferenced) continue;

        reporter.reportErrorForElement(code, parameterElement);
      }
    });
  }

  bool containsOnlyUnderscores(String input) {
    return RegExp(r'^_+$').hasMatch(input);
  }
}
