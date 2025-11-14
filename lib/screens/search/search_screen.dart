import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thenexstore/screens/common/empty_data_screen.dart';
import 'package:thenexstore/screens/common/error_screen_new.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/constants.dart';
import '../../data/providers/search_provider.dart';
import '../../data/models/search_model.dart';
import '../../utils/assets.dart';
import '../../utils/size_config.dart';
import '../home/components/product_card.dart';
import '../components/language_bottom_sheet.dart';
import 'component/animated_microphone.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (!mounted) return;
    await context.read<SearchDataProvider>().initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeRecentSearch(SearchDataProvider provider, String search) async {
    // Remove individual search from the list
    final prefs = await SharedPreferences.getInstance();
    final searches = List<String>.from(provider.recentSearches);
    searches.remove(search);
    await prefs.setStringList('recent_searches', searches);

    // Update provider
    provider.recentSearches.remove(search);
    setState(() {});
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const LanguageBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCommon(title: "Search"),
      backgroundColor: kAppBarColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showLanguageBottomSheet,
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.language,
          color: kWhiteColor,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar and Microphone Button Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Search Input Field
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(5),
                        vertical: getProportionateScreenHeight(6),
                      ),
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: getProportionateScreenWidth(16)),
                          SvgPicture.asset(
                            searchIcon,
                            height: getProportionateScreenWidth(26),
                          ),
                          SizedBox(width: getProportionateScreenWidth(12)),
                          Expanded(
                            child: Consumer<SearchDataProvider>(
                              builder: (context, provider, _) {
                                if (_searchController.text != provider.searchQuery) {
                                  _searchController.text = provider.searchQuery;
                                  _searchController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: provider.searchQuery.length),
                                  );
                                }
                                return TextField(
                                  controller: _searchController,
                                  style: bodyStyleStyleB1Bold.copyWith(
                                    color: kBlackColor,
                                  ),
                                  onChanged: (value) => provider.updateSearchQuery(value),
                                  decoration: InputDecoration(
                                    hintText: 'Search here',
                                    hintStyle: bodyStyleStyleB1Bold.copyWith(
                                      color: kBlackColor.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Animated Microphone Button
                  Consumer<SearchDataProvider>(
                    builder: (context, provider, _) {
                      return Container(
                        width: getProportionateScreenHeight(55),
                        height: getProportionateScreenHeight(55),
                        decoration: BoxDecoration(
                          color: provider.isListening
                              ? kPrimaryColor.withOpacity(0.1)
                              : kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedMicrophoneIcon(
                          isListening: provider.isListening,
                          onTap: () => provider.toggleListening(),
                          activeColor: kPrimaryColor,
                          inactiveColor: kWhiteColor,
                          tooltip: provider.isListening
                              ? 'Stop listening'
                              : 'Start voice search',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Scrollable content area
            Expanded(
              child: Consumer<SearchDataProvider>(
                builder: (context, provider, _) {
                  return CustomScrollView(
                    slivers: [
                      // Recent Searches Header
                      if (provider.recentSearches.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: bodyStyleStyleB0.copyWith(color: kPrimaryColor),
                                ),
                                TextButton(
                                  onPressed: () => provider.clearRecentSearches(),
                                  child: Text(
                                    'Clear all',
                                    style: bodyStyleStyleB2Bold.copyWith(
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                      // Recent Searches List
                      if (provider.recentSearches.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final search = provider.recentSearches[index];
                              return InkWell(
                                onTap: () => provider.updateSearchQuery(search),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          search,
                                          style: bodyStyleStyleB2.copyWith(
                                            color: kBlackColor,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _removeRecentSearch(provider, search),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: provider.recentSearches.take(3).length,
                          ),
                        ),

                      // Search Results
                      provider.searchState.state.when(
                        initial: () => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: NoDataScreen(
                            title: "Start searching for products",
                            subTitle: 'Type in the search bar or use voice search',
                            icon: emptyError,
                          ),
                        ),
                        loading: () => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                        success: (data) {
                          if (data.data.isEmpty) {
                            return const SliverFillRemaining(
                              hasScrollBody: false,
                              child: NoDataScreen(
                                title: "No products found",
                                subTitle: 'Try searching with different keywords',
                                icon: emptyError,
                              ),
                            );
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  return ProductCard(product: data.data[index]);
                                },
                                childCount: data.data.length,
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                            ),
                          );
                        },
                        failure: (error) => SliverFillRemaining(
                          hasScrollBody: false,
                          child: ErrorScreenNew(error: error),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}