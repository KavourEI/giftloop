import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/gift_idea.dart';
import '../utils/app_theme.dart';

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
    _priceController = TextEditingController(
        text: g?.estimatedPrice?.toStringAsFixed(0) ?? '');
    _currency = g?.currency ?? '€';
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

    final priceText = _priceController.text.trim();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Gift Idea' : 'New Gift Idea'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              _isEditing ? 'Save' : 'Add',
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
              _Label('Gift name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Wireless headphones, Book, Perfume...',
                  prefixIcon: Icon(Icons.card_giftcard_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // Category
              _Label('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  hintText: 'Select a category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                isExpanded: true,
                items: giftCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
              ).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 20),

              // Description
              _Label('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Notes, details, size, color preferences...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ).animate().fadeIn(delay: 75.ms),

              const SizedBox(height: 20),

              // Price
              _Label('Estimated price'),
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
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // Link
              _Label('Online link'),
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
                    return 'Please enter a valid URL (include https://)';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 125.ms),

              const SizedBox(height: 20),

              // Store info
              _Label('Store / Shop name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _storeNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Amazon, Zara, Local bookstore...',
                  prefixIcon: Icon(Icons.store_rounded),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 16),
              _Label('Store location / Address'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _storeLocationController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. City Centre Mall, Floor 2...',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ).animate().fadeIn(delay: 175.ms),

              const SizedBox(height: 24),

              // Purchased toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isPurchased
                      ? AppTheme.mint.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPurchased
                        ? AppTheme.mint.withOpacity(0.4)
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
                          const Text('Mark as purchased',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            'Check this off once you\'ve bought it',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPurchased,
                      onChanged: (v) => setState(() => _isPurchased = v),
                      activeColor: AppTheme.mint,
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
                      _isEditing ? '✓ Save Changes' : '+ Add Gift Idea'),
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
