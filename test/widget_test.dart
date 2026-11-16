import 'package:flutter_test/flutter_test.dart';
import 'package:game_coffee/main.dart';
import 'package:game_coffee/models/coffee_recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CoffeeRecipe evaluation calculates score and stars accurately', () {
    final turkishRecipe = CoffeeRecipe.allRecipes.firstWhere((r) => r.id == 'turkish_coffee');

    final perfectScore = turkishRecipe.evaluate(
      selectedBean: BeanType.turkishRoast,
      selectedGrind: GrindLevel.extraFine,
      extractionAccuracy: 1.0,
      selectedMilk: MilkType.none,
      selectedFoam: FoamLevel.none,
      selectedSyrup: SyrupType.none,
      selectedTopping: ToppingType.none,
      selectedCup: CupType.turkishCup,
    );

    expect(perfectScore.totalScore, greaterThanOrEqualTo(90));
    expect(perfectScore.stars, equals(5));
  });

  testWidgets('GameCoffeeApp loads home screen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GameCoffeeApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('BARISTA MASTER'), findsOneWidget);
    expect(find.text('MÜŞTERİ MODU (KARİYER)'), findsOneWidget);
  });
}
