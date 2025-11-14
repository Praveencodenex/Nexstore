import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/shared_pref_service.dart';
import '../../data/providers/product_provider.dart';
import '../../data/providers/search_provider.dart';
import '../../utils/constants.dart';


class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  String currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await SharedService.getLanguage();
    setState(() {
      currentLanguage = language;
    });
  }

  Future<void> _updateLanguage(String languageCode) async {
    if (currentLanguage != languageCode) {
      await SharedService.saveLanguage(languageCode);

      // Update both providers
      final productsProvider = context.read<ProductsDataProvider>();
      final searchProvider = context.read<SearchDataProvider>();

      await productsProvider.updateLanguage(languageCode);
      await searchProvider.updateLanguage(languageCode);

      setState(() {
        currentLanguage = languageCode;
      });
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Select Language',
                  style: headingH3Style.copyWith(color: kPrimaryColor)
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: kSecondaryColor,
                    width: 0.6
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            child: Column(
              children: [
                _LanguageOption(
                  title: 'English',
                  subtitle: 'English',
                  isSelected: currentLanguage == 'en',
                  onTap: () => _updateLanguage('en'),
                ),
                _LanguageOption(
                  title: 'മലയാളം',
                  subtitle: 'Malayalam',
                  isSelected: currentLanguage == 'ml',
                  onTap: () => _updateLanguage('ml'),
                ),
                _LanguageOption(
                  title: 'தமிழ்',
                  subtitle: 'Tamil',
                  isSelected: currentLanguage == 'ta',
                  onTap: () => _updateLanguage('ta'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: isSelected
            ? const Icon(Icons.check_circle, color: kAccentTextAccentOrange)
            : const Icon(Icons.circle_outlined),
        title: Text(
          title,
          style: bodyStyleStyleB2SemiBold.copyWith(
              color: isSelected ? kPrimaryColor : kBlackColor
          ),
        ),
        subtitle: Text(
          subtitle,
          style: bodyStyleStyleB3,
        ),
        selected: isSelected,
        selectedTileColor: kPrimaryColor.withOpacity(0.1),
        hoverColor: Colors.grey[100],
      ),
    );
  }
}