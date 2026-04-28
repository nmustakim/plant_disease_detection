import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';


class _FaqCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_FaqItem> items;

  const _FaqCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

const _categories = [
  _FaqCategory(
    title: 'Getting Started',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFF2E7D32),
    items: [
      _FaqItem(
        question: 'How do I scan a plant leaf?',
        answer:
        'Tap "Scan Leaf" on the home screen to open your camera, or tap "Upload from Gallery" to choose an existing photo. Hold the camera 15–30 cm from the leaf in good lighting for best results. The app accepts JPG and PNG images up to 10 MB.',
      ),
      _FaqItem(
        question: 'Does the app work without internet?',
        answer:
        'Yes — all disease detection runs fully offline on your device using an on-device AI model. You only need internet for optional features like downloading model updates or syncing your feedback to the cloud.',
      ),
      _FaqItem(
        question: 'Which crops and diseases are supported?',
        answer:
        'The app currently supports 38 disease classes across tomato, potato, maize, pepper, apple, grape, cherry, peach, and strawberry. It can also detect healthy leaves. More crops will be added in future updates.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Scan & Detection',
    icon: Icons.document_scanner_rounded,
    color: Color(0xFF1565C0),
    items: [
      _FaqItem(
        question: 'Why did my scan show "Unknown"?',
        answer:
        'An "Unknown" result means the model\'s confidence was below 60%. This usually happens with blurry images, poor lighting, or leaves that are too far from the camera. Try again with a clear, well-lit, close-up photo of a single leaf.',
      ),
      _FaqItem(
        question: 'What do the confidence percentages mean?',
        answer:
        'The confidence score shows how certain the AI is about its diagnosis:\n\n• Green (≥85%) — High confidence, result is likely accurate\n• Yellow (60–84%) — Medium confidence, consider a second scan\n• Red (<60%) — Low confidence, result marked as Unknown\n\nAlways consult an agronomist for critical decisions.',
      ),
      _FaqItem(
        question: 'How accurate is the detection?',
        answer:
        'The model achieves approximately 92% accuracy on the PlantVillage test dataset. In real field conditions, accuracy may vary due to image quality, lighting, and disease stage. The app is designed as a decision-support tool, not a replacement for expert advice.',
      ),
      _FaqItem(
        question: 'How long does a scan take?',
        answer:
        'On most mid-range Android and iOS devices, inference completes in 200–500 ms. The result screen typically appears within 1 second of confirming your image.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'History & Data',
    icon: Icons.history_rounded,
    color: Color(0xFF6A1B9A),
    items: [
      _FaqItem(
        question: 'Where are my scan results stored?',
        answer:
        'All prediction records and leaf images are stored locally on your device using an SQLite database. Nothing is sent to a server without your action. You can view, browse, and delete your history at any time from the History screen.',
      ),
      _FaqItem(
        question: 'How do I delete a prediction?',
        answer:
        'Go to History, find the prediction you want to remove, and swipe left on it (or tap the delete icon). You can also delete all predictions at once from Settings → Data Storage → Clear Cache.',
      ),
      _FaqItem(
        question: 'Can I export my scan history?',
        answer:
        'Export functionality is planned for a future version. Currently all data lives on your device. If you uninstall the app, your history will be permanently deleted.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Feedback & Sync',
    icon: Icons.sync_rounded,
    color: Color(0xFFE65100),
    items: [
      _FaqItem(
        question: 'What happens when I submit feedback?',
        answer:
        'Your feedback (Correct / Incorrect / Unsure) is saved locally first. When you\'re online, it syncs anonymously to our cloud database to help improve the AI model for all users. No personal information is attached to your feedback.',
      ),
      _FaqItem(
        question: 'Why should I give feedback?',
        answer:
        'Your feedback directly helps improve future model accuracy. When you mark a result as "Incorrect" and enter the correct disease name, that signal is used to fine-tune the model in future updates — benefiting all farmers using the app.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Model Updates',
    icon: Icons.system_update_rounded,
    color: Color(0xFF00838F),
    items: [
      _FaqItem(
        question: 'How do I update the AI model?',
        answer:
        'Go to Settings → App Information → Model Version, then tap "Check for Updates". If a newer model is available, it will download automatically over your current connection. We recommend using Wi-Fi for downloads.',
      ),
      _FaqItem(
        question: 'Will a model update delete my history?',
        answer:
        'No. Model updates only replace the AI inference file on your device. Your prediction history, settings, and feedback records are completely separate and are never affected by model updates.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Settings & Language',
    icon: Icons.tune_rounded,
    color: Color(0xFF558B2F),
    items: [
      _FaqItem(
        question: 'How do I switch to Bengali?',
        answer:
        'Go to Settings → Preferences → Language and select "বাংলা (Bengali)". The app will ask you to restart to apply the change. All UI text, including disease names and treatment tips, will switch to Bengali.',
      ),
      _FaqItem(
        question: 'What is the confidence threshold setting?',
        answer:
        'This controls the minimum confidence score required before the app shows a disease name instead of "Unknown". The default is 60%. Raising it (e.g. to 80%) makes the app more conservative — it will say Unknown more often but only confirm diseases it\'s very sure about.',
      ),
    ],
  ),
];



class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _headerAnimController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  String _searchQuery = '';
  int? _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    ));
    _headerAnimController.forward();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  List<_FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty && _selectedCategoryIndex == null) {
      return _categories;
    }

    return _categories.where((cat) {
      if (_selectedCategoryIndex != null &&
          _categories.indexOf(cat) != _selectedCategoryIndex) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final matchesTitle =
        cat.title.toLowerCase().contains(_searchQuery);
        final matchesItems = cat.items.any(
              (item) =>
          item.question.toLowerCase().contains(_searchQuery) ||
              item.answer.toLowerCase().contains(_searchQuery),
        );
        return matchesTitle || matchesItems;
      }
      return true;
    }).map((cat) {
      if (_searchQuery.isEmpty) return cat;
      final filteredItems = cat.items
          .where((item) =>
      item.question.toLowerCase().contains(_searchQuery) ||
          item.answer.toLowerCase().contains(_searchQuery))
          .toList();
      return filteredItems.isEmpty
          ? null
          : _FaqCategory(
        title: cat.title,
        icon: cat.icon,
        color: cat.color,
        items: filteredItems,
      );
    }).whereType<_FaqCategory>().toList();
  }

  int get _totalResults =>
      _filteredCategories.fold(0, (sum, c) => sum + c.items.length);


  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategoryChips()),
          if (_searchQuery.isNotEmpty)
            SliverToBoxAdapter(child: _buildResultCount()),
          if (filtered.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _FaqCategoryCard(
                  category: filtered[index],
                  searchQuery: _searchQuery,
                  animDelay: Duration(milliseconds: 60 * index),
                ),
                childCount: filtered.length,
              ),
            ),
          SliverToBoxAdapter(child: _buildContactCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }


  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF2E7D32),
                    Color(0xFF388E3C),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.04),
                ),
              ),
            ),
            // Header content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Help & FAQ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_categories.fold(0, (s, c) => s + c.items.length)} answers across ${_categories.length} topics',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search questions…',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded,
                color: AppColors.primary.withValues(alpha:0.7)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }


  Widget _buildCategoryChips() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final isSelected = isAll
              ? _selectedCategoryIndex == null
              : _selectedCategoryIndex == index - 1;
          final cat = isAll ? null : _categories[index - 1];

          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategoryIndex = isAll ? null : index - 1;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isAll ? AppColors.primary : cat!.color)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: (isAll ? AppColors.primary : cat!.color)
                        .withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAll ? Icons.apps_rounded : cat!.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAll ? 'All' : cat!.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color:
                      isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Text(
        _totalResults == 0
            ? 'No results found'
            : '$_totalResults result${_totalResults == 1 ? '' : 's'} for "$_searchQuery"',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.primary.withValues(alpha:0.5)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matches found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or browse by category',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }


  Widget _buildContactCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Still need help?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Couldn\'t find your answer above',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'nmustakim98@gmail.com',
            ),
            const SizedBox(height: 10),
            const _InfoRow(
              icon: Icons.code_rounded,
              label: 'GitHub',
              value: 'https://github.com/nmustakim/plant_disease_detection',
            ),
            const SizedBox(height: 10),
            const _InfoRow(
              icon: Icons.info_outline_rounded,
              label: 'Version',
              value: 'Plant DD AI v1.0.0',
            ),
          ],
        ),
      ),
    );
  }
}



