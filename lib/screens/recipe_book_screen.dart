import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';
import 'brewing_station_screen.dart';

class RecipeBookScreen extends StatelessWidget {
  const RecipeBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('📖 Barista Tarif Rehberi'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: CoffeeRecipe.allRecipes.length,
          itemBuilder: (context, index) {
            final recipe = CoffeeRecipe.allRecipes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 1.5),
              ),
              child: ExpansionTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldenCrema),
                  ),
                  child: Center(
                    child: Text(recipe.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  recipe.turkishName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  '${recipe.brewMethod.displayName} • ${recipe.basePrice} ₺',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    recipe.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Recipe specs table
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow('Çekirdek', recipe.defaultBean.displayName.split('(').first.trim()),
                        _buildSpecRow('Öğütme', recipe.idealGrind.displayName.split('(').first.trim()),
                        _buildSpecRow('Süt', recipe.idealMilk.displayName),
                        _buildSpecRow('Köpük', recipe.idealFoam.displayName),
                        if (recipe.idealSyrup != SyrupType.none)
                          _buildSpecRow('Şurup', recipe.idealSyrup.displayName),
                        if (recipe.idealTopping != ToppingType.none)
                          _buildSpecRow('Süsleme', recipe.idealTopping.displayName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Brew button
                  ElevatedButton.icon(
                    onPressed: () {
                      SoundService().playClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BrewingStationScreen(
                            targetRecipe: recipe,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.coffee),
                    label: const Text('BU TARİFİ HAZIRLA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldenCrema,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
