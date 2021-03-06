//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Includes.
#include "Terminal.mqh"

#ifdef __MQL5__
// Define MQL4 constants in MQL5.
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
// --
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
#endif

/**
 * Class to provide market information.
 */
class Market {

protected:
    string symbol; // Current symbol pair.
    double pip_size; // Value of pip size.
    uint symbol_digits; // Count of digits after decimal point in the symbol price.
    uint pip_digits;  // Number of digits for a pip.
    uint pts_per_pip; // Number of points per pip.
    double volume_precision;

public:

  /**
   * Implements class constructor with a parameter.
   */
  Market(string _symbol = NULL) :
    symbol(_symbol == NULL ? _Symbol : _symbol),
    pip_size(GetPipSize()),
    pip_digits(GetPipDigits()),
    symbol_digits(GetSymbolDigits()),
    pts_per_pip(GetPointsPerPip())
  {
  }

  /**
   * Get current symbol pair used by the class.
   */
  string GetSymbol() {
    return symbol;
  }

  /**
   * Get the symbol pair from the current chart.
   */
  string GetChartSymbol() {
    return _Symbol;
  }

  /**
   * Get ask price (best buy offer).
   */
  double GetAsk() {
    return SymbolInfoDouble(symbol, SYMBOL_ASK);
  }
  static double GetAsk(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_ASK);
  }

  /**
   * Get bid price (best sell offer).
   */
  double GetBid() {
    return SymbolInfoDouble(symbol, SYMBOL_BID);
  }
  static double GetBid(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_BID);
  }


  /**
   * The latest known seller's price (ask price) for the current symbol.
   * The RefreshRates() function must be used to update.
   *
   * @see http://docs.mql4.com/predefined/ask
   */
  double Ask() {
    MqlTick last_tick;
    SymbolInfoTick(symbol,last_tick);
    return last_tick.ask;

    // Overriding Ask variable to become a function call.
    #ifdef __MQL5__
    #define Ask Market::Ask()
    #endif
  }

  /**
   * The latest known buyer's price (offer price, bid price) of the current symbol.
   * The RefreshRates() function must be used to update.
   *
   * @see http://docs.mql4.com/predefined/bid
   */
  double Bid() {
    MqlTick last_tick;
    SymbolInfoTick(symbol, last_tick);
    return last_tick.bid;

    // Overriding Bid variable to become a function call.
    #ifdef __MQL5__
    #define Bid Market::Bid()
    #endif
  }

  /**
   * Get the point size in the quote currency.
   *
   * The smallest digit of price quote.
   * A change of 1 in the least significant digit of the price.
   * You may also use Point predefined variable for the current symbol.
   */
  double GetPointSize() {
    return SymbolInfoDouble(symbol, SYMBOL_POINT); // Same as: MarketInfo(symbol, MODE_POINT);
  }
  static double GetPointSize(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_POINT); // Same as: MarketInfo(symbol, MODE_POINT);
  }

  /**
   * Return a pip size.
   *
   * In most cases, a pip is equal to 1/100 (.01%) of the quote currency.
   */
  double GetPipSize() {
    // @todo: This code may fail at Gold and Silver (https://www.mql5.com/en/forum/135345#515262).
    return GetSymbolDigits() % 2 == 0 ? GetPointSize() : GetPointSize() * 10;
  }

  /**
   * Get a tick size in the price value.
   *
   * It is the smallest movement in the price quoted by the broker,
   * which could be several points.
   * In currencies it is equivalent to point size, in metals they are not.
   */
  double GetTickSize() {
    // Note: In currencies a tick is always a point, but not for other markets.
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
  }
  static double GetTickSize(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
  }

  /**
   * Get a tick size in points.
   *
   * It is a minimal price change in points.
   * In currencies it is equivalent to point size, in metals they are not.
   */
  double GetSymbolTradeTickSize() {
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
  }

  /**
   * Get a tick value in the deposit currency.
   *
   * It gives you the number of base currency units for one pip of movement.
   */
  double GetTickValue() {
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE); // Same as: MarketInfo(symbol, MODE_TICKVALUE);
  }
  double GetTickValue(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE); // Same as: MarketInfo(symbol, MODE_TICKVALUE);
  }

  /**
   * Get count of digits after decimal point for the symbol price.
   *
   * For the current symbol, it is stored in the predefined variable Digits.
   *
   */
  uint GetSymbolDigits() {
    return (uint) SymbolInfoInteger(symbol, SYMBOL_DIGITS); // Same as: MarketInfo(symbol, MODE_DIGITS);
  }
  static uint GetSymbolDigits(string _symbol) {
    return (uint) SymbolInfoInteger(_symbol, SYMBOL_DIGITS); // Same as: MarketInfo(symbol, MODE_DIGITS);
  }

  /**
   * Get pip precision.
   */
  int GetPipDigits() {
    return (GetSymbolDigits() < 4 ? 2 : 4);
  }

  /**
   * Get current spread in points.
   *
   * @param
   *   symbol string (optional)
   *   Currency pair symbol.
   *
   * @return
   *   Return symbol trade spread level in points.
   */
  uint GetSpreadInPts() {
    return (uint) SymbolInfoInteger(symbol, SYMBOL_SPREAD);
  }
  uint GetSpreadInPts(string _symbol) {
    return (uint) SymbolInfoInteger(_symbol, SYMBOL_SPREAD);
  }

  /**
   * Get current spread in float.
   */
  double GetSpreadInPips() {
    return (GetAsk() - GetBid()) * pow(10, GetPipDigits());
  }

  /**
   * Get current spread in percent.
   */
  double GetSpreadInPct() {
    return 100.0 * (GetAsk() - GetBid()) / GetAsk();
  }

  /**
   * Get number of points per pip.
   *
   * To be used to replace Point for trade parameters calculations.
   * See: http://forum.mql4.com/30672
   */
  int GetPointsPerPip() {
    return (int) pow(10, GetSymbolDigits() - GetPipDigits());
  }

  /**
   * Minimal indention in points from the current close price to place Stop orders.
   *
   * This is due that at placing of a pending order, the open price cannot be too close to the market.
   * The minimal distance of the pending price from the current market one in points can be obtained
   * using the MarketInfo() function with the MODE_STOPLEVEL parameter.
   * Related error messages:
   *   Error 130 (ERR_INVALID_STOPS) happens In case of false open price of a pending order.
   *   Error 145 (ERR_TRADE_MODIFY_DENIED) happens when modification of order was too close to market.
   *
   *
   * @param
   *   symbol string (optional)
   *   Currency pair symbol.
   *
   * @return
   *   Returns the minimal permissible distance value in points for StopLoss/TakeProfit.
   *   A zero value means either absence of any restrictions on the minimal distance.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  long GetTradeStopsLevel() {
    return SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
  }
  static long GetTradeStopsLevel(string _symbol) {
    return SymbolInfoInteger(_symbol, SYMBOL_TRADE_STOPS_LEVEL);
  }

  /**
   * Get a market distance in points.
   *
   * Minimal permissible distance value in points for StopLoss/TakeProfit.
   *
   * This is due that at placing of a pending order, the open price cannot be too close to the market.
   * The minimal distance of the pending price from the current market one in points can be obtained
   * using the MarketInfo() function with the MODE_STOPLEVEL parameter.
   * Related error messages:
   *   Error 130 (ERR_INVALID_STOPS) happens In case of false open price of a pending order.
   *   Error 145 (ERR_TRADE_MODIFY_DENIED) happens when modification of order was too close to market.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  long GetTradeDistanceInPts() {
    return fmax(GetTradeStopsLevel(), GetFreezeLevel());
  }

  /**
   * Get a market distance in pips.
   *
   * Minimal permissible distance value in pips for StopLoss/TakeProfit.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  double GetTradeDistanceInPips() {
    // @fixme
    return (double) (GetTradeDistanceInPts() / GetPointsPerPip());
  }

  /**
   * Get a market gap in value.
   *
   * Minimal permissible distance value in value for StopLoss/TakeProfit.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  double GetTradeDistanceInValue() {
    return GetTradeDistanceInPts() * GetPointSize();
  }

    /**
     * Validate whether trade operation is permitted.
     *
     * @param int cmd
     *   Trade command.
     * @param int sl
     *   Stop loss price value.
     * @param int tp
     *   Take profit price value.
     * @param string symbol
     *   Currency symbol.
     * @return
     *   Returns true when trade operation is allowed.
     *
     * @see: https://book.mql4.com/appendix/limits
     * @see: https://www.mql5.com/en/articles/2555#invalid_SL_TP_for_position
     */
    double TradeOpAllowed(ENUM_ORDER_TYPE _cmd, double sl, double tp) {
      double ask = GetAsk();
      double bid = GetBid();
      double openprice = GetOpenPrice(_cmd);
      double closeprice = GetClosePrice(_cmd);
      // The minimum distance of SYMBOL_TRADE_STOPS_LEVEL taken into account.
      double distance = GetTradeDistanceInValue();
      // bool result;
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          // Buying is done at the Ask price.
          // Requirements for Minimum Distance Limitation:
          // - Bid - StopLoss >= StopLevel  && TakeProfit - Bid >= StopLevel
          // - Bid - StopLoss > FreezeLevel && TakeProfit - Bid > FreezeLevel
          /*
          result = sl > 0 && tp > 0 && bid - sl >= distance && tp - bid >= distance;
          PrintFormat("1. Buy: (%g - %g) = %g >= %g; %s", Bid, sl, (bid - sl), distance, result ? "true" : "false");
          PrintFormat("2. Buy: (%g - %g) = %g >= %g; %s", tp, Bid, (tp - Bid), distance, result ? "true" : "false");
          */
          // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from the Bid price.
          return sl > 0 && tp > 0 &&
            bid - sl >= distance &&
            tp - bid >= distance;
        case ORDER_TYPE_SELL:
          // Selling is done at the Bid price.
          // Requirements for Minimum Distance Limitation:
          // - StopLoss - Ask >= StopLevel  && Ask - TakeProfit >= StopLevel
          // - StopLoss - Ask > FreezeLevel && Ask - TakeProfit > FreezeLevel
          /*
          result = sl > 0 && tp > 0 && sl - ask > distance && ask - tp > distance;
          PrintFormat("1. Sell: (%g - %g) = %g >= %g; %s",
            sl, Ask, (sl - Ask), distance, result ? "true" : "false");
          PrintFormat("2. Sell: (%g - %g) = %g >= %g; %s",
            Ask, tp, (ask - tp), distance, result ? "true" : "false");
          */
          // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from the Ask price.
          return sl > 0 && tp > 0 &&
            sl - ask > distance &&
            ask - tp > distance;
        case ORDER_TYPE_BUY_LIMIT:
          // Requirements when performing trade operations:
          // - Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
          // - Open Price of a Pending Order is Below the current Ask price.
          // - Ask price reaches open price.
          return
            ask - openprice >= distance &&
            openprice - sl >= distance &&
            tp - openprice >= distance;
        case ORDER_TYPE_SELL_LIMIT:
          // Requirements when performing trade operations:
          // - OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
          // - Open Price of a Pending Order is Above the current Bid price.
          // - Bid price reaches open price.
          return
            openprice - bid >= distance &&
            sl - openprice >= distance &&
            openprice - tp >= distance;
        case ORDER_TYPE_BUY_STOP:
          // Requirements when performing trade operations:
          // - OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
          // - Open Price of a Pending Order is Above the current Ask price.
          // - Ask price reaches open price.
          return
            openprice - ask >= distance &&
            openprice - sl >= distance &&
            tp - openprice >= distance;
        case ORDER_TYPE_SELL_STOP:
          // Requirements when performing trade operations:
          // - Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
          // - Open Price of a Pending Order is Below the current Bid price.
          // - Bid price reaches open price.
          return
            bid - openprice >= distance &&
            sl - openprice >= distance &&
            openprice - tp >= distance;
        default:
          return (true);
      }
    }

    /**
     * Validate whether trade operation is permitted.
     *
     * @param int cmd
     *   Trade command.
     * @param int price
     *   Take profit or stop loss price value.
     * @return
     *   Returns true when trade operation is allowed.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    double TradeOpAllowed(ENUM_ORDER_TYPE _cmd, double price) {
      double ask = GetAsk();
      double bid = GetBid();
      double distance = GetTradeDistanceInPips() + GetPipSize();
      // bool result;
      switch (_cmd) {
        case ORDER_TYPE_BUY_STOP:
          // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        case ORDER_TYPE_BUY_LIMIT:
          // Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        case ORDER_TYPE_BUY:
          // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case ORDER_TYPE_SELL_LIMIT:
          // OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case ORDER_TYPE_SELL_STOP:
          // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case ORDER_TYPE_SELL:
          /*
          result = price > 0 && ask - price > distance && price - ask > distance;
          PrintFormat("%s: 1: %g - %g = %g > %g; %s",
              __FUNCTION__, bid, price, bid - price, distance, result ? "true" : "false");
          PrintFormat("%s: 2: %g - %g = %g > %g; %s",
              __FUNCTION__, ask, price, ask - price, distance, result ? "true" : "false");
           */
          // return price > 0 && fabs(bid - price) > distance && fabs(ask - price) > distance;
          return price > 0 &&
            fabs(bid - price) > distance &&
            fabs(ask - price) > distance;
        default:
          return (true);
      }
    }

  /**
   * Get a lot step.
   */
  double GetLotStepInPips() {
    // @todo: Correct bit shifting.
    return fmax(GetLotStepInPts(), 10 >> GetPipDigits());
  }

  /**
   * Get a lot/volume step.
   */
  double GetLotStepInPts() {
    // @todo: Correct bit shifting.
    return SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP); // Same as: MarketInfo(symbol, MODE_LOTSTEP);
  }
  static double GetLotStepInPts(string _symbol) {
    // @todo: Correct bit shifting.
    return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP); // Same as: MarketInfo(symbol, MODE_LOTSTEP);
  }

  /**
   * Get a lot size in the base currency.
   */
  double GetLotSize() {
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Same as: MarketInfo(symbol, MODE_LOTSIZE);
  }
  static double GetLotSize(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Same as: MarketInfo(symbol, MODE_LOTSIZE);
  }

  /**
   * Minimum permitted amount of a lot/volume.
   */
  double GetMinLot() {
    return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN); // Same as: MarketInfo(symbol, MODE_MINLOT);
  }
  double GetMinLot(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); // Same as: MarketInfo(symbol, MODE_MINLOT);
  }

  /**
   * Maximum permitted amount of a lot/volume.
   */
  double GetMaxLot() {
    return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX); // Same as: MarketInfo(symbol, MODE_MAXLOT);
  }
  static double GetMaxLot(string _symbol) {
    return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX); // Same as: MarketInfo(symbol, MODE_MAXLOT);
  }

  /**
   * Get a volume precision.
   */
  int GetVolumeDigits() {
    return (int)
      -log10(
          fmin(
            GetLotStepInPts(),
            GetMinLot()
          )
      );
  }

  /**
   * Order freeze level in points.
   *
   * Freeze level is a value that determines the price band,
   * within which the order is considered as 'frozen' (prohibited to change).
   *
   * If the execution price lies within the range defined by the freeze level,
   * the order cannot be modified, cancelled or closed.
   * The possibility of deleting a pending order is regulated by the FreezeLevel.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  uint GetFreezeLevel() {
    return (uint) SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL); // Same as: MarketInfo(symbol, MODE_FREEZELEVEL);
  }
  static uint GetFreezeLevel(string _symbol) {
    return (uint) SymbolInfoInteger(_symbol, SYMBOL_TRADE_FREEZE_LEVEL); // Same as: MarketInfo(symbol, MODE_FREEZELEVEL);
  }

  /**
   * Initial margin requirements for 1 lot.
   */
  double GetMarginInit() {
    return SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL); // Same as: MarketInfo(symbol, MODE_MARGININIT);
  }

  /**
   * Free margin required to open 1 lot for buying.
   */
  double GetMarginRequired() {
    #ifdef __MQL4__
    return MarketInfo(symbol, MODE_MARGINREQUIRED);
    #else
    // @todo
    // @see: https://www.mql5.com/en/articles/81
    // OrderCalcMargin()?
    return (0);
    #endif
  }

  /**
   * Get current open price depending on the operation type.
   *
   * @param:
   *   op_type int Order operation type of the order.
   * @return
   *   Current open price.
   */
  double GetOpenPrice(ENUM_ORDER_TYPE _cmd = NULL) {
    if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE); // Same as: OrderType();
    return _cmd == ORDER_TYPE_BUY ? GetAsk() : GetBid();
  }

  /**
   * Returns open price of a bar.
   */
  double GetOpen(uint _bar = 0) {
    #ifdef __MQL5__
    double Open[];
    ArraySetAsSeries(Open, true);
    CopyOpen(symbol,_Period, 0, _bar, Open);
    #endif
    return Open[_bar];
  }

  /**
   * Returns close price of a bar.
   */
  double GetClose(uint _bar = 0) {
    #ifdef __MQL5__
    double Close[];
    ArraySetAsSeries(Close, true);
    CopyOpen(symbol,_Period, 0, _bar, Close);
    #endif
    return Close[_bar];
  }

  /**
   * Returns low price of a bar.
   */
  double GetLow(uint _bar = 0) {
    #ifdef __MQL5__
    double Low[];
    ArraySetAsSeries(Low, true);
    CopyOpen(symbol,_Period, 0, _bar, Low);
    #endif
    return Low[_bar];
  }

  /**
   * Returns high price of a bar.
   */
  double GetHigh(uint _bar = 0) {
    #ifdef __MQL5__
    double High[];
    ArraySetAsSeries(High, true);
    CopyOpen(symbol,_Period, 0, _bar, High);
    #endif
    return High[_bar];
  }

  /**
   * Returns Time value for the bar of indicated symbol with timeframe and shift.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static datetime iTime(string _symbol, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    #ifdef __MQL4__
    return ::iTime(_symbol, timeframe, shift);
    #else // __MQL5__
    datetime arr[];
    if (::CopyTime(_symbol, timeframe, shift, 1, arr) > 0) {
      return (arr[0]);
    } else {
      return (-1);
    }
    #endif
  }
  datetime iTime(ENUM_TIMEFRAMES timeframe, int shift = 0) {
    return iTime(symbol, timeframe, shift);
  }

  /**
   * Returns Open value for the bar of indicated symbol with timeframe and shift.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iOpen(string _symbol, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    #ifdef __MQL4__
    return ::iOpen(_symbol, timeframe, shift);
    #else // __MQL5__
    double arr[];
    if (CopyOpen(_symbol, timeframe, shift, 1, arr) > 0) {
      return (arr[0]);
    } else {
      return (-1);
    }
    #endif
  }
  double iOpen(ENUM_TIMEFRAMES timeframe, int shift = 0) {
    return iOpen(symbol, timeframe, shift);
  }

  /**
   * Returns Close value for the bar of indicated symbol with timeframe and shift.
   *
   * If local history is empty (not loaded), function returns 0.
   *
   * @see http://docs.mql4.com/series/iclose
   */
  static double iClose(string _symbol, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    #ifdef __MQL4__
    return ::iClose(_symbol, timeframe, shift);
    #else // __MQL5__
    double arr[];
    if (CopyClose(_symbol, timeframe, shift, 1, arr) > 0) {
      return (arr[0]);
    } else {
      return (-1);
    }
    #endif
  }
  double iClose(ENUM_TIMEFRAMES timeframe, int shift = 0) {
    return iClose(symbol, timeframe, shift);
  }

  /**
   * Returns Low value for the bar of indicated symbol with timeframe and shift.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iLow(string _symbol, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    #ifdef __MQL4__
    return ::iLow(_symbol, timeframe, shift);
    #else // __MQL5__
    double arr[];
    if (CopyLow(_symbol, timeframe, shift, 1, arr) > 0) {
      return (arr[0]);
    } else {
      return (-1);
    }
    #endif
  }
  double iLow(ENUM_TIMEFRAMES timeframe, int shift = 0) {
    return iLow(symbol, timeframe, shift);
  }

  /**
   * Returns Low value for the bar of indicated symbol with timeframe and shift.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iHigh(string _symbol, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    #ifdef __MQL4__
    return ::iHigh(_symbol, timeframe, shift);
    #else // __MQL5__
    double arr[];
    if (CopyHigh(_symbol, timeframe, shift, 1, arr) > 0) {
      return (arr[0]);
    } else {
      return (-1);
    }
    #endif
  }
  double iHigh(ENUM_TIMEFRAMES timeframe, int shift = 0) {
    return iHigh(symbol, timeframe, shift);
  }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  static int iHighest(string _symbol, ENUM_TIMEFRAMES timeframe, int type, int count = WHOLE_ARRAY, int start = 0) {
    #ifdef __MQL4__
    return ::iHighest(_symbol, timeframe, type, count, start);
    #else // __MQL5__
    if (start < 0) return (-1);
    if (count <= 0) {
      count = Bars(_symbol, timeframe);
    }
    double arr_d[];
    long arr_l[];
    datetime arr_dt[];
    ArraySetAsSeries(arr_d, true);
    switch (type) {
      case MODE_OPEN:
        CopyOpen(_symbol, timeframe, start, count, arr_d);
        break;
      case MODE_LOW:
        CopyLow(_symbol, timeframe, start, count, arr_d);
        break;
      case MODE_HIGH:
        CopyHigh(_symbol, timeframe, start, count, arr_d);
        break;
      case MODE_CLOSE:
        CopyClose(_symbol, timeframe, start, count, arr_d);
        break;
      case MODE_VOLUME:
        ArraySetAsSeries(arr_l, true);
        CopyTickVolume(_symbol, timeframe, start, count, arr_l);
        return (ArrayMaximum(arr_l, 0, count) + start);
      case MODE_TIME:
        ArraySetAsSeries(arr_dt, true);
        CopyTime(_symbol, timeframe, start, count, arr_dt);
        return (ArrayMaximum(arr_dt, 0, count) + start);
      default:
        break;
    }
    return (ArrayMaximum(arr_d, 0, count) + start);
    #endif
  }
  int iHighest(ENUM_TIMEFRAMES timeframe, int type, int count = WHOLE_ARRAY, int start = 0) {
    return iHighest(symbol, timeframe, type, count, start);
  }

  /**
   * Returns the shift of the lowest value over a specific number of periods depending on type.
   */
  static int iLowest(string _symbol, ENUM_TIMEFRAMES timeframe, int type, int count = WHOLE_ARRAY, int start = 0) {
    #ifdef __MQL4__
    return ::iLowest(_symbol, timeframe, type, count, start);
    #else // __MQL5__
    if (start < 0) return (-1);
    if (count <= 0) {
      count = Bars(_symbol, timeframe);
    }
    // @todo
    // @see: iHighest().
    return 0; // (ArrayMaximum(arr_d, 0, count) + start);
    #endif
  }
  int iLowest(ENUM_TIMEFRAMES timeframe, int type, int count = WHOLE_ARRAY, int start = 0) {
    return iLowest(symbol, timeframe, type, count, start);
  }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  static int iBarShift(string _symbol, ENUM_TIMEFRAMES _timeframe, datetime _time, bool _exact = false) {
    #ifdef __MQL4__
    return iBarShift(_symbol, _timeframe, _time, _exact);
    #else // __MQL5__
    if (_time < 0) return (-1);
    datetime arr[], time0;
    CopyTime(_symbol, _timeframe, 0, 1, arr);
    time0 = arr[0];
    if (CopyTime(_symbol,_timeframe, _time, time0, arr) > 0) {
      if (ArraySize(arr) > 2 ) {
        return(ArraySize(arr) - 1);
      } else {
        return _time < time0 ? 1 : 0;
      }
    } else {
      return (-1);
    }
    #endif
  }

  /**
   * Returns market data about securities.
   */
  double MarketInfo(string _symbol, int _type) {
    switch(_type) {
      case MODE_LOW:               return SymbolInfoDouble(_symbol, SYMBOL_LASTLOW);
      case MODE_HIGH:              return SymbolInfoDouble(_symbol, SYMBOL_LASTHIGH);
      case MODE_TIME:              return (double) SymbolInfoInteger(_symbol, SYMBOL_TIME); // Time of the last quote.
      case MODE_BID:               return GetBid(_symbol);
      case MODE_ASK:               return GetAsk(_symbol);
      case MODE_POINT:             return GetPointSize(_symbol);
      case MODE_DIGITS:            return GetSymbolDigits(_symbol);
      case MODE_SPREAD:            return GetSpreadInPts(_symbol);
      case MODE_STOPLEVEL:         return (double) GetTradeStopsLevel(_symbol);
      case MODE_LOTSIZE:           return GetLotSize(_symbol);
      case MODE_TICKVALUE:         return GetTickValue(_symbol);
      case MODE_TICKSIZE:          return GetTickSize(_symbol);
      case MODE_SWAPLONG:          return SymbolInfoDouble(_symbol, SYMBOL_SWAP_LONG);
      case MODE_SWAPSHORT:         return SymbolInfoDouble(_symbol, SYMBOL_SWAP_SHORT);
      case MODE_MINLOT:            return GetMinLot(_symbol);
      case MODE_LOTSTEP:           return GetLotStepInPts(_symbol);
      case MODE_MAXLOT:            return GetMaxLot(_symbol);
      case MODE_SWAPTYPE:          return (double) SymbolInfoInteger(_symbol, SYMBOL_SWAP_MODE);
      case MODE_PROFITCALCMODE:    return (double) SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE);
      case MODE_STARTING:          return (0); // @todo
      case MODE_EXPIRATION:        return (0); // @todo
      case MODE_TRADEALLOWED:      return Terminal::IsTradeAllowed();
      case MODE_MARGINCALCMODE:    return (0); // @todo
      case MODE_MARGININIT:        return (0); // @todo
      case MODE_MARGINMAINTENANCE: return (0); // @todo
      case MODE_MARGINHEDGED:      return (0); // @todo
      case MODE_MARGINREQUIRED:    return GetMarginRequired();
      case MODE_FREEZELEVEL:       return GetFreezeLevel(_symbol);
    }
    return (0);
  }

  /**
   * Get current close price depending on the operation type.
   *
   * @param:
   *   op_type int Order operation type of the order.
   * @return
   * Current close price.
   */
  double GetClosePrice(ENUM_ORDER_TYPE _cmd = NULL) {
    if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE); // Same as: OrderType();
    return _cmd == ORDER_TYPE_BUY ? GetBid() : GetAsk();
  }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  double GetPeakPrice(ENUM_TIMEFRAMES timeframe, int mode, int bars, int index = 0) {
    int ibar = -1;
    // @todo: Add symbol parameter.
    double peak_price = GetOpen(0);
    switch (mode) {
      case MODE_HIGH:
        ibar = iHighest(symbol, timeframe, MODE_HIGH, bars, index);
        return ibar >= 0 ? iHigh(symbol, timeframe, ibar) : false;
      case MODE_LOW:
        ibar =  iLowest(symbol, timeframe, MODE_LOW,  bars, index);
        return ibar >= 0 ? iLow(symbol, timeframe, ibar) : false;
      default:
        return false;
    }
  }


  /**
   * Get delta value per lot in account currency of a point of symbol.
   *
   * @see
   * - https://forum.mql4.com/33975
   * - https://forum.mql4.com/43064#515262
   * - https://forum.mql4.com/41259/page3#512466
   * - https://www.mql5.com/en/forum/127584
   * - https://www.mql5.com/en/forum/135345
   * - https://www.mql5.com/en/forum/133792/page3#512466
   */
  double GetDeltaValue() {
    // Return tick value in the deposit currency divided by tick size in points.
    return GetTickValue() / GetTickSize();
  }

  /**
   * Normalize price value.
   *
   * Make sure that the price is a multiple of ticksize.
   */
  double NormalizePrice(double p) {
    // See: http://forum.mql4.com/47988
    // http://forum.mql4.com/43064#515262 zzuegg reports for non-currency DE30:
    // - MarketInfo(chart.symbol,MODE_TICKSIZE) returns 0.5
    // - MarketInfo(chart.symbol,MODE_DIGITS) return 1
    // - Point = 0.1
    // Rare fix when a change in tick size leads to a change in tick value.
    return round(p / GetPointSize()) * GetTickSize();
  }

  /**
   * Normalize lot size.
   */
  double NormalizeLots(double lots, bool ceiling = false) {
    // Related: http://forum.mql4.com/47988
    double precision = GetLotStepInPts() > 0.0 ? 1 / GetLotStepInPts() : 1 / GetMinLot();
    double lot_size = ceiling ? MathCeil(lots * precision) / precision : MathFloor(lots * precision) / precision;
    lot_size = fmin(fmax(lot_size, GetMinLot()), GetMaxLot());
    return NormalizeDouble(lot_size, GetVolumeDigits());
  }

  /**
   * Refresh data in pre-defined variables and series arrays.
   *
   * @see http://docs.mql4.com/series/refreshrates
   */
  static bool RefreshRates() {
    // In MQL5 returns true for backward compability.
    return #ifdef __MQL4__ ::RefreshRates(); #else true; #endif
  }

  /**
   * Check whether we're trading within market peak hours.
   */
  bool IsPeakHour() {
      int hour;
      #ifdef __MQL5__
      MqlDateTime dt;
      TimeCurrent(dt);
      hour = dt.hour;
      #else
      hour = Hour();
      #endif
      return hour >= 8 && hour <= 16;
  }

  /**
   * Calculates the current market trend.
   *
   * @param
   *   method (int)
   *    Bitwise trend method to use.
   *   tf (ENUM_TIMEFRAMES)
   *     Frequency based on the given timeframe. Use NULL for the current.
   *   symbol (string)
   *     Symbol pair to check against it.
   *   simple (bool)
   *     If true, use simple trend calculation.
   *
   * @return
   *   Returns positive value for bullish, negative for bearish, zero for neutral market trend.
   *
   * @todo: Improve number of increases for bull/bear variables.
   */
  double GetTrend(int method, ENUM_TIMEFRAMES _tf = NULL, bool simple = false) {
    static datetime _last_trend_check = 0;
    static double _last_trend = 0;
    if (_last_trend_check == iTime(symbol, _tf, 0)) {
      return _last_trend;
    }
    double bull = 0, bear = 0;
    int _counter = 0;

    if (simple) {
      if ((method &   1) != 0)  {
        if (iOpen(NULL, PERIOD_MN1, 0) > iClose(NULL, PERIOD_MN1, 1)) bull++;
        if (iOpen(NULL, PERIOD_MN1, 0) < iClose(NULL, PERIOD_MN1, 1)) bear++;
      }
      if ((method &   2) != 0)  {
        if (iOpen(NULL, PERIOD_W1, 0) > iClose(NULL, PERIOD_W1, 1)) bull++;
        if (iOpen(NULL, PERIOD_W1, 0) < iClose(NULL, PERIOD_W1, 1)) bear++;
      }
      if ((method &   4) != 0)  {
        if (iOpen(NULL, PERIOD_D1, 0) > iClose(NULL, PERIOD_D1, 1)) bull++;
        if (iOpen(NULL, PERIOD_D1, 0) < iClose(NULL, PERIOD_D1, 1)) bear++;
      }
      if ((method &   8) != 0)  {
        if (iOpen(NULL, PERIOD_H4, 0) > iClose(NULL, PERIOD_H4, 1)) bull++;
        if (iOpen(NULL, PERIOD_H4, 0) < iClose(NULL, PERIOD_H4, 1)) bear++;
      }
      if ((method &   16) != 0)  {
        if (iOpen(NULL, PERIOD_H1, 0) > iClose(NULL, PERIOD_H1, 1)) bull++;
        if (iOpen(NULL, PERIOD_H1, 0) < iClose(NULL, PERIOD_H1, 1)) bear++;
      }
      if ((method &   32) != 0)  {
        if (iOpen(NULL, PERIOD_M30, 0) > iClose(NULL, PERIOD_M30, 1)) bull++;
        if (iOpen(NULL, PERIOD_M30, 0) < iClose(NULL, PERIOD_M30, 1)) bear++;
      }
      if ((method &   64) != 0)  {
        if (iOpen(NULL, PERIOD_M15, 0) > iClose(NULL, PERIOD_M15, 1)) bull++;
        if (iOpen(NULL, PERIOD_M15, 0) < iClose(NULL, PERIOD_M15, 1)) bear++;
      }
      if ((method &  128) != 0)  {
        if (iOpen(NULL, PERIOD_M5, 0) > iClose(NULL, PERIOD_M5, 1)) bull++;
        if (iOpen(NULL, PERIOD_M5, 0) < iClose(NULL, PERIOD_M5, 1)) bear++;
      }
      //if (iOpen(NULL, PERIOD_H12, 0) > iClose(NULL, PERIOD_H12, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H12, 0) < iClose(NULL, PERIOD_H12, 1)) bear++;
      //if (iOpen(NULL, PERIOD_H8, 0) > iClose(NULL, PERIOD_H8, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H8, 0) < iClose(NULL, PERIOD_H8, 1)) bear++;
      //if (iOpen(NULL, PERIOD_H6, 0) > iClose(NULL, PERIOD_H6, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H6, 0) < iClose(NULL, PERIOD_H6, 1)) bear++;
      //if (iOpen(NULL, PERIOD_H2, 0) > iClose(NULL, PERIOD_H2, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H2, 0) < iClose(NULL, PERIOD_H2, 1)) bear++;
    } else {
      if ((method &   1) != 0)  {
        for (_counter = 0; _counter < 3; _counter++) {
          if (iOpen(NULL, PERIOD_MN1, _counter) > iClose(NULL, PERIOD_MN1, _counter + 1)) bull += 30;
          else if (iOpen(NULL, PERIOD_MN1, _counter) < iClose(NULL, PERIOD_MN1, _counter + 1)) bear += 30;
        }
      }
      if ((method &   2) != 0)  {
        for (_counter = 0; _counter < 8; _counter++) {
          if (iOpen(NULL, PERIOD_W1, _counter) > iClose(NULL, PERIOD_W1, _counter + 1)) bull += 7;
          else if (iOpen(NULL, PERIOD_W1, _counter) < iClose(NULL, PERIOD_W1, _counter + 1)) bear += 7;
        }
      }
      if ((method &   4) != 0)  {
        for (_counter = 0; _counter < 7; _counter++) {
          if (iOpen(NULL, PERIOD_D1, _counter) > iClose(NULL, PERIOD_D1, _counter + 1)) bull += 1440/1440;
          else if (iOpen(NULL, PERIOD_D1, _counter) < iClose(NULL, PERIOD_D1, _counter + 1)) bear += 1440/1440;
        }
      }
      if ((method &   8) != 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (iOpen(NULL, PERIOD_H4, _counter) > iClose(NULL, PERIOD_H4, _counter + 1)) bull += 240/1440;
          else if (iOpen(NULL, PERIOD_H4, _counter) < iClose(NULL, PERIOD_H4, _counter + 1)) bear += 240/1440;
        }
      }
      if ((method &   16) != 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (iOpen(NULL, PERIOD_H1, _counter) > iClose(NULL, PERIOD_H1, _counter + 1)) bull += 60/1440;
          else if (iOpen(NULL, PERIOD_H1, _counter) < iClose(NULL, PERIOD_H1, _counter + 1)) bear += 60/1440;
        }
      }
      if ((method &   32) != 0)  {
        for (_counter = 0; _counter < 48; _counter++) {
          if (iOpen(NULL, PERIOD_M30, _counter) > iClose(NULL, PERIOD_M30, _counter + 1)) bull += 30/1440;
          else if (iOpen(NULL, PERIOD_M30, _counter) < iClose(NULL, PERIOD_M30, _counter + 1)) bear += 30/1440;
        }
      }
      if ((method &   64) != 0)  {
        for (_counter = 0; _counter < 96; _counter++) {
          if (iOpen(NULL, PERIOD_M15, _counter) > iClose(NULL, PERIOD_M15, _counter + 1)) bull += 15/1440;
          else if (iOpen(NULL, PERIOD_M15, _counter) < iClose(NULL, PERIOD_M15, _counter + 1)) bear += 15/1440;
        }
      }
      if ((method &  128) != 0)  {
        for (_counter = 0; _counter < 288; _counter++) {
          if (iOpen(NULL, PERIOD_M5, _counter) > iClose(NULL, PERIOD_M5, _counter + 1)) bull += 5/1440;
          else if (iOpen(NULL, PERIOD_M5, _counter) < iClose(NULL, PERIOD_M5, _counter + 1)) bear += 5/1440;
        }
      }
    }
    _last_trend = (bull - bear);
    _last_trend_check = iTime(symbol, _tf, 0);
    #ifdef __trace__ PrintFormat("%s: %g", __FUNCTION__, _last_trend); #endif
    return _last_trend;
  }

  /**
   * Get the current market trend.
   *
   * @param
   *   method (int)
   *    Bitwise trend method to use.
   *   tf (ENUM_TIMEFRAMES)
   *     Frequency based on the given timeframe. Use NULL for the current.
   *   symbol (string)
   *     Symbol pair to check against it.
   *   simple (bool)
   *     If true, use simple trend calculation.
   *
   * @return
   *   Returns Buy operation for bullish, Sell for bearish, otherwise NULL for neutral market trend.
   */
  ENUM_ORDER_TYPE GetTrendOp(int method, ENUM_TIMEFRAMES _tf = NULL, bool simple = false) {
    double _curr_trend = GetTrend(method, _tf, simple);
    return _curr_trend == 0 ? (ENUM_ORDER_TYPE) (ORDER_TYPE_BUY + ORDER_TYPE_SELL) : (_curr_trend > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  }

};
