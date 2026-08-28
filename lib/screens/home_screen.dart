import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/person.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import 'person_detail_screen.dart';
import 'add_edit_person_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Person> _people = [];
  bool _loading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final people = await StorageService.loadPeople();
    if (mounted) {
      setState(() {
        _people = people;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await StorageService.savePeople(_people);
    await NotificationService.scheduleAllBirthdayReminders(_people);
  }

  List<Person> get _filteredPeople {
    if (_searchQuery.isEmpty) return _people;
    return _people
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Person> get _upcomingBirthdays {
    return _people
        .where((p) => p.hasBirthdaySoon)
        .toList()
      ..sort((a, b) =>
          (a.daysUntilBirthday ?? 999).compareTo(b.daysUntilBirthday ?? 999));
  }

  Future<void> _addPerson() async {
    final result = await Navigator.push<Person>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditPersonScreen()),
    );
    if (result != null) {
      setState(() => _people.add(result));
      await _save();
    }
  }

  Future<void> _openPerson(Person person) async {
    await Navigator.push<Person?>(
      context,
      MaterialPageRoute(
          builder: (_) => PersonDetailScreen(
                person: person,
                onUpdate: (p) async {
                  setState(() {
                    final idx = _people.indexWhere((x) => x.id == p.id);
                    if (idx != -1) _people[idx] = p;
                  });
                  await _save();
                },
                onDelete: (id) async {
                  setState(() => _people.removeWhere((x) => x.id == id));
                  await _save();
                },
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPerson,
        label: const Icon(  Icons.person_add_rounded),
        backgroundColor: AppTheme.coral,
        foregroundColor: Colors.white,
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                    'Never forget a perfect gift',
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
                color: AppTheme.coral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_people.length} ${_people.length == 1 ? 'person' : 'people'}',
                style: TextStyle(
                  color: AppTheme.coral,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildBirthdayBanner() {
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
              color: AppTheme.sunflower.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🎂', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Upcoming Birthdays!',
                  style: TextStyle(
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
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(p.avatarEmoji ?? '🎂',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3D1F00),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        days == 0
                            ? 'Today! 🎉'
                            : days == 1
                                ? 'Tomorrow!'
                                : 'in $days days',
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
            hintText: 'Search people...',
            prefixIcon:
                const Icon(Icons.search_rounded, color: Colors.grey),
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
    return SliverFillRemaining(
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
              _searchQuery.isNotEmpty
                  ? 'No one found'
                  : 'Add your first person!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different name'
                  : 'Tap the button below to get started',
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

class _PersonCard extends StatelessWidget {
  final Person person;
  final int gradientIndex;
  final VoidCallback onTap;

  const _PersonCard({
    required this.person,
    required this.gradientIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.cardGradientFor(gradientIndex);
    final days = person.daysUntilBirthday;
    final hasSoon = person.hasBirthdaySoon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
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
                          child: const Text('🎂',
                              style: TextStyle(fontSize: 14)),
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
                          color: Colors.white.withOpacity(0.85), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${person.giftIdeas.length} idea${person.giftIdeas.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        days == 0
                            ? '🎉 Today!'
                            : days == 1
                                ? '🎂 Tomorrow'
                                : '🎂 in $days days',
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
