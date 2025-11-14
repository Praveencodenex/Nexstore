import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/utils/assets.dart';
import '../../../data/providers/product_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';
import 'package:flutter/services.dart';

import 'filter_loader.dart';

void showFilterBottomSheet(BuildContext context,int catId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterBottomSheet(catId: catId,),
  );
}

class FilterBottomSheet extends StatefulWidget {
  final int catId;
   const FilterBottomSheet( {super.key,required this.catId});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  late TextEditingController _searchController;
  late ProductsDataProvider _productsProvider;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _productsProvider = context.read<ProductsDataProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productsProvider.fetchFilters(widget.catId);
    });

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Widget _buildFilterList(ProductsDataProvider provider) {
    return provider.filterState.state.when(
      initial: () => const FilterLoader(),
      loading: () => const FilterLoader(),
      success: (filterData) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Filter types (always visible)
            Container(
              width: 100,
              height: double.infinity,
              color: kAppBarColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTypeItem('Brand', provider),
                  _buildFilterTypeItem('Type', provider),
                ],
              ),
            ),
            // Right side - Search field and filter items
            Expanded(
              child: Column(
                children: [
                  _buildSearchField(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: provider.selectedFilterType == 'brand'
                          ? _buildBrandListWithEmptyState(provider)
                          : _buildTypeListWithEmptyState(provider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      failure: (error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text('Error: ${error.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchFilters(widget.catId),
              child: const Text('Retry'),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildBrandListWithEmptyState(ProductsDataProvider provider) {
    if (provider.brands.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(Icons.search_off, size: getProportionateScreenWidth(50), color: Colors.grey),
           SizedBox(height: getProportionateScreenWidth(10)),
          Text(
            'No brands found',
            style: bodyStyleStyleB3Medium.copyWith(color: Colors.grey[600]),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                provider.setFilterSearchQuery('',widget.catId);
              },
              child: const Text('Clear Search'),
            ),
          ],
        ],
      );
    }
    return _buildBrandList(provider);
  }

  Widget _buildTypeListWithEmptyState(ProductsDataProvider provider) {
    if (provider.types.isEmpty) {
      return Column( mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: getProportionateScreenWidth(50), color: Colors.grey),
          SizedBox(height: getProportionateScreenWidth(10)),
          Center(child: Text('No type found',style: bodyStyleStyleB3Medium.copyWith(color: Colors.grey[600]),))
        ],
      );
    }
    return _buildTypeList(provider);
  }
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenHeight(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter By',
            style: headingH3Style.copyWith(color: kPrimaryColor)

          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(18),
        vertical: getProportionateScreenHeight(12),
      ),
      child: SizedBox(
        height: getProportionateScreenHeight(45), // Control the height of TextField
        child: TextField(
          style: bodyStyleStyleB2Bold,
          controller: _searchController,
          onChanged: (value) => _productsProvider.setFilterSearchQuery(value,widget.catId),
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(10)), // Adjust padding around the icon
              child: SvgPicture.asset(
                searchIcon,
                fit: BoxFit.contain, // Make icon fit within its space
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(35),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(35),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(35),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding:  EdgeInsets.symmetric(
              vertical: 0, // Reduce vertical padding
              horizontal: getProportionateScreenWidth(16),
            ),
            constraints: const BoxConstraints(
              maxHeight: 40, // Ensure consistent height
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              padding: const EdgeInsets.all(8), // Adjust clear icon padding
              icon: const Icon(Icons.clear, size: 20), // Smaller clear icon
              onPressed: () {
                _searchController.clear();
                _productsProvider.setFilterSearchQuery('',widget.catId);
              },
            ) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTypeItem(String type, ProductsDataProvider provider) {
    final isSelected = provider.selectedFilterType.toLowerCase() == type.toLowerCase();
    return InkWell(
      onTap: () => provider.setFilterType(type.toLowerCase(),widget.catId),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(16),
          horizontal: getProportionateScreenWidth(16),
        ),

        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        child: Row(
          children: [

            if (isSelected)
              Container(
                width: 8,
                height: 8,
                margin:  EdgeInsets.only(right: getProportionateScreenHeight(8)),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              type,
              style: bodyStyleStyleB2SemiBold.copyWith(  color: isSelected ? kPrimaryColor : Colors.black,
                fontWeight:  FontWeight.w900 )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandList(ProductsDataProvider provider) {
    if (provider.brands.isEmpty) {
      return  Center(child: Text('No brands found',style: bodyStyleStyleB3Medium,));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: provider.brands.length,
      itemBuilder: (context, index) {
        final brand = provider.brands[index];
        final isSelected = provider.selectedBrandId == brand.id.toString();
        return InkWell(
          onTap: () async {
            await provider.updateBrandFilter(brand.id.toString());
            NavigationService.instance.goBack();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Radio<String>(
                    value: brand.id.toString(),
                    groupValue: provider.selectedBrandId,
                    onChanged: (value) async {
                      await provider.updateBrandFilter(value);
                      NavigationService.instance.goBack();
                    },
                    activeColor: kPrimaryColor,
                  ),
                ),
                Text(
                  '${brand.name} (15)',
                    style: bodyStyleStyleB2SemiBold.copyWith(color:isSelected ? kPrimaryColor : Colors.black, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500, )
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeList(ProductsDataProvider provider) {
    if (provider.types.isEmpty) {
      return const Center(child: Text('No types found'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: provider.types.length,
      itemBuilder: (context, index) {
        final type = provider.types[index];
        final isSelected = provider.selectedType == type.id.toString();
        return InkWell(
          onTap: () async {
            await provider.updateTypeFilter(type.id.toString());
            NavigationService.instance.goBack();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Radio<String>(
                    value: type.id.toString(),
                    groupValue: provider.selectedType,
                    onChanged: (value) async {
                      await provider.updateTypeFilter(value);
                      NavigationService.instance.goBack();
                    },
                    activeColor: kPrimaryColor,
                  ),
                ),
                Text(
                  type.name,
                    style: bodyStyleStyleB2SemiBold.copyWith(color:isSelected ? kPrimaryColor : Colors.black, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500, )

                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: getProportionateScreenHeight(10),),
          Expanded(
            child: _buildFilterList(context.watch<ProductsDataProvider>()),
          ),
        ],
      ),
    );
  }
}