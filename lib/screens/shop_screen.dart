import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/shop_item.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopCategory _selectedCategory = ShopCategory.beans;
  late List<ShopItem> _items;

  @override
  void initState() {
    super.initState();
    _items = ShopItem.defaultItems;
    _syncUnlocked();
  }

  void _syncUnlocked() {
    final state = GameState();
    for (final item in _items) {
      if (state.isItemUnlocked(item.id)) {
        item.isUnlocked = true;
      }
    }
  }

  void _buyItem(ShopItem item) {
    final state = GameState();
    if (state.coins < item.price) {
      SoundService().playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yetersiz Para! Daha fazla kahve yaparak bahşiş topla.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = state.buyItem(item);
    if (success) {
      SoundService().playSuccess();
      setState(() {
        item.isUnlocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} başarıyla satın alındı! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = GameState();
    final filteredItems = _items.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('🛍️ Barista Mağazası'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldenCrema),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                ListenableBuilder(
                  listenable: state,
                  builder: (context, _) => Text(
                    '${state.coins} ₺',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildCategoryTab(ShopCategory.beans, '🫘 Çekirdekler'),
                  const SizedBox(width: 8),
                  _buildCategoryTab(ShopCategory.equipment, '⚙️ Ekipmanlar'),
                  const SizedBox(width: 8),
                  _buildCategoryTab(ShopCategory.cups, '☕ Fincanlar'),
                  const SizedBox(width: 8),
                  _buildCategoryTab(ShopCategory.syrups, '🍯 Şuruplar'),
                ],
              ),
            ),

            // Item Grid
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isUnlocked = state.isItemUnlocked(item.id) || item.isUnlocked;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isUnlocked ? Colors.green.withValues(alpha: 0.3) : AppColors.borderSubtle,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon Box
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Center(
                            child: Text(item.icon, style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warmCoffee,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.bonusEffect,
                                  style: const TextStyle(fontSize: 11, color: AppColors.goldenCrema, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Buy / Owned Button
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              'Sahipsin ✓',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _buyItem(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldenCrema,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              '${item.price} ₺',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(ShopCategory category, String title) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (_) {
        SoundService().playClick();
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: AppColors.goldenCrema,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.bgCard,
    );
  }
}
