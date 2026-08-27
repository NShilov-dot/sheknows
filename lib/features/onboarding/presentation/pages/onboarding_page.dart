import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/onboarding/data/onboarding_prefs.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/widgets/moon_cycle_indicator.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Value-first intro shown once per device before the auth screens. Each slide
/// previews the product with its real widgets (the cycle moon, the phase
/// chart) fed sample data — not a mockup, the actual thing.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  /// Guards the finish action so a double-tap can't fire it twice while the
  /// flag persists and the route swaps.
  bool _finishing = false;

  static const _slideCount = 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _slideCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_finishing) {
      return;
    }
    setState(() => _finishing = true);
    // Persist before navigating so the redirect doesn't bounce back here.
    await OnboardingPrefs.markSeen();
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLastPage = _page == _slideCount - 1;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (page) => setState(() => _page = page),
                    children: [
                      _OnboardingSlide(
                        hero: const _PredictionHero(),
                        headline: l10n.onboardingPredictHeadline,
                        subtext: l10n.onboardingPredictSubtext,
                      ),
                      _OnboardingSlide(
                        hero: const _CorrelationHero(),
                        headline: l10n.onboardingPatternsHeadline,
                        subtext: l10n.onboardingPatternsSubtext,
                      ),
                    ],
                  ),
                ),
                _BottomControls(
                  page: _page,
                  slideCount: _slideCount,
                  primaryLabel:
                      isLastPage ? l10n.onboardingGetStarted : l10n.commonNext,
                  onPrimary: _next,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l10n.commonSkip),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.hero,
    required this.headline,
    required this.subtext,
  });

  final Widget hero;
  final String headline;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              hero,
              const SizedBox(height: AppSpacing.xxl),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                subtext,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slide 1: the app's signature moon at mid-cycle — a real preview, not art.
class _PredictionHero extends StatelessWidget {
  const _PredictionHero();

  static const _sampleStats = CycleStats(
    periodCount: 4,
    averageCycleLength: 28,
    averagePeriodLength: 5,
    currentCycleDay: 16,
  );

  @override
  Widget build(BuildContext context) {
    return const MoonCycleIndicator(stats: _sampleStats, size: 140);
  }
}

/// Slide 2: the actual phase-attribution card component with sample counts.
class _CorrelationHero extends StatelessWidget {
  const _CorrelationHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.cyclePhaseLuteal, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            BarRow(
              label: l10n.symptomTypeCramps,
              value: 6,
              fraction: 0.85,
              color: primary,
            ),
            BarRow(
              label: l10n.symptomTypeFatigue,
              value: 4,
              fraction: 0.55,
              color: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.page,
    required this.slideCount,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final int page;
  final int slideCount;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slideCount; i++)
                _Dot(active: i == page),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimary,
              child: Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? scheme.primary : scheme.onSurfaceVariant.withValues(
          alpha: AppAlpha.future,
        ),
        borderRadius: BorderRadius.circular(AppRadius.swatch),
      ),
    );
  }
}
