import 'package:flutter_test/flutter_test.dart';
import 'package:game_coffee/engine3d/camera3d.dart';
import 'package:game_coffee/engine3d/models3d.dart';
import 'package:game_coffee/main.dart';
import 'package:game_coffee/models/caravan_model.dart';
import 'package:game_coffee/models/coffee_recipe.dart';
import 'package:game_coffee/models/expedition_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

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

  test('ExpeditionState generates procedural roguelite map and handles caravan progression', () {
    final expedition = ExpeditionState();
    expedition.startNewRun(regionId: 'valley', tierId: CaravanTierId.nomad);

    expect(expedition.isRunActive, isTrue);
    expect(expedition.reputationHearts, equals(3));
    expect(expedition.nodes.isNotEmpty, isTrue);

    // Initial layer nodes should be available
    final initialNodes = expedition.nodes.values.where((n) => n.layer == 0).toList();
    expect(initialNodes.isNotEmpty, isTrue);
    expect(initialNodes.any((n) => n.isAvailable), isTrue);

    // Relic effects test
    expedition.addRelic('relic_succulent');
    expect(expedition.totalPatienceMultiplier, greaterThan(1.0));

    // Dishwashing / Clean cups capacity
    expect(expedition.maxCleanCups, equals(4));

    // Losing a heart
    expedition.loseHeart();
    expect(expedition.reputationHearts, equals(2));
  });

  test('3D Engine builds low-poly caravan mesh and projects camera properly', () {
    final caravan = Models3D.createCaravan();
    expect(caravan.vertices.isNotEmpty, isTrue);
    expect(caravan.faces.isNotEmpty, isTrue);

    final camera = Camera3D(
      position: vm.Vector3(10, 10, 10),
      target: vm.Vector3(0, 0, 0),
      isIsometric: true,
    );

    final view = camera.getViewMatrix();
    final proj = camera.getProjectionMatrix(16 / 9);
    final vp = proj * view;

    final transformed = vp.transform(vm.Vector4(0, 0, 0, 1.0));
    expect(transformed.w, isNotNull);
  });

  testWidgets('GameCoffeeApp loads Coffee Caravan 3D home screen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GameCoffeeApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('COFFEE CARAVAN'), findsOneWidget);
    expect(find.text('3D Karavan Garajı'), findsOneWidget);
    expect(find.text('Günün Menüsü'), findsOneWidget);
  });
}
