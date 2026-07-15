import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/crypto_coin.dart';

class CoinTile extends StatelessWidget {
  final CryptoCoin coin;
  final VoidCallback? onTap;

  const CoinTile({super.key, required this.coin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? AppColors.positive : AppColors.negative;
    final priceFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            coin.image,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => const CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(Icons.currency_bitcoin, color: AppColors.whiteMuted),
            ),
          ),
        ),
        title: Text(
          coin.name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          coin.symbol.toUpperCase(),
          style: const TextStyle(color: AppColors.whiteMuted, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              priceFormat.format(coin.currentPrice),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
              style: TextStyle(color: changeColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}