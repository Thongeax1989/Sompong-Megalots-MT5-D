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
   Print(__FUNCTION__"#", __LINE__, " DevDevDevDevDevDevDevDevDevDevDev ");

   Order_Select(Docker.Docker[0].TICKE_TOP_DW, Docker.Docker[0].Price_TOP_DW, retCode, __LINE__);

   Print(__FUNCTION__"#", __LINE__, " DevDevDevDevDevDevDevDevDevDevDev ");

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
int   retCode = -1;
//+------------------------------------------------------------------+
//|                                                                  |
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

//---
   retCode = -1;
//Order_Select(Docker.Docker[0].TICKE_TOP_DW, Docker.Docker[0].Price_TOP_DW, retCode, __LINE__);

   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Order_Select(int  Ticket_Check, double  Price_Check, int   &retDevCode, int   DevLine)
   {
   /* Mock Data*/
   int   __EA_Magic  =  0;
   Price_Check = SymbolInfoDouble(NULL,SYMBOL_BID);
   /* Mock Data*/
//---

   Price_Check =  NormalizeDouble(Price_Check, _Digits);
   if(Price_Check == -1)
      {
      Print(__FUNCTION__"#", __LINE__, " Price_Check : ", Price_Check," | Funtion --> return   true;");
      return   true;
      }


   bool   IsTicket_Found   =  false;
//---
      {
      int   __Port_CNT_Avtive  = PositionsTotal();

      for(int i = 0; i < __Port_CNT_Avtive; i++)
         {

         if(PositionGetSymbol(i) != _Symbol)    continue;

         ulong  _PositionGetTicket = PositionGetTicket(i);
         if(_PositionGetTicket != 0 &&
               PositionSelectByTicket(_PositionGetTicket))        //*Select fillter
            {

            //Print(__FUNCTION__"#", __LINE__, " _PositionGetTicket : ", _PositionGetTicket, " | PositionGetSymbol(i) : ", PositionGetSymbol(i));

            long   __POSITION_MAGIC  =  PositionGetInteger(POSITION_MAGIC);
            if(__POSITION_MAGIC == __EA_Magic)                    //*__EA_Magic fillter
               {
                  {
                  /*** Mian Funtion ***/

                  if(_PositionGetTicket == Ticket_Check)
                     {
                     IsTicket_Found = true;
                     }
                  /***Mian Funtion # End***/
                  }
               }

            }
         }
      }

      {
      if(IsTicket_Found == false)
         {

         int   __Port_CNT_Pending = OrdersTotal();
         for(int i = 0; i < __Port_CNT_Pending; i++)
            {

            ulong    _OrderGetTicket = OrderGetTicket(i);

            if(_OrderGetTicket != 0 &&
                  OrderSelect(_OrderGetTicket))
               {
               if(OrderGetString(ORDER_SYMBOL) != _Symbol)
                  {
                  continue;
                  }
               //Print(__FUNCTION__"#", __LINE__, " _OrderGetTicket : ", _OrderGetTicket);

               long   __ORDER_MAGIC  =  OrderGetInteger(ORDER_MAGIC);
               if(__ORDER_MAGIC == __EA_Magic)                          //*__EA_Magic fillter
                  {

                  long     __ORDER_TYPE      = OrderGetInteger(ORDER_TYPE);

                     {
                     /*** Mian Funtion ***/
                     double   __ORDER_PRICE_OPEN = OrderGetDouble(ORDER_PRICE_OPEN);
                     if(__ORDER_PRICE_OPEN != Price_Check)
                        {
                        if(OrderDelete(_OrderGetTicket))
                           {
                           IsTicket_Found = false;
                           }
                        }

                     /***Mian Funtion # End***/
                     }
                  }
               }
            }

         }
      }
//---
   return false;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderDelete(ulong  OrderDelete_Ticket)
   {
   /* Mock Data*/
   ulong   EXPERT_MAGIC  =  0;
   /* Mock Data*/
   
//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request = {};
   MqlTradeResult  result = {};
   int total = OrdersTotal(); // total number of placed pending orders
//--- iterate over all placed pending orders
   for(int i = total - 1; i >= 0; i--)
      {
      ulong  order_ticket = OrderGetTicket(i);                 // order ticket
      ulong  magic = OrderGetInteger(ORDER_MAGIC);             // MagicNumber of the order
      //--- if the MagicNumber matches
      if(magic == EXPERT_MAGIC)
         {
         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //--- setting the operation parameters
         request.action = TRADE_ACTION_REMOVE;                 // type of trade operation
         request.order = order_ticket;                         // order ticket
         //--- send the request
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
         //--- information about the operation
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         }
      }
   return true;
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
void OnTradeTransaction(const MqlTradeTransaction & trans,
                        const MqlTradeRequest & request,
                        const MqlTradeResult & result)
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
                  const long & lparam,
                  const double & dparam,
                  const string & sparam)
   {
//---

   }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string & symbol)
   {
//---

   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
