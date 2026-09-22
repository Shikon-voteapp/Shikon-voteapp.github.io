import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../platform/platform_utils.dart';
import '../utils/version_info.dart';

/// ドキュメント・リソース一覧およびModal Side Sheet詳細表示ウィジェット
class AdminDocumentsView extends StatelessWidget {
  const AdminDocumentsView({super.key});

  static const String manualUrl =
      'https://github.com/Shikon-voteapp/Shikon-voteapp.github.io/releases/download/Auto_v1.1/SetUpGuide.pdf';
  static const String setupWizardUrl =
      'https://github.com/Shikon-voteapp/Shikon-voteapp.github.io/releases/download/Auto_v1.1/setup.exe';
  static const String contactEmail = 'mamouna.inori@outlook.jp';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final documentItems = [
      _DocItem(
        icon: Icons.menu_book_rounded,
        title: 'マニュアルダウンロード',
        subtitle: '文化祭セットアップマニュアル(PDF)の閲覧・ダウンロード',
        tag: 'PDF',
        accentColor: const Color(0xFFE11D48),
        onTap: () => _showManualSheet(context),
      ),
      _DocItem(
        icon: Icons.install_desktop_rounded,
        title: 'セットアップウィザードのダウンロード',
        subtitle: 'Windows環境向けの自動インストーラー (setup.exe)',
        tag: 'EXE',
        accentColor: const Color(0xFF2563EB),
        onTap: () => _showSetupWizardSheet(context),
      ),
      _DocItem(
        icon: Icons.mark_email_read_rounded,
        title: 'メールで問い合わせ・機能追加の依頼',
        subtitle: '不具合報告や機能追加のご要望 ($contactEmail)',
        tag: 'Email',
        accentColor: const Color(0xFF059669),
        onTap: () => _showContactSheet(context),
      ),
      _DocItem(
        icon: Icons.info_rounded,
        title: 'バージョン情報',
        subtitle: '現在のバージョン: ${VersionInfo.version} (${VersionInfo.formattedBuildDate})',
        tag: 'v${VersionInfo.version}',
        accentColor: const Color(0xFF7C3AED),
        onTap: () => _showVersionSheet(context),
      ),
      _DocItem(
        icon: Icons.policy_rounded,
        title: 'オープンソースライセンス',
        subtitle: '使用しているサードパーティ製ライブラリのライセンス表示',
        tag: 'OSS',
        accentColor: const Color(0xFFD97706),
        onTap: () => _showLicenseSheet(context),
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダーセクション
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ドキュメント & リソース',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '各種マニュアル、インストーラー、お問い合わせ、アプリ情報',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // リストセクション
              M3ECard(
                variant: M3ECardVariant.outlined,
                borderRadius: BorderRadius.circular(20.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documentItems.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 20,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final item = documentItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: item.accentColor.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.accentColor,
                          size: 24,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: item.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              item.tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          M3EButton(
                            style: M3EButtonStyle.tonal,
                            size: M3EButtonSize.sm,
                            shape: M3EButtonShape.round,
                            onPressed: item.onTap,
                            child: const Text('詳細'),
                          ),
                        ],
                      ),
                      onTap: item.onTap,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─ 1. マニュアルダウンロード Modal side sheet ─────────────────────────
  void _showManualSheet(BuildContext context) {
    M3ESideSheet.show<void>(
      context,
      title: 'マニュアルダウンロード',
      body: _buildSheetBody(
        context,
        icon: Icons.menu_book_rounded,
        accentColor: const Color(0xFFE11D48),
        title: '文化祭セットアップマニュアル',
        description:
            '文化祭の投票システム準備・運用・集計手順、投票端末の設定方法、'
            'およびトラブルシューティングを網羅した公式PDFマニュアルです。',
        details: const [
          _SheetDetail('ドキュメント', '文化祭セットアップマニュアル'),
          _SheetDetail('ファイル形式', 'PDF'),
          _SheetDetail('対象', '管理者・受付スタッフ・機材担当'),
          _SheetDetail('配信形式', 'WebブラウザまたはPDFリーダー'),
        ],
        hint: '下のボタンを押すと、新しいタブでPDFマニュアルが開きます。ダウンロードまたは印刷してご利用ください。',
      ),
      actions: [
        Expanded(
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('マニュアルを開く'),
            onPressed: () {
              PlatformUtils.openUrl(manualUrl);
            },
          ),
        ),
      ],
    );
  }

  // ─ 2. セットアップウィザード Modal side sheet ───────────────────────
  void _showSetupWizardSheet(BuildContext context) {
    M3ESideSheet.show<void>(
      context,
      title: 'セットアップウィザード',
      body: _buildSheetBody(
        context,
        icon: Icons.install_desktop_rounded,
        accentColor: const Color(0xFF2563EB),
        title: 'Windows自動セットアップ',
        description:
            '投票端末や管理サーバーに必要なローカル環境・前提コンポーネントを'
            '自動的に構成するWindows専用インストーラーです。',
        details: const [
          _SheetDetail('ファイル名', 'setup.exe'),
          _SheetDetail('バージョン', 'Auto_v1.1'),
          _SheetDetail('対応OS', 'Windows 10 / 11 (64bit)'),
          _SheetDetail('配信元', 'GitHub Releases'),
        ],
        hint: '下のボタンを押すとGitHub Releasesから setup.exe のダウンロードが開始されます。',
      ),
      actions: [
        Expanded(
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('セットアップウィザードをダウンロード'),
            onPressed: () {
              PlatformUtils.openUrl(setupWizardUrl);
            },
          ),
        ),
      ],
    );
  }

