import 'dart:async';
import 'package:flutter/material.dart';
import '../models/customer_order.dart';
import '../utils/app_colors.dart';

class CustomerDialogueWidget extends StatefulWidget {
  final CustomerOrder order;
  final VoidCallback onTimeExpired;

  const CustomerDialogueWidget({
    super.key,
    required this.order,
    required this.onTimeExpired,
  });

  @override
  State<CustomerDialogueWidget> createState() => _CustomerDialogueWidgetState();
}

class _CustomerDialogueWidgetState extends State<CustomerDialogueWidget> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.order.patienceSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onTimeExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / widget.order.patienceSeconds;
    final timerColor = progress > 0.5
        ? Colors.greenAccent
        : (progress > 0.25 ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Customer Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldenCrema, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    widget.order.avatar,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.order.role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Patience Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: timerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: timerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: timerColor),
                    const SizedBox(width: 4),
                    Text(
                      '${_remainingSeconds}s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Speech Bubble
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x22F59E0B)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('“', style: TextStyle(fontSize: 20, color: AppColors.goldenCrema, height: 1)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.order.dialogue,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Order Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warmCoffee,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.order.recipe.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Sipariş: ${widget.order.recipe.turkishName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenCrema,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Ücret: ${widget.order.recipe.basePrice} ₺',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
