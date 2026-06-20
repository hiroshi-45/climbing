import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../premium/purchase_service.dart';
import '../providers.dart';

const _benefits = [
  ('統計ダッシュボード', '月別の完登推移・グレード別成功率・苦手な壁の分析'),
  ('写真の無制限保存', '各課題に何枚でも写真を残せる'),
  ('データのエクスポート', '記録のバックアップ・書き出し'),
];

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  late Future<List<Package>> _packagesFuture;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _packagesFuture = PurchaseService.fetchPackages();
  }

  Future<void> _buy(Package package) async {
    setState(() => _busy = true);
    try {
      final ok = await PurchaseService.purchase(package);
      ref.read(premiumProvider.notifier).setPremium(ok);
      if (ok && mounted) {
        Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        _snack('購入に失敗しました: ${e.message ?? code.name}');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      final ok = await ref.read(premiumProvider.notifier).restore();
      _snack(ok ? '購入を復元しました' : '復元できる購入が見つかりませんでした');
      if (ok && mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プレミアム')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              Icons.workspace_premium,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Climb Log プレミアム',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ..._benefits.map(
              (b) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(b.$1),
                subtitle: Text(b.$2),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Package>>(
              future: _packagesFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final packages = snap.data ?? const [];
                if (packages.isEmpty) {
                  return _UnavailableNotice(
                    onDebugUnlock: kDebugMode
                        ? () {
                            ref.read(premiumProvider.notifier).setPremium(true);
                            Navigator.of(context).pop();
                          }
                        : null,
                  );
                }
                return Column(
                  children: packages
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FilledButton(
                            onPressed: () => _buy(p),
                            child: Text(
                              '${p.storeProduct.title} ・ ${p.storeProduct.priceString}',
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _restore, child: const Text('購入を復元')),
          ],
        ),
      ),
    );
  }
}

class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice({this.onDebugUnlock});
  final VoidCallback? onDebugUnlock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '現在この端末では購入プランを取得できません。\n'
              'ストア審査用の課金設定（RevenueCat / App内課金）が未構成の可能性があります。',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        if (onDebugUnlock != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onDebugUnlock,
            icon: const Icon(Icons.bug_report),
            label: const Text('（開発用）プレミアムをプレビュー'),
          ),
        ],
      ],
    );
  }
}
