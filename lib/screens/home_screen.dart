import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/strings.dart';
import '../models/person.dart';
import '../services/people_store.dart';
import '../utils/app_theme.dart';
import '../widgets/person_avatar.dart';
import 'add_edit_person_screen.dart';
import 'contacts_import_screen.dart';
import 'person_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = PeopleStore.instance;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Person> get _people => _store.people;

  List<Person> get _filteredPeople {
    if (_searchQuery.isEmpty) return _people;
    return _people
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Person> get _upcomingBirthdays {
    return _people.where((p) => p.hasBirthdaySoon).toList()
      ..sort((a, b) =>
          (a.daysUntilBirthday ?? 999).compareTo(b.daysUntilBirthday ?? 999));
  }

  Future<void> _showAddOptions() async {
    final s = S.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.addPersonTitle,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _AddOption(
                icon: Icons.edit_rounded,
                color: AppTheme.coral,
                title: s.addManually,
                subtitle: s.addManuallySub,
                onTap: () => Navigator.pop(context, 'manual'),
              ),
              const SizedBox(height: 12),
              _AddOption(
                icon: Icons.contacts_rounded,
                color: AppTheme.sky,
                title: s.importFromContacts,
                subtitle: s.importFromContactsSub,
                onTap: () => Navigator.pop(context, 'contacts'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'manual') {
      await _addPerson();
    } else if (choice == 'contacts') {
      await _importContacts();
    }
  }

  Future<void> _addPerson() async {
    final result = await Navigator.push<Person>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditPersonScreen()),
    );
    if (result != null) await _store.add(result);
  }

  Future<void> _importContacts() async {
    final added = await Navigator.push<List<Person>>(
      context,
      MaterialPageRoute(builder: (_) => const ContactsImportScreen()),
    );
    if (added == null || added.isEmpty || !mounted) return;
    await _store.addAll(added);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).peopleAdded(added.length))));
  }

  void _openPerson(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PersonDetailScreen(personId: person.id)),
    );
  }

  void _openSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: !_store.isLoaded
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    _buildHeader(),
                    if (_upcomingBirthdays.isNotEmpty) _buildBirthdayBanner(),
                    _buildSearchBar(),
                    _filteredPeople.isEmpty
                        ? _buildEmptyState()
                        : _buildPeopleGrid(),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddOptions,
          shape: const CircleBorder(),
          child: const Icon(Icons.person_add_rounded),
        ).animate().scale(delay: 400.ms),
      ),
    );
  }

  Widget _buildHeader() {
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo_mark.png',
                        height: 40,
                        filterQuality: FilterQuality.medium,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'GiftLoop',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.tagline,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                s.peopleCount(_people.length),
                style: const TextStyle(
                  color: AppTheme.coral,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: s.settings,
              onPressed: _openSettings,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildBirthdayBanner() {
    final s = S.of(context);
    final upcoming = _upcomingBirthdays;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD93D), Color(0xFFFFB347)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sunflower.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎂', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  s.upcomingBirthdays,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF5D3000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...upcoming.map((p) {
              final days = p.daysUntilBirthday!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    PersonAvatar(
                      imageName: p.avatarImage,
                      emoji: p.avatarEmoji,
                      size: 26,
                      background: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D1F00),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        days == 0
                            ? s.today
                            : days == 1
                                ? s.tomorrow
                                : s.inDays(days),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF3D1F00),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: S.of(context).searchPeople,
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
    );
  }

  Widget _buildEmptyState() {
    final s = S.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _searchQuery.isNotEmpty
                ? Icon(Icons.search_off_rounded,
                    size: 72, color: Colors.grey.shade400)
                : Image.asset(
                    'assets/logo.png',
                    width: 200,
                    filterQuality: FilterQuality.medium,
                  ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? s.noOneFound : s.addFirstPerson,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ? s.tryDifferentName : s.tapToStart,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).scale(),
      ),
    );
  }

  Widget _buildPeopleGrid() {
    final people = _filteredPeople;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final person = people[index];
            return _PersonCard(
              key: ValueKey(person.id),
              person: person,
              gradientIndex: _people.indexOf(person),
              onTap: () => _openPerson(person),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  duration: 400.ms,
                );
          },
          childCount: people.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;
  final int gradientIndex;
  final VoidCallback onTap;

  const _PersonCard({
    super.key,
    required this.person,
    required this.gradientIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = AppTheme.cardGradientFor(gradientIndex);
    final days = person.daysUntilBirthday;
    final hasSoon = person.hasBirthdaySoon;
    final bg = personBackground(person.backgroundImage);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (bg != null)
              Positioned.fill(child: bg)
            else
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      person.avatarImage != null
                          ? PersonAvatar(
                              imageName: person.avatarImage,
                              emoji: person.avatarEmoji,
                              size: 50,
                              background: Colors.white24,
                              borderColor: Colors.white,
                            )
                          : Text(
                              person.avatarEmoji ?? '🎁',
                              style: const TextStyle(fontSize: 36),
                            ),
                      if (hasSoon)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Text('🎂', style: TextStyle(fontSize: 14)),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    person.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.card_giftcard_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 14),
                      const SizedBox(width: 4),
                      Text(
                        s.ideasCount(person.giftIdeas.length),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (days != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        days == 0
                            ? s.cardToday
                            : days == 1
                                ? s.cardTomorrow
                                : s.cardInDays(days),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
