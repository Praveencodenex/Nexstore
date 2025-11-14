import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/constants.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../utils/assets.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../components/common_app_bar.dart';
import 'category_success_screen.dart';
import 'components/category_shimmer.dart';


class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoryProvider>().fetchCategoryData(forceRefresh: false);
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<CategoryProvider>().fetchCategoryData(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);
        }
      },
      child: Scaffold(
        appBar: const AppBarCommon(title: 'All Categories',isBottom: true,),
        backgroundColor: kAppBarColor,
        body: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            return provider.categoryState.state.when(
              initial: () => const CategoryLoader(),
              loading: () => const CategoryLoader(),
              success: (categoryData) {
                if (categoryData.data.isEmpty) {
                  return NoDataScreen(
                    title: "Categories",
                    subTitle: categoryData.message,
                    icon: emptyError);
                }
                return CategorySuccessScreen(
                  categoryData: categoryData,
                  onRefresh: _onRefresh,
                );
              },
              failure: (error) => ErrorScreenNew(
                error: error,
                onRetry: () => provider.fetchCategoryData(forceRefresh: true),
              ),
            );
          },
        ),
      ),
    );
  }
}

