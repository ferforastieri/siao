import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/app_brand.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/love_background.dart';
import 'package:family_ui/family_ui.dart';
import 'auth_sheet.dart';

const _androidDownloadUrl =
    'https://github.com/ferforastieri/siao/releases/latest/download/app-release.apk';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.auth,
    required this.toast,
  });

  final AuthController auth;
  final ToastController toast;

  void _openAuth(
    BuildContext context, {
    required bool register,
    String? tenantSlug,
    String? invitationToken,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (sheetContext) => AuthSheet(
        auth: auth,
        toast: toast,
        initialRegisterMode: register,
        tenantSlug: tenantSlug,
        invitationToken: invitationToken,
        onAuthenticated: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  void _openLegal(BuildContext context, String path) {
    context.push('/$path');
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final routerState = GoRouterState.of(context);
    final tenantSlug = routerState.uri.queryParameters['tenantSlug'];
    final invitationToken = routerState.uri.queryParameters['invitation'];
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;
    final showPreview = width >= 1000;

    void create() => _openAuth(
          context,
          register: true,
          tenantSlug: tenantSlug,
          invitationToken: invitationToken,
        );
    void login() => _openAuth(
          context,
          register: false,
          tenantSlug: tenantSlug,
        );

    return Scaffold(
      body: LoveBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 38 : 20,
                  isWide ? 20 : 16,
                  isWide ? 38 : 20,
                  40,
                ),
                children: [
                  _WelcomeHeader(
                    wide: isWide,
                    onLogin: login,
                  ),
                  SizedBox(height: isWide ? 54 : 34),
                  _WelcomeHero(
                    wide: isWide,
                    showPreview: showPreview,
                    onCreate: create,
                    onLogin: login,
                  ),
                  SizedBox(height: isWide ? 58 : 44),
                  _WelcomePresentation(wide: isWide),
                  SizedBox(height: isWide ? 56 : 42),
                  _WelcomePlans(
                    wide: isWide,
                    onCreate: create,
                  ),
                  SizedBox(height: isWide ? 56 : 42),
                  _WelcomeFaq(wide: isWide),
                  const SizedBox(height: 34),
                  _WelcomeFooter(
                    palette: palette,
                    onTerms: () => _openLegal(context, 'termos'),
                    onPrivacy: () => _openLegal(context, 'privacidade'),
                    onLogin: login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.wide, required this.onLogin});

  final bool wide;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return Row(
      children: [
        AppBrandLogo(width: 42, height: 42),
        const SizedBox(width: 10),
        Text(
          'Sião',
          style: TextStyle(
            color: palette.foreground,
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -.3,
          ),
        ),
        if (wide) ...[
          const SizedBox(width: 14),
          Container(
            width: 1,
            height: 18,
            color: palette.border.withValues(alpha: .55),
          ),
          const SizedBox(width: 14),
          Text(
            'Memórias e rotina em um espaço privado',
            style: TextStyle(color: palette.muted, fontSize: 13),
          ),
        ],
        const Spacer(),
        FamilyOutlinedButton.icon(
          onPressed: onLogin,
          icon: const Icon(FamilyIcons.login, size: 18),
          label: const Text('Entrar'),
        ),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({
    required this.wide,
    required this.showPreview,
    required this.onCreate,
    required this.onLogin,
  });

  final bool wide;
  final bool showPreview;
  final VoidCallback onCreate;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final copy = Column(
      crossAxisAlignment:
          showPreview ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const _WelcomeEyebrow('Um espaço só da sua família'),
        const SizedBox(height: 16),
        Text(
          'Sua família não cabe em um grupo de mensagens.',
          textAlign: showPreview ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: palette.foreground,
            fontFamily: 'Georgia',
            fontSize: showPreview ? 46 : (wide ? 40 : 31),
            height: 1.08,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Memórias, cartas, listas, localização e pequenos rituais reunidos '
            'em uma casa digital privada — com a identidade de vocês.',
            textAlign: showPreview ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              color: palette.muted,
              fontSize: wide ? 17 : 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: showPreview ? WrapAlignment.start : WrapAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            FamilyFilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(FamilyIcons.personAddAlt1Outlined),
              label: const Text('Criar minha família'),
            ),
            FamilyOutlinedButton.icon(
              onPressed: onLogin,
              icon: const Icon(FamilyIcons.login),
              label: const Text('Entrar'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: showPreview ? WrapAlignment.start : WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: const [
            FamilyChip(
              icon: FamilyIcons.lockOutline,
              label: 'Privado por família',
            ),
            FamilyChip(
              icon: FamilyIcons.blockOutlined,
              label: 'Sem anúncios',
            ),
            FamilyChip(
              icon: FamilyIcons.photoLibraryOutlined,
              label: 'Web e Android',
            ),
          ],
        ),
      ],
    );

    if (!showPreview) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: copy,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: copy),
        const SizedBox(width: 46),
        const Expanded(flex: 5, child: _WelcomePreview()),
      ],
    );
  }
}

class _WelcomePreview extends StatelessWidget {
  const _WelcomePreview();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return SizedBox(
      height: 366,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 22,
            right: 0,
            top: 6,
            height: 286,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: palette.primary.withValues(alpha: .22),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.card,
                    palette.bgEnd.withValues(alpha: .92),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: .12),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FamilyIcons.photoLibraryOutlined,
                          color: palette.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nossas memórias',
                              style: TextStyle(
                                color: palette.foreground,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '8 anos de histórias',
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FamilyIcons.favorite,
                        color: palette.primary.withValues(alpha: .7),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            palette.primary.withValues(alpha: .18),
                            palette.petal.withValues(alpha: .5),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -12,
                            bottom: -18,
                            child: Icon(
                              FamilyIcons.favorite,
                              size: 120,
                              color: palette.primary.withValues(alpha: .10),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FamilyIcons.autoAwesomeOutlined,
                                  color: palette.primary.withValues(alpha: .7),
                                  size: 26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'O dia em que tudo começou',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: palette.foreground,
                                    fontFamily: 'Georgia',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 228,
            width: 238,
            child: _MiniPreviewCard(
              icon: FamilyIcons.checklistOutlined,
              title: 'Lista do fim de semana',
              subtitle: '2 de 5 concluídos',
              color: palette.card,
            ),
          ),
          Positioned(
            right: 4,
            bottom: 0,
            width: 226,
            child: _MiniPreviewCard(
              icon: FamilyIcons.chatBubbleOutline,
              title: 'Chat da família',
              subtitle: 'Boa noite, amo vocês',
              color: palette.card,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPreviewCard extends StatelessWidget {
  const _MiniPreviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return FamilyCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: color,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: palette.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeEyebrow extends StatelessWidget {
  const _WelcomeEyebrow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 1.5,
          color: palette.primary.withValues(alpha: .55),
        ),
        const SizedBox(width: 9),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: palette.primary,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _WelcomePresentation extends StatelessWidget {
  const _WelcomePresentation({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    const points = [
      (
        FamilyIcons.photoLibraryOutlined,
        'Memórias e história',
        'Fotos, cartas, notas e a jornada da família em um só lugar.',
      ),
      (
        FamilyIcons.checklistOutlined,
        'Rotina compartilhada',
        'Listas, lembretes e pequenos rituais que aproximam.',
      ),
      (
        FamilyIcons.chatBubbleOutline,
        'Conversa e presença',
        'Chat, jogos e localização para estar perto de verdade.',
      ),
      (
        FamilyIcons.shieldOutlined,
        'Privacidade por família',
        'Cada família tem seu espaço isolado, acessível por convite.',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WelcomeEyebrow('Apresentação'),
        const SizedBox(height: 12),
        Text(
          'Um lugar para a vida de vocês.',
          style: TextStyle(
            color: palette.foreground,
            fontFamily: 'Georgia',
            fontSize: wide ? 31 : 26,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            'O Sião reúne o que a família guarda, organiza e vive junto. '
            'Sem feed, sem excesso de notificações e sem transformar a '
            'intimidade de vocês em conteúdo público.',
            style: TextStyle(color: palette.muted, fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
            return Wrap(
              spacing: 20,
              runSpacing: 18,
              children: [
                for (final point in points)
                  SizedBox(
                    width: width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(point.$1, color: palette.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                point.$2,
                                style: TextStyle(
                                  color: palette.foreground,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                point.$3,
                                style: TextStyle(
                                  color: palette.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WelcomePlans extends StatelessWidget {
  const _WelcomePlans({required this.wide, required this.onCreate});

  final bool wide;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final plans = [
      _LandingPlan(
        title: 'Free',
        price: 'R\$ 0',
        cadence: 'para sempre',
        description: 'Comece sem pagar nada.',
        features: const [
          'Todas as funções essenciais',
          'Até 10 fotos',
          'Localização em tempo real',
        ],
        action: 'Começar grátis',
        highlighted: false,
      ),
      _LandingPlan(
        title: 'Mensal',
        price: 'R\$ 30,00',
        cadence: 'por mês',
        description: 'Para viver o Sião sem limites.',
        features: const [
          'Todas as funções liberadas',
          'Fotos sem limite',
          'Cancele quando quiser',
        ],
        action: 'Criar conta e assinar',
        highlighted: true,
      ),
      _LandingPlan(
        title: 'Anual',
        price: 'R\$ 300,00',
        cadence: 'por ano',
        description: 'A melhor escolha para a família.',
        features: const [
          'Todas as funções liberadas',
          'Fotos sem limite',
          'Melhor custo-benefício',
        ],
        action: 'Criar conta e assinar',
        highlighted: false,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WelcomeEyebrow('Planos'),
        const SizedBox(height: 12),
        Text(
          'Comece no Free. Libere o restante quando quiser.',
          style: TextStyle(
            color: palette.foreground,
            fontFamily: 'Georgia',
            fontSize: wide ? 29 : 24,
            height: 1.12,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 18),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < plans.length; i++) ...[
                Expanded(child: _PlanCard(plan: plans[i], onPressed: onCreate)),
                if (i < plans.length - 1) const SizedBox(width: 14),
              ],
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < plans.length; i++) ...[
                _PlanCard(plan: plans[i], onPressed: onCreate),
                if (i < plans.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _WelcomeFaq extends StatelessWidget {
  const _WelcomeFaq({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    const questions = [
      (
        'Preciso pagar para começar?',
        'Não. O plano Free reúne as funções essenciais para a família começar '
            'a guardar memórias e organizar a rotina.',
      ),
      (
        'Outras famílias veem o que eu publico?',
        'Não. Cada família tem um espaço isolado. Nada do que vocês guardam '
            'aparece para outras famílias.',
      ),
      (
        'Posso participar de mais de uma família?',
        'Sim. A mesma conta pode participar de várias famílias e alternar '
            'entre elas sem criar outro cadastro.',
      ),
      (
        'Funciona no celular e no computador?',
        'Sim. O Sião abre no navegador e também está disponível para Android, '
            'com a mesma conta e as mesmas memórias.',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WelcomeEyebrow('Dúvidas'),
        const SizedBox(height: 12),
        Text(
          'Perguntas frequentes.',
          style: TextStyle(
            color: palette.foreground,
            fontFamily: 'Georgia',
            fontSize: wide ? 29 : 24,
            height: 1.12,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final item in questions)
                  SizedBox(
                    width: width,
                    child: FamilyCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              color: palette.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            item.$2,
                            style: TextStyle(
                              color: palette.muted,
                              height: 1.45,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LandingPlan {
  const _LandingPlan({
    required this.title,
    required this.price,
    required this.cadence,
    required this.description,
    required this.features,
    required this.action,
    required this.highlighted,
  });

  final String title;
  final String price;
  final String cadence;
  final String description;
  final List<String> features;
  final String action;
  final bool highlighted;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onPressed});

  final _LandingPlan plan;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return FamilyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (plan.highlighted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Popular',
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan.price,
            style: TextStyle(
              color: palette.primary,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(plan.cadence, style: TextStyle(color: palette.muted)),
          const SizedBox(height: 8),
          Text(plan.description, style: TextStyle(color: palette.muted)),
          const SizedBox(height: 16),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(FamilyIcons.check, color: palette.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(color: palette.foreground, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FamilyFilledButton(
              onPressed: onPressed,
              child: Text(plan.action),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeFooter extends StatelessWidget {
  const _WelcomeFooter({
    required this.palette,
    required this.onTerms,
    required this.onPrivacy,
    required this.onLogin,
  });

  final AppPalette palette;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onLogin;

  Future<void> _downloadAndroid() => launchUrl(
        Uri.parse(_androidDownloadUrl),
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          '© 2026 Sião',
          style: TextStyle(color: palette.muted, fontSize: 12),
        ),
        const SizedBox(width: 8),
        _FooterLink(label: 'Termos', onTap: onTerms),
        _FooterLink(label: 'Privacidade', onTap: onPrivacy),
        _FooterLink(label: 'Baixar para Android', onTap: _downloadAndroid),
        _FooterLink(label: 'Entrar', onTap: onLogin),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      child: Text(label),
    );
  }
}
