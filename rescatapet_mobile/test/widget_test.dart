import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescatapet_mobile/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RescataPetApp()),
    );
    await tester.pumpAndSettle();

    // Verifica que al iniciar sin sesión se muestra la pantalla de login
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
