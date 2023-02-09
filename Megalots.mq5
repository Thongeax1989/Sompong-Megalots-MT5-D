//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#include "inc.mqh"

#property copyright "Copyright 2023 Thongeak - Development."
#property link      "https://www.facebook.com/lapukdee/"
#property version    EA_Version

/**
https://www.mql5.com/en/articles/81    MQL4  to MQL5
**/

#define     EA_Identity          "MLot"    //OrderName
#define     EA_Identity_Short    "MLO"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
bool  DEV_Clear   =  0;
int OnInit()
{
//--- create timer
   EventSetTimer(60);

   ChartSetInteger(0,CHART_SHOW_GRID,false);


   Print(__FUNCTION__"#", __LINE__);
   Print(__FUNCTION__"#", __LINE__, " ------------------------------------------------------------ ");

//Print(__FUNCTION__"#", __LINE__, " test : ", test);

   Print(__FUNCTION__"#", __LINE__, " ------------------------------------------------------------ ");
//---
   Print(__FUNCTION__"#", __LINE__, " DevDevDevDevDevDevDevDevDevDevDev ");
   
   Docker.Main();
   OrderDeleteAll();

   Print(__FUNCTION__"#", __LINE__, " DevDevDevDevDevDevDevDevDevDevDev ");
   {

      OrderCloseAll();
   }

   OnTick();
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

bool  DEV_OneTick =   true;
string   CMM_Dock_UP = "\n";
string   CMM_Dock_DW = "\n";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   Port.Order_Callculator();

//Print(__FUNCTION__"#", __LINE__, " All.Sum_ActiveHold : ", Port.All.Sum_ActiveHold);

   string   CMM = "";
   CMM += "AccountInfoInteger(ACCOUNT_TRADE_EXPERT)" + " : " + string(bool(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))) + "\n";

   CMM += "Port.All.Sum_ActiveHold" + " : " + DoubleToString(Port.All.Sum_ActiveHold,2) + "\n";
   CMM += "Port.All.Sum_ActiveHold" + " : " + DoubleToString(Port.Buy.Sum_ActiveHold,2) + "\n";
   CMM += "Port.All.Sum_ActiveHold" + " : " + DoubleToString(Port.Sell.Sum_ActiveHold,2) + "\n";
   CMM += "\n";

   CMM += "Port.Buy.CNT_Pending" + " : " + IntegerToString(Port.Buy.CNT_Pending) + "\n";
   CMM += "Port.Sell.CNT_Pending" + " : " +  IntegerToString(Port.Sell.CNT_Pending) + "\n";
   CMM += "Port.All.CNT_Pending" + " : " +  IntegerToString(Port.All.CNT_Pending) + "\n";

