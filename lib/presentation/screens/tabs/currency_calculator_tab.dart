import 'package:audioplayers/audioplayers.dart';
import 'package:app/infrastructure/cubits/currency/currency_cubit.dart';
import 'package:app/infrastructure/hive_adapters/currency_model/currency_model.dart';
import 'package:app/presentation/widgets/common/bottom_padding.dart';
import 'package:app/presentation/widgets/unique/tappable_currency_tile.dart';
import 'package:app/utilities/constants/theme_globals.dart';
import 'package:app/utilities/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyCalculatorTab extends StatefulWidget {
  @override
  _CurrencyCalculatorTabState createState() => _CurrencyCalculatorTabState();
}

class _CurrencyCalculatorTabState extends State<CurrencyCalculatorTab> {
  late final AudioCache _audioCache;
  late final CurrencyCubit _currencyCubit;

  @override
  void initState() {
    _audioCache = AudioCache();
    _currencyCubit = BlocProvider.of<CurrencyCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          BottomPadding(color: Colors.white, defaultBottom: 0.0),
        ],
      ),
    );
  }

  Widget buildCalculation(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(bottom: 10.0),
      color: primaryColor,
      child: Column(
        children: <Widget>[
          _buildFromCurrency(),
          _buildChangeCurrenciesButton(),
          _buildToCurrency(),
        ],
      ),
    );
  }

  Widget _buildChangeCurrenciesButton() {
    return CircleAvatar(
      radius: 23.0,
      backgroundColor: greenColor,
      child: GestureDetector(
        child: Icon(Icons.swap_vert, size: 32.0, color: Colors.white),
        onTap: _currencyCubit.swapCurrencies,
      ),
    );
  }

  Widget _buildToCurrency() {
    return StreamBuilder<CurrencyModel>(
      stream: _currencyCubit.toCurrency$,
      builder: (context, snapshot) {
        final currency = snapshot.data;

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
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (Widget child, Animation<double> animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Text(
                          '${(snapshot.data ?? 0).asFormatted}',
                          style: size32weight400.copyWith(color: Colors.white),
                          key: UniqueKey(),
                        ),
                      );
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
      },
    );
  }

  Widget _buildFromCurrency() {
    return StreamBuilder<CurrencyModel>(
      stream: _currencyCubit.fromCurrency$,
      builder: (context, snapshot) {
        final currency = snapshot.data;

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
                        child: Text('${(snapshot.data ?? 0).asFormatted}', style: size32weight400.copyWith(color: Colors.white)),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
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
                _buildNumberButton(1),
                _buildNumberButton(2),
                _buildNumberButton(3),
              ],
            ),
          ),
          // SizedBox(height: 10.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNumberButton(4),
                _buildNumberButton(5),
                _buildNumberButton(6),
              ],
            ),
          ),
          // SizedBox(height: 10.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNumberButton(7),
                _buildNumberButton(8),
                _buildNumberButton(9),
              ],
            ),
          ),
          // SizedBox(height: 10.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildDotButton(),
                _buildNumberButton(0),
                _buildBackspaceButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _currencyCubit.dropLastDigitFromTypedValue();
          playSound();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
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

  Widget _buildDotButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _currencyCubit.addTwoZerosToTypedValue();
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

  Widget _buildNumberButton(int value) {
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
