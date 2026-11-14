import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../l10n/strings.dart';
import '../models/gift_idea.dart';
import '../services/settings_service.dart';
import '../utils/app_theme.dart';
import '../widgets/category_dialog.dart';

/// Dropdown value for the "create new category" entry.
const _createCategoryValue = '__create__';

class AddEditGiftScreen extends StatefulWidget {
  final GiftIdea? gift;

  const AddEditGiftScreen({super.key, this.gift});

  @override
  State<AddEditGiftScreen> createState() => _AddEditGiftScreenState();
}

class _AddEditGiftScreenState extends State<AddEditGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  late TextEditingController _storeNameController;
  late TextEditingController _storeLocationController;
  late TextEditingController _priceController;
  String _currency = '€';
  String? _category;
  bool _isPurchased = false;
  int _categoryFieldVersion = 0;

  final _currencies = ['€', '\$', '£', '¥', '₹', 'CHF', 'AUD', 'CAD'];

  bool get _isEditing => widget.gift != null;

  @override
  void initState() {
    super.initState();
    final g = widget.gift;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descriptionController =
        TextEditingController(text: g?.description ?? '');
    _linkController = TextEditingController(text: g?.link ?? '');
    _storeNameController = TextEditingController(text: g?.storeName ?? '');
    _storeLocationController =
        TextEditingController(text: g?.storeLocation ?? '');
    final price = g?.estimatedPrice;
    _priceController = TextEditingController(
        text: price == null
            ? ''
            : price == price.roundToDouble()
                ? price.toStringAsFixed(0)
                : price.toStringAsFixed(2));
    // Older gifts were saved with the currency code 'USD' by default.
    _currency = switch (g?.currency) {
      null => '€',
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      final c => _currencies.contains(c) ? c : '€',
    };
    _category = g?.category;
    _isPurchased = g?.isPurchased ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _storeNameController.dispose();
    _storeLocationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Greek keyboards type a comma as the decimal separator.
    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final price =
        priceText.isNotEmpty ? double.tryParse(priceText) : null;

    final gift = GiftIdea(
      id: widget.gift?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      link: _linkController.text.trim().isEmpty
          ? null
          : _linkController.text.trim(),
      storeName: _storeNameController.text.trim().isEmpty
          ? null
          : _storeNameController.text.trim(),
      storeLocation: _storeLocationController.text.trim().isEmpty
          ? null
          : _storeLocationController.text.trim(),
      estimatedPrice: price,
      currency: _currency,
      isPurchased: _isPurchased,
      category: _category,
      createdAt: widget.gift?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, gift);
  }

  Future<void> _onCategoryChanged(String? value) async {
    if (value != _createCategoryValue) {
      setState(() => _category = value);
      return;
    }
    final created = await showCreateCategoryDialog(context);
    if (!mounted) return;
    // Rebuild the field even when cancelled, so it stops showing the
    // "create" entry as the selection.
    setState(() {
      _categoryFieldVersion++;
      if (created != null) _category = created;
    });
  }

  Widget _buildCategoryDropdown(S s) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) {
        final options = [
          ...giftCategories,
          ...SettingsService.instance.customCategories,
        ];
        // Keep a category that is no longer listed (deleted custom category,
        // or one that came with a shared card) so the dropdown can show it.
        if (_category != null && !options.contains(_category)) {
          options.add(_category!);
        }
        return DropdownButtonFormField<String>(
          initialValue: _category,
          key: ValueKey('$_category#$_categoryFieldVersion'),
          decoration: InputDecoration(
            hintText: s.selectCategory,
            prefixIcon: const Icon(Icons.category_rounded),
          ),
          isExpanded: true,
          items: [
            ...options.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(s.categoryLabel(c),
                      style: const TextStyle(fontSize: 14)),
                )),
            DropdownMenuItem(
              value: _createCategoryValue,
              child: Text(s.createCategory,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.coral)),
            ),
          ],
          onChanged: _onCategoryChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? s.editGiftIdea : s.newGiftIdea),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              _isEditing ? s.save : s.add,
              style: TextStyle(
                color: AppTheme.coral,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _Label(s.giftNameLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: s.giftNameHint,
                  prefixIcon: const Icon(Icons.card_giftcard_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? s.nameRequired : null,
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // Category
              _Label(s.category),
              const SizedBox(height: 8),
              _buildCategoryDropdown(s).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 20),

              // Description
              _Label(s.description),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: s.descriptionHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ).animate().fadeIn(delay: 75.ms),

              const SizedBox(height: 20),

              // Price
              _Label(s.estimatedPrice),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currency,
                        items: _currencies
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _currency = v ?? '€'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    // No currency icon here: the currency is chosen on the
                    // left, and a fixed "\$" icon contradicted it.
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[.,]?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0.00',
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // Link
              _Label(s.onlineLink),
              const SizedBox(height: 8),
              TextFormField(
                controller: _linkController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) {
                    return s.invalidUrl;
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 125.ms),

              const SizedBox(height: 20),

              // Store info
              _Label(s.storeName),
              const SizedBox(height: 8),
              TextFormField(
                controller: _storeNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: s.storeNameHint,
                  prefixIcon: const Icon(Icons.store_rounded),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 16),
              _Label(s.storeLocation),
              const SizedBox(height: 8),
              TextFormField(
                controller: _storeLocationController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: s.storeLocationHint,
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),
              ).animate().fadeIn(delay: 175.ms),

              const SizedBox(height: 24),

              // Purchased toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isPurchased
                      ? AppTheme.mint.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPurchased
                        ? AppTheme.mint.withValues(alpha: 0.4)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Text('✅', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.markPurchased,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Text(
                            s.markPurchasedSub,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPurchased,
                      onChanged: (v) => setState(() => _isPurchased = v),
                      activeThumbColor: AppTheme.mint,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                      _isEditing ? s.saveChanges : s.addGiftButton),
                ),
              ).animate().fadeIn(delay: 225.ms).scale(delay: 225.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Colors.grey.shade600),
    );
  }
}