//---
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&
      DEV_OneTick && !DEV_Clear) {

      CMM_Dock_UP = "\n";
      CMM_Dock_DW = "\n";

      //if(!IsExpertEnabled()) {
      //   Program.Running   =  false;
      //}

      retCode = -1;
      for(int i = 0; i < Docker.Global.Docker_total; i++) {
         //---
         if(true) {
            CMM_Dock_UP += "D[" + string(i) + "].UP" + " : " +  string(Docker.Docker[i].TICKE_TOP_UP) + "@" +  DoubleToString(Docker.Docker[i].Price_TOP_UP,_Digits) +  "\n";
            CMM_Dock_UP += "D[" + string(i) + "].DW" + " : " +  string(Docker.Docker[i].TICKE_TOP_DW) + "@" +  DoubleToString(Docker.Docker[i].Price_TOP_DW,_Digits) +  "\n";

            CMM_Dock_DW += "D[" + string(i) + "].UP" + " : " +  string(Docker.Docker[i].TICKE_BOT_UP) + "@" +  DoubleToString(Docker.Docker[i].Price_BOT_UP,_Digits) +  "\n";
            CMM_Dock_DW += "D[" + string(i) + "].DW" + " : " +  string(Docker.Docker[i].TICKE_BOT_DW) + "@" +  DoubleToString(Docker.Docker[i].Price_BOT_DW,_Digits) +  "\n";

         } else {
            CMM_Dock_UP += "D[" + string(i) + "].Price_TOP_UP" + " : " +  DoubleToString(Docker.Docker[i].Price_TOP_UP,_Digits) + "\n";
            CMM_Dock_UP += "D[" + string(i) + "].Price_TOP_DW" + " : " +  DoubleToString(Docker.Docker[i].Price_TOP_DW,_Digits) + "\n";

            CMM_Dock_DW += "D[" + string(i) + "].Price_BOT_UP" + " : " +  DoubleToString(Docker.Docker[i].Price_BOT_UP,_Digits) + "\n";
            CMM_Dock_DW += "D[" + string(i) + "].Price_BOT_DW" + " : " +  DoubleToString(Docker.Docker[i].Price_BOT_DW,_Digits) + "\n";
         }
         //---

         if(Order_Select(Docker.Docker[i].TICKE_TOP_DW, Docker.Docker[i].Price_TOP_DW, retCode, __LINE__)) {

         } else {
            Docker.Docker[i].TICKE_TOP_DW = Order_Place(i, Docker.Docker[i].Price_TOP_DW, ORDER_TYPE_SELL); //, Global.Price_Master,Global.Docker_total,Global.Point_Distance);
         }
         //---
         if(i != Docker.Global.Docker_total - 1) {
            if(Order_Select(Docker.Docker[i].TICKE_TOP_UP, Docker.Docker[i].Price_TOP_UP, retCode, __LINE__)) {

            } else {
               Docker.Docker[i].TICKE_TOP_UP = Order_Place(i, Docker.Docker[i].Price_TOP_UP, ORDER_TYPE_BUY); //,Global.Price_Master,Global.Docker_total,Global.Point_Distance);
            }
         }
         //------ Mid
         if(Order_Select(Docker.Docker[i].TICKE_BOT_UP, Docker.Docker[i].Price_BOT_UP, retCode, __LINE__)) {

         } else {
            Docker.Docker[i].TICKE_BOT_UP = Order_Place(i, Docker.Docker[i].Price_BOT_UP, ORDER_TYPE_BUY); //, Global.Price_Master,Global.Docker_total,Global.Point_Distance);
         }
         //---
         if(i != Docker.Global.Docker_total - 1) {
            if(Order_Select(Docker.Docker[i].TICKE_BOT_DW, Docker.Docker[i].Price_BOT_DW, retCode, __LINE__)) {

            } else {
               Docker.Docker[i].TICKE_BOT_DW = Order_Place(i, Docker.Docker[i].Price_BOT_DW, ORDER_TYPE_SELL); //, Global.Price_Master,Global.Docker_total,Global.Point_Distance);
            }
         }
      }
      //DEV_OneTick  = false;
   }

   CMM += CMM_Dock_UP;
   CMM += "Mid \n";
   CMM += CMM_Dock_DW;

