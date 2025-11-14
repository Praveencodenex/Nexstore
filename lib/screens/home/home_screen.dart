import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/home/components/home_loader.dart';
import '../../data/providers/home_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import 'components/home_app_bar.dart';
import 'home_success_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const HomeAppBar(),
      body: Consumer<HomeDataProvider>(
        builder: (context, provider, child) {
          return provider.homeState.state.when(
            initial: () => const HomeLoader(),
            loading: () => const HomeLoader(),
            success: (homeData) {
              return HomeSuccessScreen(
                homeData: homeData,
                onRefresh: ()=>_fetchData(forceRefresh: true),
              );
            },
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => provider.fetchHomeData(forceRefresh: true),
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(forceRefresh: false);

  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<HomeDataProvider>().fetchHomeData(
      forceRefresh: forceRefresh,
    );
  }
}