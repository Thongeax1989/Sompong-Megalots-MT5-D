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

//Order_Select(Docker.Docker[0].TICKE_TOP_DW, Docker.Docker[0].Price_TOP_DW, retCode, __LINE__);

   Order_Place(0, 0, ORDER_TYPE_BUY);

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
   if(true)
      {

      //if(!IsExpertEnabled()) {
      //   Program.Running   =  false;
      //}

      retCode = -1;
      for(int i = 0; i < Docker.Global.Docker_total; i++)
         {

         if(Order_Select(Docker.Docker[i].TICKE_TOP_DW, Docker.Docker[i].Price_TOP_DW, retCode, __LINE__))
            {

            }
         else
            {

            Docker.Docker[i].TICKE_TOP_DW = Order_Place(i, Docker.Docker[i].Price_TOP_DW, ORDER_TYPE_SELL); //, Global.Price_Master,Global.Docker_total,Global.Point_Distance);
            }
         //---
         if(i != Docker.Global.Docker_total - 1)
            {
            if(Order_Select(Docker.Docker[i].TICKE_TOP_UP, Docker.Docker[i].Price_TOP_UP, retCode, __LINE__))
               {

               }
            else
               {
               Docker.Docker[i].TICKE_TOP_UP = Order_Place(i, Docker.Docker[i].Price_TOP_UP, ORDER_TYPE_BUY); //,Global.Price_Master,Global.Docker_total,Global.Point_Distance);
               }
            }
         //---
         if(Order_Select(Docker.Docker[i].TICKE_BOT_UP, Docker.Docker[i].Price_BOT_UP, retCode, __LINE__))
            {

            }
         else
            {
            Docker.Docker[i].TICKE_BOT_UP = Order_Place(i, Docker.Docker[i].Price_BOT_UP, ORDER_TYPE_BUY); //, Global.Price_Master,Global.Docker_total,Global.Point_Distance);
            }
         //---
         if(i != Docker.Global.Docker_total - 1)
            {
            if(Order_Select(Docker.Docker[i].TICKE_BOT_DW, Docker.Docker[i].Price_BOT_DW, retCode, __LINE__))
               {

               }
            else
               {
               Docker.Docker[i].TICKE_BOT_DW = Order_Place(i, Docker.Docker[i].Price_BOT_DW, ORDER_TYPE_SELL); //, Global.Price_Master,Global.Docker_total,Global.Point_Distance);
               }
            }
         }
      }

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
//+------------------------------------------------------------------+//+------------------------------------------------------------------+
//+------------------------------------------------------------------+//+------------------------------------------------------------------+
ulong Order_Place(int DockRoom, double   price, ENUM_ORDER_TYPE OP_DIR = -1)
   {
   /* Mock Data*/
   ulong   EXPERT_MAGIC  =  0;
   /* Mock Data*/
//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request = {};
   MqlTradeResult  result = {};
//--- parameters to place a pending order
   request.action   = TRADE_ACTION_PENDING;                            // type of trade operation

   request.symbol   = Symbol();                                        // symbol
//request.volume   = 0.1;                                             // volume of 0.1 lot

   request.deviation = 2;                                              // allowed deviation from the price
   request.magic    = EXPERT_MAGIC;                                    // MagicNumber of the order
   int offset = 50;                                                    // offset from the current price to place the order, in points

   double point = SymbolInfoDouble(_Symbol,SYMBOL_POINT);              // value of point
   int digits = int(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));              // number of decimal places (precision)

//---
   double   lot   =  -1;
   double __BID = SymbolInfoDouble(_Symbol,SYMBOL_BID);

//--- Mock Data
   //price = __BID + (300 * _Point);
//---

   if(OP_DIR == ORDER_TYPE_BUY)
      {

      lot = Docker.Docker[DockRoom].Lot_Buy;

      if(price > __BID)
         {
         OP_DIR = ORDER_TYPE_BUY_STOP;
         }
      else
         {
         OP_DIR = ORDER_TYPE_BUY_LIMIT;
         }
      }
   if(OP_DIR == ORDER_TYPE_SELL)
      {

      lot = Docker.Docker[DockRoom].Lot_Sell;

      if(price > __BID)
         {
         OP_DIR = ORDER_TYPE_SELL_LIMIT;
         }
      else
         {
         OP_DIR = ORDER_TYPE_SELL_STOP;
         }
      }
   request.volume   = lot;                                             // volume of 0.1 lot

//--- checking the type of operation

//---

   request.type     = OP_DIR;                                        // order type
   request.price    = NormalizeDouble(price,digits);                 // normalized opening price

//--- send the request
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());                 // if unable to send the request, output the error code
//--- information about the operation
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);

//---
   return   result.deal;
   }
//+------------------------------------------------------------------+
