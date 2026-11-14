import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/strings.dart';
import '../models/birthday.dart';
import '../utils/app_theme.dart';

/// Formats a birthday for display, e.g. "15 June 1990" or "15 June".
String formatBirthday(BuildContext context, Birthday b, {bool withYear = true}) {
  final locale = Localizations.localeOf(context).languageCode;
  final pattern = (withYear && b.year != null) ? 'd MMMM y' : 'd MMMM';
  return DateFormat(pattern, locale).format(b.displayDate);
}

/// Shows a bottom sheet with day / month / year wheels.
///
/// Wheels let people reach a birth year decades back with one flick, instead
/// of paging month by month through a calendar grid. The year can be marked
/// unknown. Returns null when dismissed.
Future<Birthday?> showBirthdayPicker(BuildContext context, {Birthday? initial}) {
  return showModalBottomSheet<Birthday>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _BirthdayPickerSheet(initial: initial),
  );
}

class _BirthdayPickerSheet extends StatefulWidget {
  final Birthday? initial;
  const _BirthdayPickerSheet({this.initial});

  @override
  State<_BirthdayPickerSheet> createState() => _BirthdayPickerSheetState();
}

class _BirthdayPickerSheetState extends State<_BirthdayPickerSheet> {
  static const _firstYear = 1900;
  late final int _lastYear = DateTime.now().year;

  late int _day;
  late int _month;
  late int _year;
  late bool _yearUnknown;

  late final FixedExtentScrollController _dayCtrl;
  late final FixedExtentScrollController _monthCtrl;
  late final FixedExtentScrollController _yearCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final b = widget.initial;
    _day = b?.day ?? now.day;
    _month = b?.month ?? now.month;
    _year = b?.year ?? now.year - 30;
    _yearUnknown = b != null && b.year == null;
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(initialItem: _year - _firstYear);
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  int get _daysInMonth {
    // Without a year, allow 29 February.
    final y = _yearUnknown ? 2000 : _year;
    return DateTime(y, _month + 1, 0).day;
  }

  void _clampDay() {
    final max = _daysInMonth;
    if (_day > max) {
      _day = max;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dayCtrl.hasClients) _dayCtrl.jumpToItem(_day - 1);
      });
    }
  }

  Birthday get _value =>
      Birthday(year: _yearUnknown ? null : _year, month: _month, day: _day);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final monthNames = List.generate(
        12, (i) => DateFormat('LLLL', locale).format(DateTime(2000, i + 1)));
    final age = _value.turningAge;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('🎂', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(s.birthdayPickerTitle,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),

            // Live preview of the chosen date.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    formatBirthday(context, _value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (age != null)
                    Text(
                      s.turnsAge(age),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Wheels
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _wheel(
                      controller: _dayCtrl,
                      count: _daysInMonth,
                      label: (i) => '${i + 1}',
                      onChanged: (i) => setState(() => _day = i + 1),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _wheel(
                      controller: _monthCtrl,
                      count: 12,
                      label: (i) => monthNames[i],
                      onChanged: (i) => setState(() {
                        _month = i + 1;
                        _clampDay();
                      }),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _yearUnknown
                        ? const SizedBox.shrink()
                        : SizedBox(
                            width: 100,
                            child: _wheel(
                              controller: _yearCtrl,
                              count: _lastYear - _firstYear + 1,
                              label: (i) => '${_firstYear + i}',
                              onChanged: (i) => setState(() {
                                _year = _firstYear + i;
                                _clampDay();
                              }),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Unknown year toggle
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: SwitchListTile.adaptive(
                value: _yearUnknown,
                activeTrackColor: AppTheme.coral,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                title: Text(s.dontKnowYear,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                onChanged: (v) => setState(() {
                  _yearUnknown = v;
                  _clampDay();
                  if (!v) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_yearCtrl.hasClients) {
                        _yearCtrl.jumpToItem(_year - _firstYear);
                      }
                    });
                  }
                }),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _value),
                child: Text(s.done),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 40,
      magnification: 1.15,
      useMagnifier: true,
      squeeze: 1.1,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: AppTheme.coral.withValues(alpha: 0.12),
      ),
      onSelectedItemChanged: onChanged,
      children: List.generate(
        count,
        (i) => Center(
          child: Text(
            label(i),
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoal),
          ),
        ),
      ),
    );
  }
}
