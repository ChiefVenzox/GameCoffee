import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class DailyMenuDialog extends StatelessWidget {
  const DailyMenuDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();
    final gameState = GameState();

    return ListenableBuilder(
      listenable: expedition,
      builder: (context, _) {
        final allRecipes = CoffeeRecipe.allRecipes;

        return AlertDialog(
          backgroundColor: const Color(0xFF1B241C), // Chalkboard dark green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8D5B4C), width: 3), // Wooden frame border
          ),
          title: Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'GÜNÜN KARAVAN MENÜSÜ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.warmMilk,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Tezgahta sunulacak kahveleri seçin (1 - 5 adet)',
                      style: TextStyle(fontSize: 11, color: AppColors.lightCrema),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: allRecipes.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final recipe = allRecipes[index];
                final isUnlocked = gameState.isRecipeUnlocked(recipe.id);
                final isSelected = expedition.activeMenu.contains(recipe.id);

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Text(recipe.emoji, style: const TextStyle(fontSize: 24)),
                  title: Row(
                    children: [
                      Text(
                        recipe.turkishName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (recipe.isCold)
                        const Text('🧊', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  subtitle: Text(
                    isUnlocked
                        ? '${recipe.brewMethod.displayName} • ${recipe.basePrice} 💰'
                        : '🔒 Kilitli (Akademiden açılmalı)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isUnlocked ? AppColors.goldenCrema : AppColors.textMuted,
                    ),
                  ),
                  trailing: isUnlocked
                      ? Checkbox(
                          value: isSelected,
                          activeColor: AppColors.goldenCrema,
                          checkColor: Colors.black,
                          onChanged: (val) {
                            SoundService().playClick();
                            final success = expedition.toggleMenuRecipe(recipe.id);
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Menüde en az 1, en fazla 5 kahve bulunmalıdır.'),
                                  duration: Duration(milliseconds: 900),
                                ),
                              );
                            }
                          },
                        )
                      : const Icon(Icons.lock, size: 16, color: AppColors.textMuted),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenCrema,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Menüyü Onayla', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
