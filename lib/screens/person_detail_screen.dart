import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../l10n/strings.dart';
import '../models/person.dart';
import '../models/gift_idea.dart';
import '../services/people_store.dart';
import '../utils/app_theme.dart';
import '../widgets/birthday_picker.dart';
import '../widgets/person_avatar.dart';
import 'add_edit_person_screen.dart';
import 'add_edit_gift_screen.dart';
import 'share_person_screen.dart';

class PersonDetailScreen extends StatelessWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PeopleStore.instance,
      builder: (context, _) {
        final person = PeopleStore.instance.byId(personId);
        // Briefly null while popping after a delete.
        if (person == null) return const Scaffold();
        return _PersonDetailView(person: person);
      },
    );
  }
}

class _PersonDetailView extends StatefulWidget {
  final Person person;
  const _PersonDetailView({required this.person});

  @override
  State<_PersonDetailView> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<_PersonDetailView> {
  Person get _person => widget.person;
  final _store = PeopleStore.instance;

  Future<void> _save() => _store.update(_person);

  Future<void> _editPerson() async {
    final updated = await Navigator.push<Person>(
      context,
      MaterialPageRoute(builder: (_) => AddEditPersonScreen(person: _person)),
    );
    if (updated != null) await _store.update(updated);
  }

  void _sharePerson() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SharePersonScreen(person: _person)),
    );
  }

  Future<void> _deletePerson() async {
    final s = S.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(s.deletePersonTitle),
        content: Text(s.deletePersonBody(_person.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final nav = Navigator.of(context);
      final id = _person.id;
      nav.pop();
      await _store.delete(id);
    }
  }

  Future<void> _addGift() async {
    final gift = await Navigator.push<GiftIdea>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditGiftScreen()),
    );
    if (gift != null) {
      _person.giftIdeas.add(gift);
      await _save();
    }
  }

  Future<void> _editGift(GiftIdea gift, int index) async {
    final updated = await Navigator.push<GiftIdea>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditGiftScreen(gift: gift)),
    );
    if (updated != null) {
      _person.giftIdeas[index] = updated;
      await _save();
    }
  }

  Future<void> _deleteGift(int index) async {
    _person.giftIdeas.removeAt(index);
    await _save();
  }

  Future<void> _togglePurchased(int index) async {
    _person.giftIdeas[index] = _person.giftIdeas[index]
        .copyWith(isPurchased: !_person.giftIdeas[index].isPurchased);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final days = _person.daysUntilBirthday;
    final bday = _person.birthdayInfo;
    final gradientColors = AppTheme.cardGradientFor(
        PeopleStore.instance.people.indexWhere((p) => p.id == _person.id));
    final bg = personBackground(_person.backgroundImage);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: gradientColors[0],
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: _sharePerson,
                tooltip: s.share,
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: _editPerson,
                tooltip: s.edit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _deletePerson,
                tooltip: s.delete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(fit: StackFit.expand, children: [
                  ?bg,
                  SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PersonAvatar(
                          imageName: _person.avatarImage,
                          emoji: _person.avatarEmoji,
                          size: 72,
                          background: Colors.white.withValues(alpha: 0.25),
                          borderColor: _person.avatarImage != null
                              ? Colors.white
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _person.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (bday != null)
                                Text(
                                  '🎂 ${formatBirthday(context, bday, withYear: false)}${days != null ? ' · ${s.daysAway(days)}' : ''}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
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
                ]),
              ),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      _StatChip(
                        icon: Icons.card_giftcard_rounded,
                        label: s.ideasStat(_person.giftIdeas.length),
                        color: AppTheme.sky,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.check_circle_rounded,
                        label: s.boughtStat(_person.giftIdeas
                            .where((g) => g.isPurchased)
                            .length),
                        color: AppTheme.mint,
                      ),
                      if (_person.hasBirthdaySoon) ...[
                        const SizedBox(width: 10),
                        _StatChip(
                          icon: Icons.cake_rounded,
                          label: s.soon,
                          color: AppTheme.sunflower,
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                // Notes
                if (_person.notes != null &&
                    _person.notes!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lavender.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.lavender.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _person.notes!,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                ],

                // Gift Ideas Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Row(
                    children: [
                      Text(s.giftIdeas,
                          style:
                              Theme.of(context).textTheme.headlineMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addGift,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(s.addIdea),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.coral,
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),

          // Gift list
          if (_person.giftIdeas.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      const Text('🎁',
                          style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        s.noGiftIdeas,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.noGiftIdeasSub(_person.name),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms).scale(),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final gift = _person.giftIdeas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GiftCard(
                        gift: gift,
                        onTap: () => _editGift(gift, index),
                        onDelete: () => _deleteGift(index),
                        onTogglePurchased: () => _togglePurchased(index),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 50 * index + 250),
                          ),
                    );
                  },
                  childCount: _person.giftIdeas.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGift,
        icon: const Icon(Icons.add_rounded),
        label: Text(s.addGiftIdea),
      ).animate().scale(delay: 400.ms),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final GiftIdea gift;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePurchased;

  const _GiftCard({
    required this.gift,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePurchased,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: gift.isPurchased
                ? AppTheme.mint.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gift.isPurchased
                  ? AppTheme.mint.withValues(alpha: 0.4)
                  : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onTogglePurchased,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: gift.isPurchased
                          ? AppTheme.mint
                          : Colors.transparent,
                      border: Border.all(
                        color: gift.isPurchased
                            ? AppTheme.mint
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: gift.isPurchased
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gift.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                decoration: gift.isPurchased
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: gift.isPurchased
                                    ? Colors.grey.shade500
                                    : AppTheme.charcoal,
                              ),
                            ),
                          ),
                          if (gift.estimatedPrice != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.sunflower.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                gift.priceLabel!,
                                style: TextStyle(
                                  color: const Color(0xFF5D3000),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (gift.category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          S.of(context).categoryLabel(gift.category!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (gift.description != null &&
                          gift.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          gift.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (gift.link != null && gift.link!.isNotEmpty)
                            _InfoTag(
                              icon: Icons.link_rounded,
                              label: S.of(context).link,
                              color: AppTheme.sky,
                              onTap: () async {
                                final uri = Uri.tryParse(gift.link!);
                                if (uri != null &&
                                    await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode
                                          .externalApplication);
                                }
                              },
                            ),
                          if (gift.storeName != null &&
                              gift.storeName!.isNotEmpty)
                            _InfoTag(
                              icon: Icons.store_rounded,
                              label: gift.storeName!,
                              color: AppTheme.lavender,
                            ),
                          if (gift.storeLocation != null &&
                              gift.storeLocation!.isNotEmpty)
                            _InfoTag(
                              icon: Icons.location_on_rounded,
                              label: gift.storeLocation!,
                              color: AppTheme.peach,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _InfoTag(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