  // ─ 3. お問い合わせ・機能追加 Modal side sheet ────────────────────────
  void _showContactSheet(BuildContext context) {
    M3ESideSheet.show<void>(
      context,
      title: 'お問い合わせ・機能追加依頼',
      body: _buildSheetBody(
        context,
        icon: Icons.mark_email_read_rounded,
        accentColor: const Color(0xFF059669),
        title: '開発者へのお問い合わせ',
        description:
            '不具合のご報告、操作に関するご質問、または追加機能・改善の要望を受け付けています。'
            'お気軽にメールにてご連絡ください。',
        details: const [
          _SheetDetail('宛先アドレス', contactEmail),
          _SheetDetail('件名', '【紫紺祭投票アプリ】お問い合わせ・機能要望'),
          _SheetDetail('対応形式', '電子メール'),
        ],
        hint: '下のボタンを押すと、お使いの端末の既定メールアプリが起動します。',
      ),
      actions: [
        Expanded(
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('メールを作成する'),
            onPressed: () {
              final subject = Uri.encodeComponent('【紫紺祭投票アプリ】お問い合わせ・機能要望');
              PlatformUtils.openUrl('mailto:$contactEmail?subject=$subject');
            },
          ),
        ),
      ],
    );
  }

  // ─ 4. バージョン情報 Modal side sheet ──────────────────────────────
  void _showVersionSheet(BuildContext context) {
    M3ESideSheet.show<void>(
      context,
      title: 'バージョン情報',
      body: _buildSheetBody(
        context,
        icon: Icons.info_rounded,
        accentColor: const Color(0xFF7C3AED),
        title: '紫紺祭投票アプリ',
        description: '現在のアプリケーションバージョン、ビルド番号、およびデータ更新日です。',
        details: [
          _SheetDetail('バージョン', VersionInfo.version),
          _SheetDetail('ビルド番号', VersionInfo.buildNumber),
          _SheetDetail('完全バージョン表記', VersionInfo.fullVersion),
          _SheetDetail('ビルド日 / 更新日', VersionInfo.formattedBuildDate),
          const _SheetDetail('プラットフォーム', 'Flutter (Web / Responsive)'),
          const _SheetDetail('デザインシステム', 'Material 3 Expressive (M3E)'),
        ],
        hint: '最新の投票項目や機能変更が反映されていない場合は、画面右上の更新ボタンまたは再読込をお試しください。',
      ),
      actions: [
        Expanded(
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('確認'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  // ─ 5. オープンソースライセンス Modal side sheet ──────────────────────
  void _showLicenseSheet(BuildContext context) {
    M3ESideSheet.show<void>(
      context,
      title: 'オープンソースライセンス',
      body: _buildSheetBody(
        context,
        icon: Icons.policy_rounded,
        accentColor: const Color(0xFFD97706),
        title: 'サードパーティ製ソフトウェア',
        description:
            '本アプリケーションは、多くのオープンソースソフトウェアおよびライブラリを活用して開発されています。'
            '各パッケージの著作権者およびライセンス条文をご確認いただけます。',
        details: const [
          _SheetDetail('フレームワーク', 'Flutter SDK (BSD-3-Clause)'),
          _SheetDetail('UIコンポーネント', 'Material 3 Expressive (M3E)'),
          _SheetDetail('バックエンド', 'Firebase Core / Cloud Firestore'),
          _SheetDetail('状態管理・ユーティリティ', 'Provider, url_launcher, excel 等'),
        ],
        hint: '下のボタンを押すと、すべての使用ライブラリおよびライセンス本文の一覧画面（showLicensePage）が開きます。',
      ),
      actions: [
        Expanded(
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            icon: const Icon(Icons.gavel_rounded, size: 18),
            label: const Text('ライセンス一覧を表示'),
            onPressed: () {
              Navigator.of(context).pop();
              showLicensePage(
                context: context,
                applicationName: '紫紺祭投票アプリ',
                applicationVersion: VersionInfo.fullVersion,
              );
            },
          ),
        ),
      ],
    );
  }

  // ─ 共通 Modal side sheet コンテンツビルダー ───────────────────────
  Widget _buildSheetBody(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
    required List<_SheetDetail> details,
    required String hint,
  }) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 上部アイコン & タイトルカード
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '詳細情報',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 説明テキスト
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // 詳細項目カード
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < details.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            details[i].label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            details[i].value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 案内ノート
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color accentColor;
  final VoidCallback onTap;

  const _DocItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.accentColor,
    required this.onTap,
  });
}

class _SheetDetail {
  final String label;
  final String value;

  const _SheetDetail(this.label, this.value);
}
