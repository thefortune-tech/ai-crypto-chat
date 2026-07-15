import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../providers/crypto_providers.dart';
import '../widgets/error_view.dart';

class CoinDetailPage extends ConsumerWidget {
  final String coinId;

  const CoinDetailPage({super.key, required this.coinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinAsync = ref.watch(coinByIdProvider(coinId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Coin Details', style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: coinAsync.when(
        data: (coin) {
          final isPositive = coin.priceChangePercentage24h >= 0;
          final changeColor = isPositive ? AppColors.positive : AppColors.negative;
          final priceFormat = NumberFormat.currency(symbol: '\$');

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.network(coin.image, width: 64, height: 64),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    coin.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    coin.symbol.toUpperCase(),
                    style: const TextStyle(color: AppColors.whiteMuted, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
                _DetailRow(
                  label: 'Current Price',
                  value: priceFormat.format(coin.currentPrice),
                  valueColor: AppColors.white,
                ),
                _DetailRow(
                  label: '24h Change',
                  value:
                      '${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                  valueColor: changeColor,
                ),
                _DetailRow(
                  label: 'Market Cap',
                  value: priceFormat.format(coin.marketCap),
                  valueColor: AppColors.white,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, stackTrace) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(coinByIdProvider(coinId)),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.whiteMuted, fontSize: 15)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}