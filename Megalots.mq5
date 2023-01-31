//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#include "inc.mqh"

#property copyright "Copyright 2023 Thongeak - Development."
#property link      "https://www.facebook.com/lapukdee/"
#property version    EA_Version

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   Print(__FUNCTION__"#", __LINE__, " ------------------------------------------------------------ ");

   Print(__FUNCTION__"#", __LINE__, " test : ", test);

   Print(__FUNCTION__"#", __LINE__, " ------------------------------------------------------------ ");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   Print(__FUNCTION__"#", __LINE__, " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Port.Order_Callculator();

//Print(__FUNCTION__"#", __LINE__, " All.Sum_ActiveHold : ", Port.All.Sum_ActiveHold);

   string   CMM = "";
   CMM += "Port.All.Sum_ActiveHold" + " : " + DoubleToString(Port.All.Sum_ActiveHold,2) + "\n";
   CMM += "Port.All.Sum_ActiveHold" + " : " + DoubleToString(Port.Buy.Sum_ActiveHold,2) + "\n";
   CMM += "Port.All.Sum_ActiveHold" + " : " + DoubleToString(Port.Sell.Sum_ActiveHold,2) + "\n";
   CMM += "\n";

   CMM += "Port.Buy.CNT_Pending" + " : " + IntegerToString(Port.Buy.CNT_Pending) + "\n";
   CMM += "Port.Sell.CNT_Pending" + " : " +  IntegerToString(Port.Sell.CNT_Pending) + "\n";
   CMM += "Port.All.CNT_Pending" + " : " +  IntegerToString(Port.All.CNT_Pending) + "\n";

   Comment(CMM);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret = 0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---

  }
//+------------------------------------------------------------------+
