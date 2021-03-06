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

/**
 * @file
 * Test functionality of Timeframe class.
 */

// Includes.
#include "Convert.mqh"
#include "Timeframe.mqh"

// Properties.
#property strict

// Define assert macros.
#define assert(cond, msg) \
  if (!(cond)) { \
    Alert(msg + " - Fail on " + #cond + " in " + __FILE__ + ":" + (string) __LINE__); \
    return (INIT_FAILED); \
  }

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test IndexToTf().
  PrintFormat("Index to timeframe: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d",
      M1,  Timeframe::IndexToTf(M1),
      M5,  Timeframe::IndexToTf(M5),
      M15, Timeframe::IndexToTf(M15),
      M30, Timeframe::IndexToTf(M30),
      H1,  Timeframe::IndexToTf(H1),
      H4,  Timeframe::IndexToTf(H4),
      D1,  Timeframe::IndexToTf(D1),
      W1,  Timeframe::IndexToTf(W1),
      MN1, Timeframe::IndexToTf(MN1)
      );
  assert(Timeframe::IndexToTf(0) == PERIOD_M1, "Invalid period for M1 index");
  assert(Timeframe::IndexToTf(1) == PERIOD_M5, "Invalid period for M5 index");

  // Test TfToIndex().
  PrintFormat("Timeframe to index: %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d, %d=>%d",
      PERIOD_M1,  Timeframe::TfToIndex(PERIOD_M1),
      PERIOD_M5,  Timeframe::TfToIndex(PERIOD_M5),
      PERIOD_M15, Timeframe::TfToIndex(PERIOD_M15),
      PERIOD_M30, Timeframe::TfToIndex(PERIOD_M30),
      PERIOD_H1,  Timeframe::TfToIndex(PERIOD_H1),
      PERIOD_H4,  Timeframe::TfToIndex(PERIOD_H4),
      PERIOD_D1,  Timeframe::TfToIndex(PERIOD_D1),
      PERIOD_W1,  Timeframe::TfToIndex(PERIOD_W1),
      PERIOD_MN1, Timeframe::TfToIndex(PERIOD_MN1)
      );
  assert(Timeframe::TfToIndex(PERIOD_M1) == 0, "Invalid index for M1 period");
  assert(Timeframe::TfToIndex(PERIOD_M5) == 1, "Invalid index for M5 period");

  return (INIT_SUCCEEDED);
}
