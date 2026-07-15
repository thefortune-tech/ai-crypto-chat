import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/crypto_coin.dart';
import '../providers/crypto_providers.dart';
import '../widgets/coin_tile.dart';
import '../widgets/error_view.dart';
import 'coin_detail_page.dart';

class CoinListPage extends ConsumerWidget {
  const CoinListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinsAsync = ref.watch(topCoinsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(topCoinsProvider);
          await ref.read(topCoinsProvider.future);
        },
        child: coinsAsync.when(
          data: (coins) => _CoinListView(coins: coins),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (error, stackTrace) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(topCoinsProvider),
          ),
        ),
      ),
    );
  }
}

class _CoinListView extends StatelessWidget {
  final List<CryptoCoin> coins;

  const _CoinListView({required this.coins});

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const Center(
        child: Text(
          'No coins found',
          style: TextStyle(color: AppColors.whiteMuted),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: coins.length,
      itemBuilder: (context, index) {
        final coin = coins[index];
        return CoinTile(
          coin: coin,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CoinDetailPage(coinId: coin.id),
              ),
            );
          },
        );
      },
    );
  }
}