//---
   Comment(CMM);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Order_Select(ulong  Ticket_Check, double  Price_Check, int   &retDevCode, int   DevLine)
{
   /* Mock Data*/
   int   __EA_Magic  =  0;
//Price_Check = SymbolInfoDouble(NULL,SYMBOL_BID);
   /* Mock Data*/
//---

   Price_Check =  NormalizeDouble(Price_Check, _Digits);
   if(Price_Check == -1) {
      //Print(__FUNCTION__"#", __LINE__, " Price_Check : ", Price_Check," | Funtion --> return   true;");
      return   true;
   }


   bool   IsTicket_Found   =  false;
//---
   {
      int   __Port_CNT_Avtive  = PositionsTotal();

      for(int i = 0; i < __Port_CNT_Avtive; i++) {

         if(PositionGetSymbol(i) != _Symbol)    continue;

         ulong  _PositionGetTicket = PositionGetTicket(i);
         if(_PositionGetTicket != 0 &&
            PositionSelectByTicket(_PositionGetTicket)) {      //*Select fillter

            //Print(__FUNCTION__"#", __LINE__, " _PositionGetTicket : ", _PositionGetTicket, " | PositionGetSymbol(i) : ", PositionGetSymbol(i));

            long   __POSITION_MAGIC  =  PositionGetInteger(POSITION_MAGIC);
            if(__POSITION_MAGIC == __EA_Magic) {                  //*__EA_Magic fillter
               {
                  /*** Mian Funtion ***/

                  if(_PositionGetTicket == Ticket_Check) {
                     IsTicket_Found = true;
                     return   true;
                  }
                  /***Mian Funtion # End***/
               }
            }

         }
      }
   }

   {
      if(IsTicket_Found == false) {

         int   __Port_CNT_Pending = OrdersTotal();
         for(int i = 0; i < __Port_CNT_Pending; i++) {

            ulong    _OrderGetTicket = OrderGetTicket(i);

            if(_OrderGetTicket != 0 &&
               _OrderGetTicket == Ticket_Check &&
               OrderSelect(_OrderGetTicket)) {
               if(OrderGetString(ORDER_SYMBOL) != _Symbol) {
                  continue;
               }
               //Print(__FUNCTION__"#", __LINE__, " _OrderGetTicket : ", _OrderGetTicket);

               long   __ORDER_MAGIC  =  OrderGetInteger(ORDER_MAGIC);
               if(__ORDER_MAGIC == __EA_Magic
                 ) {                        //*__EA_Magic fillter

                  //long     __ORDER_TYPE      = OrderGetInteger(ORDER_TYPE);

                  {
                     /*** Mian Funtion ***/
                     double   __ORDER_PRICE_OPEN = OrderGetDouble(ORDER_PRICE_OPEN);
                     if(__ORDER_PRICE_OPEN != Price_Check) {
                        if(OrderDelete(_OrderGetTicket)) {
                           Print(__FUNCTION__"#", __LINE__, " OrderDelete(",_OrderGetTicket,") : ", __ORDER_PRICE_OPEN, " != ", Price_Check," | get != Check");

                           IsTicket_Found = false;
                        }
                     } else {
                        IsTicket_Found = true;
                     }

                     /***Mian Funtion # End***/
                  }
               }
            }
         }

      }
   }
//---
   return IsTicket_Found;
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

//--- zeroing the request and result values
   ZeroMemory(request);
   ZeroMemory(result);
//--- setting the operation parameters
   request.action = TRADE_ACTION_REMOVE;                 // type of trade operation
   request.order = OrderDelete_Ticket;                         // order ticket
//--- send the request
   if(!OrderSend(request,result)) {
      Print(__FUNCTION__, "#", __LINE__, " OrderSend error ",GetLastError());    // if unable to send the request, output the error code
      return false;
   }
//--- information about the operation
   Print(__FUNCTION__, "#", __LINE__, " TRADE_ACTION_REMOVE@ retcode=",result.retcode,"  deal=",result.deal,"  order=",result.order);
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderCloseAll()
{
   /* Mock Data*/
   ulong   EXPERT_MAGIC  =  0;
   /* Mock Data# */

   /* Funtion */
   int   CountOfBox = 0;
   /* Funtion# */

   int   __Port_CNT_Avtive  = PositionsTotal();

   ulong   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE, __Port_CNT_Avtive);
   ArrayInitialize(ORDER_TICKET_CLOSE, 0);

   for(int i = 0; i < __Port_CNT_Avtive; i++) {

      ulong    _PositionGetTicket = PositionGetTicket(i);

      if(_PositionGetTicket != 0 &&
         PositionSelectByTicket(_PositionGetTicket)) {

         if(PositionGetSymbol(i) != _Symbol) {
            continue;
         }

         //Print(__FUNCTION__"#", __LINE__, " _OrderGetTicket : ", _OrderGetTicket);

         long   __POSITION_MAGIC  =  PositionGetInteger(POSITION_MAGIC);
         if(__POSITION_MAGIC == EXPERT_MAGIC) {

            ORDER_TICKET_CLOSE[i] = _PositionGetTicket;
            CountOfBox++;
         }

      }
   }
//---
   bool  doIsDeleteAll  =  false;

   Print(__FUNCTION__"#", __LINE__, " doIsDeleteAll : ", doIsDeleteAll, " | CountOfBox : ", CountOfBox);

   do {
      for(int i = 0; i < __Port_CNT_Avtive; i++) {

         ulong _OrderTicket = ORDER_TICKET_CLOSE[i];

         if(_OrderTicket != 0) {
            if(OrderClose(_OrderTicket)) {

               ORDER_TICKET_CLOSE[i] = 0;

            }
         }
      }

      for(int i = 0; i < __Port_CNT_Avtive; i++) {
         ulong _OrderTicket = ORDER_TICKET_CLOSE[i];

         if(_OrderTicket == 0) {
            doIsDeleteAll = false;
         } else {
            doIsDeleteAll = true;
            break;
         }
      }
   } while(doIsDeleteAll);

   Print(__FUNCTION__"#", __LINE__, " doIsDeleteAll : ", doIsDeleteAll, " | CountOfBox : ", CountOfBox);
//---
   return   true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderDeleteAll()
{
   /* Mock Data*/
   ulong   EXPERT_MAGIC  =  0;
   /* Mock Data# */

   /* Funtion */
   int   CountOfBox = 0;
   /* Funtion# */

   int   __Port_CNT_Pending = OrdersTotal();

   ulong   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE, __Port_CNT_Pending);
   ArrayInitialize(ORDER_TICKET_CLOSE, 0);

   for(int i = 0; i < __Port_CNT_Pending; i++) {

      ulong    _OrderGetTicket = OrderGetTicket(i);

      if(_OrderGetTicket != 0 &&
         OrderSelect(_OrderGetTicket)) {

         if(OrderGetString(ORDER_SYMBOL) != _Symbol) {
            continue;
         }

         //Print(__FUNCTION__"#", __LINE__, " _OrderGetTicket : ", _OrderGetTicket);

         long   __ORDER_MAGIC  =  OrderGetInteger(ORDER_MAGIC);
         if(__ORDER_MAGIC == EXPERT_MAGIC) {

            ORDER_TICKET_CLOSE[i] = _OrderGetTicket;
            CountOfBox++;
         }

      }
   }
//---

   bool  doIsDeleteAll  =  false;
   do {
      for(int i = 0; i < __Port_CNT_Pending; i++) {

         ulong _OrderTicket = ORDER_TICKET_CLOSE[i];

         if(_OrderTicket != 0) {
            if(OrderDelete(_OrderTicket)) {

               ORDER_TICKET_CLOSE[i] = 0;

            }
         }
      }
      for(int i = 0; i < __Port_CNT_Pending; i++) {
         ulong _OrderTicket = ORDER_TICKET_CLOSE[i];

         if(_OrderTicket == 0) {
            doIsDeleteAll = false;
         } else {
            doIsDeleteAll = true;
            break;
         }
      }
   } while(doIsDeleteAll);

   Print(__FUNCTION__"#", __LINE__, " doIsDeleteAll : ", doIsDeleteAll, " | CountOfBox : ", CountOfBox);
//---
   return   true;
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
//Print(__FUNCTION__"#", __LINE__);

}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction & trans,
                        const MqlTradeRequest & request,
                        const MqlTradeResult & result)
{
//---
//Print(__FUNCTION__"#", __LINE__);

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

   double  master =  Docker.Global.Price_Master;
   int zone_n1  =    Docker.Global.Docker_total_1;
   int zone_n2  =    Docker.Global.Docker_total_2;
//---
   int zone_ditance  =  int(Docker.Global.Point_Distance);
//---
//--- ZoneStamper
   /* Name|MasterPrice|ModePlace|N1,N2|Distance */
   string   OrderTagsCMM   =  EA_Identity + "|" +
                              DoubleToString(master, _Digits) + "|" +
                              string(exZone_PPlaceMODE) + "|" +
                              string(zone_n1) + "," + string(zone_n2) + "|" +
                              string(zone_ditance);
//---
//--- checking the type of operation
   double   lot   =  -1;
   double __BID = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   if(OP_DIR == ORDER_TYPE_BUY) {

      lot = Docker.Docker[DockRoom].Lot_Buy;

      if(price > __BID) {
         OP_DIR = ORDER_TYPE_BUY_STOP;
      } else {
         OP_DIR = ORDER_TYPE_BUY_LIMIT;
      }
   }
   if(OP_DIR == ORDER_TYPE_SELL) {

      lot = Docker.Docker[DockRoom].Lot_Sell;

      if(price > __BID) {
         OP_DIR = ORDER_TYPE_SELL_LIMIT;
      } else {
         OP_DIR = ORDER_TYPE_SELL_STOP;
      }
   }
//---
   MqlTradeRequest request = {};
   MqlTradeResult  result = {};
//---
   request.magic    = EXPERT_MAGIC;                                    // MagicNumber of the order

   request.action   = TRADE_ACTION_PENDING;                            // type of trade operation
   request.type     = OP_DIR;                                           // order type
   request.symbol   = Symbol();                                        // symbol

   request.price    = NormalizeDouble(price,_Digits);                 // normalized opening price
   request.volume   = lot;
   request.deviation = 0;                                              // allowed deviation from the price

   request.comment   =  OrderTagsCMM;

//--- send the request
   if(!OrderSend(request,result))
      Print(__FUNCTION__, "#", __LINE__, " OrderSend error ",GetLastError());                 // if unable to send the request, output the error code
//--- information about the operation
   Print(__FUNCTION__, "#", __LINE__, " retcode=",result.retcode,"  deal=",result.deal,"  order=",result.order);

//---
   return   result.order;
}
//+------------------------------------------------------------------+
