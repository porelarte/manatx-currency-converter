import 'package:app/presentation/widgets/custom_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/infrastructure/cubits/currency/currency_cubit.dart';
import 'package:app/infrastructure/hive_adapters/currency_model/currency_model.dart';
import 'package:app/presentation/screens/todays_currencies_tab.dart';
import 'package:app/presentation/widgets/bottom_padding.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:app/presentation/widgets/tappable_currency_tile.dart';
import 'package:app/utilities/constants/theme_globals.dart';
import 'package:app/utilities/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyCalculatorScreen extends StatefulWidget {
  @override
  _CurrencyCalculatorScreenState createState() => _CurrencyCalculatorScreenState();
}

class _CurrencyCalculatorScreenState extends State<CurrencyCalculatorScreen> {
  late final _audioCache;
  late CurrencyCubit _currencyCubit;

  @override
  void initState() {
    _audioCache = new AudioCache();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _currencyCubit = BlocProvider.of<CurrencyCubit>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _currencyCubit.close();
    _audioCache.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      initialData: 0,
      stream: _currencyCubit.tabIndex$,
      builder: (context, snapshot) {
        final tabIndex = snapshot.data;

        return Scaffold(
          appBar: CustomAppBar(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: _buildAppBar(),
          ),
          body: (tabIndex == 0) ? _buildBody() : TodaysCurrenciesTab(),
        );
      },
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            flex: 65,
            child: buildCalculation(context),
          ),
          Flexible(
            flex: 35,
            child: buildButtonRows(),
          ),
          BottomPadding(color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTab(title: 'Kalkulyator', index: 0),
          SizedBox(width: 8.0),
          _buildTab(title: 'Məzənnələr', index: 1),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required int index,
  }) {
    final isCurrent = index == _currencyCubit.tabIndex;

    return Expanded(
      child: InkWell(
        onTap: () => _currencyCubit.updateTabIndex(index),
        child: Container(
          height: 36.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: isCurrent ? greenColor : Colors.white10,
            border: Border.all(color: isCurrent ? greenColor : Colors.white10, width: 2.0),
          ),
          child: Text(
            title.toString(),
            style: (isCurrent ? size15weight500 : size15weight400).copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildCalculation(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(bottom: 10.0),
      color: primaryColor,
      child: Column(
        children: <Widget>[
          buildFromCurrency(),
          buildChangeCurrenciesButton(),
          buildToCurrency(),
        ],
      ),
    );
  }

  Widget buildChangeCurrenciesButton() {
    return CircleAvatar(
      radius: 23.0,
      backgroundColor: greenColor,
      child: GestureDetector(
        child: Icon(Icons.swap_vert, size: 32.0, color: Colors.white),
        onTap: _currencyCubit.swapCurrencies,
      ),
    );
  }

  Widget buildToCurrency() {
    return StreamBuilder<CurrencyModel>(
      stream: _currencyCubit.toCurrency$,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currency = snapshot.data!;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: StreamBuilder<double>(
                      initialData: 0.0,
                      stream: _currencyCubit.convertedValue$,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('${snapshot.data!.asFormatted}', style: size32weight400.copyWith(color: Colors.white));
                        }

                        return LoadingIndicator();
                      },
                    ),
                  ),
                ),
                TappableCurrencyTile(
                  currency: currency,
                  toCurrency: true,
                ),
              ],
            ),
          );
        }

        return LoadingIndicator();
      },
    );
  }

  Widget buildFromCurrency() {
    return StreamBuilder<CurrencyModel>(
      stream: _currencyCubit.fromCurrency$,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currency = snapshot.data!;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TappableCurrencyTile(
                  currency: currency,
                  toCurrency: false,
                ),
                Expanded(
                  child: Center(
                    child: StreamBuilder<double>(
                      initialData: 0,
                      stream: _currencyCubit.typedValue$,
                      builder: (context, snapshot) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white70)),
                          ),
                          child: Text('${snapshot.data!.asFormatted}', style: size32weight400.copyWith(color: Colors.white)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return LoadingIndicator();
      },
    );
  }

  Widget buildButtonRows() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildNumberButton(1),
                buildNumberButton(2),
                buildNumberButton(3),
              ],
            ),
          ),
          // SizedBox(height: 10.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildNumberButton(4),
                buildNumberButton(5),
                buildNumberButton(6),
              ],
            ),
          ),
          // SizedBox(height: 10.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildNumberButton(7),
                buildNumberButton(8),
                buildNumberButton(9),
              ],
            ),
          ),
          // SizedBox(height: 10.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildDotButton(),
                buildNumberButton(0),
                buildBackspaceButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackspaceButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _currencyCubit.dropLastDigitFromTypedValue();
          playSound();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.all(5.0),
          width: MediaQuery.of(context).size.width / 3,
          child: Icon(
            Icons.backspace,
            size: 29.0,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ),
    );
  }

  Widget buildDotButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print('object');
          // _currencyCubit.addTwoZerosToTypedValue();
          playSound();
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3,
          color: Colors.white,
          child: Text(
            '00',
            style: TextStyle(color: Colors.black, fontSize: 25.0),
          ),
        ),
      ),
    );
  }

  Widget buildNumberButton(int value) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _currencyCubit.addToTypedValue(value);
          playSound();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: .5,
              color: Colors.grey[200]!,
            ),
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 3,
          child: Text(
            '$value',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
            ),
          ),
        ),
      ),
    );
  }

  void playSound() {
    if (_currencyCubit.typedValue == 0) {
      _audioCache.play('sounds/exceeded.mp3', volume: .1);
    } else if (_currencyCubit.typedValue < CurrencyCubit.max_input) {
      _audioCache.play('sounds/key.mp3', volume: .1);
    } else {
      _audioCache.play('sounds/exceeded.mp3', volume: .1);
    }
  }
}
