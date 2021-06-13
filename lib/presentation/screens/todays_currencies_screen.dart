import 'package:app/infrastructure/cubits/currency/currency_cubit.dart';
import 'package:app/infrastructure/hive_adapters/currency_model/currency_model.dart';
import 'package:app/presentation/widgets/bottom_padding.dart';
import 'package:app/presentation/widgets/currency_list_item.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:app/utilities/constants/theme_globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodaysCurrenciesScreen extends StatelessWidget {
  final CurrencyCubit currencyCubit;

  TodaysCurrenciesScreen({required this.currencyCubit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        buildSearchField(),
        SizedBox(height: 8.0),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildList(),
                BottomPadding(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<CurrencyModel>>(
      stream: currencyCubit.filteredList$,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, position) {
              if (position == 0) return SizedBox.shrink();

              return CurrencyListItem(snapshot.data!.elementAt(position));
            },
            separatorBuilder: (_, __) => SizedBox(height: 6.0), 
          );
        }

        return LoadingIndicator();
      },
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          currencyCubit.updateFilter('');
          Navigator.of(context).pop();
        },
      ),
      title: Text('Bugünün məzənnələri'),
    );
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CupertinoTextField(
        clearButtonMode: OverlayVisibilityMode.editing,
        padding: const EdgeInsets.all(10.0),
        placeholder: 'axtar',
        prefix: const Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: const Icon(
            Icons.search,
            color: Colors.black54,
          ),
        ),
        onChanged: (value) => currencyCubit.updateFilter(value),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}