class _FaqCategoryCard extends StatefulWidget {
  final _FaqCategory category;
  final String searchQuery;
  final Duration animDelay;

  const _FaqCategoryCard({
    required this.category,
    required this.searchQuery,
    required this.animDelay,
  });

  @override
  State<_FaqCategoryCard> createState() => _FaqCategoryCardState();
}

class _FaqCategoryCardState extends State<_FaqCategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.animDelay, () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha:0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cat.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${cat.items.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cat.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100),
                // FAQ items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cat.items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade100,
                  ),
                  itemBuilder: (context, i) => _FaqTile(
                    item: cat.items[i],
                    accentColor: cat.color,
                    searchQuery: widget.searchQuery,
                    isLast: i == cat.items.length - 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  final Color accentColor;
  final String searchQuery;
  final bool isLast;

  const _FaqTile({
    required this.item,
    required this.accentColor,
    required this.searchQuery,
    required this.isLast,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
    _iconRotation =
        Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _expandController.forward() : _expandController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.only(
        bottomLeft: widget.isLast ? const Radius.circular(18) : Radius.zero,
        bottomRight: widget.isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.help_rounded,
                    size: 16,
                    color: widget.accentColor.withValues(alpha:0.7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HighlightedText(
                    text: widget.item.question,
                    query: widget.searchQuery,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    highlightColor: const Color(0xFFFFEB3B),
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _iconRotation,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.accentColor,
                    size: 22,
                  ),
                ),
              ],
            ),
            // Answer (animated)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 26),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha:0.12),
                      ),
                    ),
                    child: _HighlightedText(
                      text: widget.item.answer,
                      query: widget.searchQuery,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      highlightColor: const Color(0xFFFFEB3B),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: highlightColor,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ));
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}



class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}