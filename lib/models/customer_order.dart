import 'dart:math';
import 'coffee_recipe.dart';

class CustomerOrder {
  final String customerName;
  final String role;
  final String avatar;
  final String dialogue;
  final CoffeeRecipe recipe;
  final BeanType requestedBean;
  final MilkType requestedMilk;
  final SyrupType requestedSyrup;
  final ToppingType requestedTopping;
  final CupType requestedCup;
  final int patienceSeconds;

  const CustomerOrder({
    required this.customerName,
    required this.role,
    required this.avatar,
    required this.dialogue,
    required this.recipe,
    required this.requestedBean,
    required this.requestedMilk,
    required this.requestedSyrup,
    required this.requestedTopping,
    required this.requestedCup,
    this.patienceSeconds = 60,
  });

  static final List<Map<String, dynamic>> customerPool = [
    {
      'name': 'Deniz',
      'role': 'Yazılım Geliştirici',
      'avatar': '👩‍💻',
      'quote': 'Bütün gece kod yazdım! Bana sert, zihnimi açacak güzel bir kahve lazım!',
      'recipeId': 'espresso',
      'milk': MilkType.none,
      'syrup': SyrupType.none,
      'topping': ToppingType.none,
    },
    {
      'name': 'Mehmet Bey',
      'role': 'Eski Mahalle Sakini',
      'avatar': '👴',
      'quote': 'Evladım, şöyle köz ateşinde bol köpüklü bir Türk kahvesi yap da muhabbetimiz açılsın.',
      'recipeId': 'turkish_coffee',
      'milk': MilkType.none,
      'syrup': SyrupType.none,
      'topping': ToppingType.none,
    },
    {
      'name': 'Ayşe',
      'role': 'Üniversite Öğrencisi',
      'avatar': '🎓',
      'quote': 'Vizeler yaklaşıyor, kütüphaneye gitmeden tatlı bir Karamel Macchiato alabilir miyim?',
      'recipeId': 'caramel_macchiato',
      'milk': MilkType.whole,
      'syrup': SyrupType.vanilla,
      'topping': ToppingType.chocolateDrizzle,
    },
    {
      'name': 'Zeynep',
      'role': 'Grafik Tasarımcı & Influencer',
      'avatar': '🎨',
      'quote': 'Fotoğrafını çekip hikayemde paylaşacağım, latte art sanatına güveniyorum!',
      'recipeId': 'latte',
      'milk': MilkType.oat,
      'syrup': SyrupType.none,
      'topping': ToppingType.none,
    },
    {
      'name': 'Mert',
      'role': 'Fitness Antrenörü',
      'avatar': '🏋️',
      'quote': 'Spora girmeden önce ferahlatıcı, buzlu ve bitkisel sütlü bir soğuk latte süper olur.',
      'recipeId': 'iced_vanilla_latte',
      'milk': MilkType.almond,
      'syrup': SyrupType.vanilla,
      'topping': ToppingType.none,
    },
    {
      'name': 'Selin',
      'role': 'Kitap Çevirmeni',
      'avatar': '📚',
      'quote': 'Hava biraz serin, bol kakaolu ve sıcacık bir İtalyan Cappuccino lütfen!',
      'recipeId': 'cappuccino',
      'milk': MilkType.whole,
      'syrup': SyrupType.none,
      'topping': ToppingType.cocoa,
    },
    {
      'name': 'Kaan',
      'role': 'Müzisyen',
      'avatar': '🎸',
      'quote': 'Stüdyo kaydı öncesi enerjimi toparlayacak lezzetli bir Çikolatalı Mocha istiyorum.',
      'recipeId': 'caffe_mocha',
      'milk': MilkType.whole,
      'syrup': SyrupType.chocolate,
      'topping': ToppingType.whippedCream,
    },
    {
      'name': 'Burak',
      'role': 'Nitelikli Kahve Meraklısı',
      'avatar': '🧐',
      'quote': 'Etiyopya çekirdeklerinin meyvemsi asiditesini hissetmek istiyorum. V60 yapabilir misin?',
      'recipeId': 'v60_filter',
      'milk': MilkType.none,
      'syrup': SyrupType.none,
      'topping': ToppingType.none,
    },
  ];

  static CustomerOrder getRandomOrder([Random? random]) {
    final rng = random ?? Random();
    final data = customerPool[rng.nextInt(customerPool.length)];
    final recipe = CoffeeRecipe.allRecipes.firstWhere(
      (r) => r.id == data['recipeId'],
      orElse: () => CoffeeRecipe.allRecipes.first,
    );

    return CustomerOrder(
      customerName: data['name'] as String,
      role: data['role'] as String,
      avatar: data['avatar'] as String,
      dialogue: data['quote'] as String,
      recipe: recipe,
      requestedBean: recipe.defaultBean,
      requestedMilk: data['milk'] as MilkType,
      requestedSyrup: data['syrup'] as SyrupType,
      requestedTopping: data['topping'] as ToppingType,
      requestedCup: recipe.cupType,
      patienceSeconds: 50 + rng.nextInt(25),
    );
  }
}
