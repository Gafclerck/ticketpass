import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticketpass/main.dart';

void main() {
  testWidgets('TicketPass affiche la page des événements', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TicketPassApp()));

    await tester.pumpAndSettle();

    expect(find.text('Mes événements'), findsOneWidget);
    expect(find.text('Aucun événement pour le moment.'), findsOneWidget);
  });
}
