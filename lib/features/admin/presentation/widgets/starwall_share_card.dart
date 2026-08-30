import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/data/models/advisor_rank_model.dart';
import 'package:intl/intl.dart';

class StarwallShareCard extends StatelessWidget {
  final List<AdvisorRankModel> advisors;
  final String categoryTitle;

  const StarwallShareCard({
    super.key,
    required this.advisors,
    required this.categoryTitle,
  });

  String _getStatLabel(AdvisorRankModel adv) {
    if (categoryTitle.toLowerCase().contains('sales')) {
      return adv.formattedRevenue;
    } else if (categoryTitle.toLowerCase().contains('recruitment')) {
      return '${adv.teamSize} TEAM';
    } else {
      return '${adv.siteVisits} VISITS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topThree = advisors.take(3).toList();
    final others = advisors.skip(3).take(7).toList();

    // Card rendered at 540×960, captured at pixelRatio=2 → 1080×1920 PNG
    const double W = 540;
    const double H = 960;

    return UnconstrainedBox(
      child: SizedBox(
        width: W,
        height: H,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF1B3A4B), Color(0xFF2C5364)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── HEADER ──────────────────────────────────────────────
              _buildHeader(),

              // ─── PODIUM (Top 3) ───────────────────────────────────────
              // Fixed height so bars never overflow
              SizedBox(
                height: 330,
                child: _buildPodium(topThree),
              ),

              const SizedBox(height: 10),

              // ─── RANK LIST (4–10) ─────────────────────────────────────
              Expanded(
                child: _buildRankList(others),
              ),

              // ─── FOOTER ───────────────────────────────────────────────
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/logos/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRARAMBH INFRA',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'TOP 10 STARWALL',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Text(
              categoryTitle.toUpperCase(),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PODIUM
  // Bar heights (explicit px):  1st=160  2nd=110  3rd=80
  // Order in row:               2nd | 1st | 3rd
  // ════════════════════════════════════════════════════════════════
  Widget _buildPodium(List<AdvisorRankModel> top) {
    // bar heights define the step-podium look
    const double barH1 = 160; // gold
    const double barH2 = 110; // silver
    const double barH3 = 80;  // bronze

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place – Silver
          if (top.length >= 2)
            Expanded(
              child: _PodiumColumn(
                advisor: top[1],
                rank: 2,
                color: const Color(0xFFC0C0C0),
                avatarSize: 76,
                barHeight: barH2,
                nameFontSize: 13,
                statFontSize: 13,
                statLabel: _getStatLabel(top[1]),
              ),
            ),
          // 1st place – Gold (centre, tallest)
          if (top.isNotEmpty)
            Expanded(
              child: _PodiumColumn(
                advisor: top[0],
                rank: 1,
                color: const Color(0xFFFFD700),
                avatarSize: 92,
                barHeight: barH1,
                nameFontSize: 15,
                statFontSize: 15,
                statLabel: _getStatLabel(top[0]),
              ),
            ),
          // 3rd place – Bronze
          if (top.length >= 3)
            Expanded(
              child: _PodiumColumn(
                advisor: top[2],
                rank: 3,
                color: const Color(0xFFCD7F32),
                avatarSize: 70,
                barHeight: barH3,
                nameFontSize: 12,
                statFontSize: 12,
                statLabel: _getStatLabel(top[2]),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // RANK LIST 4–10
  // ════════════════════════════════════════════════════════════════
  Widget _buildRankList(List<AdvisorRankModel> others) {
    if (others.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: others.asMap().entries.map((entry) {
          final isLast = entry.key == others.length - 1;
          return Column(
            children: [
              _buildListRow(entry.value, entry.key + 4),
              if (!isLast)
                Divider(
                  color: Colors.white.withValues(alpha: 0.07),
                  height: 1,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListRow(AdvisorRankModel adv, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              '#$rank',
              style: GoogleFonts.montserrat(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: ClipOval(
              child: adv.profilePhoto != null && adv.profilePhoto!.isNotEmpty
                  ? Image.network(adv.avatarUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _listFallback(adv))
                  : _listFallback(adv),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adv.fullName.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  adv.advisorCode,
                  style: GoogleFonts.montserrat(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getStatLabel(adv),
            style: GoogleFonts.montserrat(
              color: const Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listFallback(AdvisorRankModel adv) {
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        adv.fullName.isNotEmpty ? adv.fullName[0].toUpperCase() : '?',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FOOTER
  // ════════════════════════════════════════════════════════════════
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Color(0xFFFFD700), size: 15),
          const SizedBox(width: 8),
          Text(
            'Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
            style: GoogleFonts.montserrat(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, color: Color(0xFFFFD700), size: 15),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PODIUM COLUMN WIDGET  (self-contained, no overflow possible)
// Layout from top to bottom:
//   [avatar + rank-badge]
//   [name]
//   [stat]
//   [bar — explicit SizedBox height]
// All stacked in a Column with crossAxisAlignment.end alignment
// at the bottom of the parent Row.
// ════════════════════════════════════════════════════════════════
class _PodiumColumn extends StatelessWidget {
  final AdvisorRankModel advisor;
  final int rank;
  final Color color;
  final double avatarSize;
  final double barHeight;
  final double nameFontSize;
  final double statFontSize;
  final String statLabel;

  const _PodiumColumn({
    required this.advisor,
    required this.rank,
    required this.color,
    required this.avatarSize,
    required this.barHeight,
    required this.nameFontSize,
    required this.statFontSize,
    required this.statLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ── Avatar + rank badge ──
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: rank == 1 ? 4 : 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: advisor.profilePhoto != null &&
                        advisor.profilePhoto!.isNotEmpty
                    ? Image.network(
                        advisor.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
            ),
            Positioned(
              bottom: -11,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFF0D1B2A), width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ── Name ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            advisor.fullName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: nameFontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 5),
        // ── Stat ──
        Text(
          statLabel,
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: statFontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        // ── Podium bar — EXPLICIT SizedBox, no overflow possible ──
        SizedBox(
          width: double.infinity,
          height: barHeight,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.65),
                  color.withValues(alpha: 0.15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: color.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        advisor.fullName.isNotEmpty ? advisor.fullName[0].toUpperCase() : '?',
        style: GoogleFonts.montserrat(
          fontSize: avatarSize * 0.38,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
