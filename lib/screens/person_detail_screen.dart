import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/person.dart';
import '../models/gift_idea.dart';
import '../utils/app_theme.dart';
import 'add_edit_person_screen.dart';
import 'add_edit_gift_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  final Person person;
  final Future<void> Function(Person) onUpdate;
  final Future<void> Function(String id) onDelete;

  const PersonDetailScreen({
    super.key,
    required this.person,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Person _person;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
  }

  Future<void> _editPerson() async {
    final updated = await Navigator.push<Person>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditPersonScreen(person: _person)),
    );
    if (updated != null) {
      setState(() => _person = updated);
      await widget.onUpdate(_person);
    }
  }

  Future<void> _deletePerson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Person?'),
        content: Text(
            'This will remove ${_person.name} and all their gift ideas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await widget.onDelete(_person.id);
      Navigator.pop(context);
    }
  }

  Future<void> _addGift() async {
    final gift = await Navigator.push<GiftIdea>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditGiftScreen()),
    );
    if (gift != null) {
      setState(() => _person.giftIdeas.add(gift));
      await widget.onUpdate(_person);
    }
  }

  Future<void> _editGift(GiftIdea gift, int index) async {
    final updated = await Navigator.push<GiftIdea>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditGiftScreen(gift: gift)),
    );
    if (updated != null) {
      setState(() => _person.giftIdeas[index] = updated);
      await widget.onUpdate(_person);
    }
  }

  Future<void> _deleteGift(int index) async {
    setState(() => _person.giftIdeas.removeAt(index));
    await widget.onUpdate(_person);
  }

  Future<void> _togglePurchased(int index) async {
    setState(() {
      _person.giftIdeas[index] = _person.giftIdeas[index]
          .copyWith(isPurchased: !_person.giftIdeas[index].isPurchased);
    });
    await widget.onUpdate(_person);
  }

  @override
  Widget build(BuildContext context) {
    final days = _person.daysUntilBirthday;
    final gradientColors =
        AppTheme.cardGradientFor(_person.id.hashCode.abs());

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
                icon: const Icon(Icons.edit_rounded),
                onPressed: _editPerson,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _deletePerson,
                tooltip: 'Delete',
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _person.avatarEmoji ?? '🎁',
                              style: const TextStyle(fontSize: 38),
                            ),
                          ),
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
                              if (_person.birthday != null)
                                Text(
                                  '🎂 ${DateFormat('MMMM d').format(DateTime.parse(_person.birthday!))}${days != null ? ' · $days days away' : ''}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
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
                        label: '${_person.giftIdeas.length} ideas',
                        color: AppTheme.sky,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.check_circle_rounded,
                        label:
                            '${_person.giftIdeas.where((g) => g.isPurchased).length} bought',
                        color: AppTheme.mint,
                      ),
                      if (_person.hasBirthdaySoon) ...[
                        const SizedBox(width: 10),
                        _StatChip(
                          icon: Icons.cake_rounded,
                          label: 'Soon! 🎉',
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
                        color: AppTheme.lavender.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.lavender.withOpacity(0.3)),
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
                      Text('Gift Ideas',
                          style:
                              Theme.of(context).textTheme.headlineMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addGift,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Idea'),
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
                        'No gift ideas yet!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Add Idea" to save gift ideas for ${_person.name}',
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
        label: const Text('Add Gift Idea',
            style: TextStyle(fontWeight: FontWeight.w700)),
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
        color: color.withOpacity(0.12),
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
              color: color.withOpacity(0.9),
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
                ? AppTheme.mint.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gift.isPurchased
                  ? AppTheme.mint.withOpacity(0.4)
                  : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                                color: AppTheme.sunflower.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${gift.currency ?? '\$'}${gift.estimatedPrice!.toStringAsFixed(0)}',
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
                          gift.category!,
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
                              label: 'Link',
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
          color: color.withOpacity(0.12),
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
