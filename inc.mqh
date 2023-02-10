//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#define EA_Version   "1.00"

#define     EA_Identity          "MLot"    //OrderName
#define     EA_Identity_Short    "MLO"
//---
enum ENUM_ProfitTake {
   ENUM_ProfitTakeBuySell,    //+ Buy,Sell
   ENUM_ProfitTakeAll,        //+ Original(Holding.Nav)
   ENUM_ProfitTakeAllInc      //+ Profit + Lot Inc.Lot
};
enum ENUM_PlacePending {   //*v1.6+
   E_PlaceNormal,    //+ Normal
   E_PlaceHalfFrist  //+ HalfFrist
};
enum ENUM_OrderCommentPos {
   Pos_Name,
   Pos_MasterPrice,
   Pos_ModePlace,
   Pos_N1N2,
   Pos_Distance
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input   string               exEAname          = "v" + string(EA_Version);          //# Megalots
input   string               exOrder           = " --------------- Setting --------------- ";   // --------------------------------------------------
input   int                  exMagicnumber     =  10022023;         //• Magicnumber
input   string               exOrder_1         =  ""; //-
input   double               exZone_PriceStart =  0;                //• Price Start (0 = Current of Bid Price)
input   int                  exZone_Distance   =  50;               //• Distance
input   ENUM_PlacePending    exZone_PPlaceMODE =  E_PlaceHalfFrist; //• Pending Mode Place

input   string               exOrder1          = " --------------- Order : Group 1 --------------- ";   // --------------------------------------------------
input   int                  exZone_CNT        =  2;                //• N Order
input   double               exOrder_Lot_Sel   =  0.02;             //• Lot Sell
input   double               exOrder_Lot_Buy   =  0.02;             //• Lot Buy

input   string               exOrder2            = " --------------- Order : Group 2 --------------- ";   // --------------------------------------------------
input   int                  exZone_CNT_2        =  2;              //• N Order : Group 2
input   double               exOrder_Lot_Sel_2   =  0.01;           //• Lot Sell
input   double               exOrder_Lot_Buy_2   =  0.01;           //• Lot Buy

input   string               exProfit                   =  " --------------- Take Profit --------------- ";   // --------------------------------------------------
input   double               exProfit_TakeTraget        =  30;                  //• TP ($) : All
input   ENUM_ProfitTake      exProfit_MODE              =  ENUM_ProfitTakeAll;  //• Mode
input   double               exProfit_TakeTraget_SELL   =  30;                  //• TP ($) : Sell
input   double               exProfit_TakeTraget_BUY_   =  30;                  //• TP ($) : Buy

input   string               exStopLoss              =  " --------------- Stop Loss --------------- ";   // --------------------------------------------------
input   string               exStopLoss_EQ           =  ".";                 //--------------- Equity ---------------
input   bool                 exStopLoss_EQ_IO        =  false;                //• Equity | Using
input   double               exStopLoss_EQ_CutValue  =  0;          //• Equity | Lower cut value

input   string               exStopLoss_Distance        =  ".";              //--------------- Distance ---------------
input   bool                 exStopLoss_Distance_IO     =  true;             //• Distance | Using
input   int                  exStopLoss_Distance_Point  =  2000;             //• Distance | Point
double                        esStopLoss_Distance_Point  =  -1;

//input   string   exTime            = " --------------- Time Run/Pause --------------- ";   // --------------------------------------------------

input   string               exComm           = " --------------- Commission  --------------- ";   // --------------------------------------------------
input   double               exComm_Lot       = 9;   //• Commission/Lot [ Standard ]

input   string               exPlaysound          = " --------------- Playsound  --------------- ";   // --------------------------------------------------
input   bool                 exPlaysound_OnClose  = true;   //• OnClose

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sDev {
   int               LINE_Init;
};
sDev  Dev = {-1};
enum eState_Ontick {
   eStateTick_Normal,
   eStateTick_CloseAll
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPort
{
public:

   struct SOrder {
      int            CNT_Avtive;
      int            CNT_Pending;
      double         Sum_ActiveHold;
      double         Sum_Product;
      double         Sum_Lot;

      double               CommHarvest, Profit_Inc;
      //--- Constructor
      SOrder()
      {
         Clear();
      }
      //--- Destructor
      ~SOrder()
      {
         Print(__FUNCTION__"#", __LINE__);
      }
      void           Clear()
      {
         CNT_Avtive     = 0;
         CNT_Pending    = 0;
         Sum_ActiveHold = 0.0;
         Sum_Product    = 0.0;
         Sum_Lot        = 0.0;
      }
      void           Decimal()
      {
         //CNT_Avtive     = 0;
         //CNT_Pending    = 0;
         Sum_ActiveHold = NormalizeDouble(Sum_ActiveHold, 2);
         Sum_Product    = NormalizeDouble(Sum_Product, _Digits);
         Sum_Lot        = NormalizeDouble(Sum_Lot, 2);
      }
   };
   SOrder            Buy, Sell, All;


   struct SDocker {
      double               Price_Master;
      int                  Docker_DistancePoint;
      ENUM_PlacePending    Zone_PPlaceMODE;

      int                  Docker_total_1, Docker_total_2;
      //---
      double               ActivePlace_TOP,ActivePlace_BOT;
      double               ActivePoint_TOP,ActivePoint_BOT;

      SDocker()
      {
         Clear();
      }
      void           Clear()
      {
         ClearStatic();
         ClearDynamic();
      }
      void           ClearStatic()
      {
         Price_Master      = -1;

         Zone_PPlaceMODE   = -1;

         Docker_DistancePoint    = -1;
         Docker_total_1          = -1;
         Docker_total_2          = -1;
      }
      void           ClearDynamic()
      {



         ActivePlace_TOP = -1;
         ActivePlace_BOT = 9999999999;

         ActivePoint_TOP = 0;
         ActivePoint_BOT = 0;

      }
   };
   SDocker           docker;

   CPort()
   {
      Print(__FUNCTION__"#", __LINE__);

      Order_Callculator();
   };
   ~CPort()
   {
      Print(__FUNCTION__"#", __LINE__);
   };
   //------

   bool              Order_Callculator()
   {
      Buy.Clear();
      Sell.Clear();
      All.Clear();
      docker.ClearDynamic();
      //---

      int   __Port_CNT_Avtive  = PositionsTotal();
      if(true) { /* For Active loop*/

         //Print(__FUNCTION__"#", __LINE__);      // Dev Debug

         for(int i = 0; i < __Port_CNT_Avtive; i++) {

            if(PositionGetSymbol(i) != _Symbol) {
               continue;
            }

            ulong  _PositionGetTicket = PositionGetTicket(i);
            if(_PositionGetTicket != 0 &&
               PositionSelectByTicket(_PositionGetTicket)) {         //*Select fillter

               //Print(__FUNCTION__"#", __LINE__, " _PositionGetTicket : ", _PositionGetTicket);

               long   __POSITION_MAGIC  =  PositionGetInteger(POSITION_MAGIC);
               if(__POSITION_MAGIC == exMagicnumber) {                  //*__EA_Magic fillter

                  long     __POSITION_TYPE      = PositionGetInteger(POSITION_TYPE);
                  //Print(__FUNCTION__"#", __LINE__, " _PositionGetTicket : ", _PositionGetTicket, " | __POSITION_TYPE : ", __POSITION_TYPE);

                  double   __POSITION_PROFIT       = PositionGetDouble(POSITION_PROFIT);
                  double   __POSITION_VOLUME       = PositionGetDouble(POSITION_VOLUME);
                  double   __POSITION_PRICE_OPEN   = PositionGetDouble(POSITION_PRICE_OPEN);

                  if(__POSITION_TYPE == POSITION_TYPE_BUY) {

                     Buy.CNT_Avtive++;
                     Buy.Sum_ActiveHold += __POSITION_PROFIT;
                  }
                  if(__POSITION_TYPE == POSITION_TYPE_SELL) {

                     Sell.CNT_Avtive++;
                     Sell.Sum_ActiveHold += __POSITION_PROFIT;
                  }
                  All.CNT_Avtive    =  Buy.CNT_Avtive + Sell.CNT_Avtive;
                  All.Sum_Lot       += __POSITION_VOLUME;
                  All.Sum_ActiveHold =  Buy.Sum_ActiveHold + Sell.Sum_ActiveHold;
                  //---

                  double   SIZE  =  SymbolInfoDouble(NULL, SYMBOL_TRADE_CONTRACT_SIZE) / 100000;

                  All.CommHarvest =  exComm_Lot * All.Sum_Lot * SIZE;
                  All.Profit_Inc  =  All.Sum_ActiveHold + All.CommHarvest;
                  //---
                  {
                     docker.ActivePlace_TOP   =  MathMax(docker.ActivePlace_TOP,__POSITION_PRICE_OPEN);
                     docker.ActivePlace_BOT   =  MathMin(docker.ActivePlace_BOT,__POSITION_PRICE_OPEN);
                  }
                  //---

                  //Print(__FUNCTION__, "#", __LINE__, " docker.Price_Master: ", docker.Price_Master);
                  if(docker.Price_Master   ==  -1) {
                     Print(__FUNCTION__, "#", __LINE__);

                     getZoneStamp(PositionGetString(POSITION_COMMENT));
                  }
                  //---

               }
            }
         }
      } /*End : For Active loop + Module*/

      {/* v1.64 */
         //Global.Price_Master
         if(All.CNT_Avtive > 0) {

            double   Bid  =  SymbolInfoDouble(NULL,SYMBOL_BID);
            double   Ask  =  SymbolInfoDouble(NULL,SYMBOL_ASK);

            docker.ActivePoint_TOP = ( docker.ActivePlace_TOP - Ask) / _Point;
            docker.ActivePoint_BOT = (Bid -  docker.ActivePlace_BOT) / _Point;

            Draw_SumProduct(5,  docker.ActivePlace_TOP, clrYellow,"_ActivePlace_TOP");
            Draw_SumProduct(5,  docker.ActivePlace_BOT, clrYellow,"_ActivePlace_BOT");

         } else {
            Draw_SumProduct(5, 0, clrYellow,"_ActivePlace_TOP");
            Draw_SumProduct(5, 0, clrYellow,"_ActivePlace_BOT");
         }
      }

      //+------------------------------------------------------------------+

      int   __Port_CNT_Pending = OrdersTotal();
      if(true) { /* For Pending loop*/

         //Print(__FUNCTION__"#", __LINE__);      // Dev Debug

         for(int i = 0; i < __Port_CNT_Pending; i++) {

            ulong    _OrderGetTicket = OrderGetTicket(i);

            if(_OrderGetTicket != 0 &&
               OrderSelect(_OrderGetTicket)) {
               if(OrderGetString(ORDER_SYMBOL) != _Symbol) {
                  continue;
               }
               //Print(__FUNCTION__"#", __LINE__, " _OrderGetTicket : ", _OrderGetTicket);

               long   __ORDER_MAGIC  =  OrderGetInteger(ORDER_MAGIC);
               if(__ORDER_MAGIC == exMagicnumber) {                  //*__EA_Magic fillter

                  long     __ORDER_TYPE      = OrderGetInteger(ORDER_TYPE);
                  //Print(__FUNCTION__"#", __LINE__, " _OrderGetTicket : ", _OrderGetTicket, " | __ORDER_TYPE : ", __ORDER_TYPE);

                  All.CNT_Pending++;

                  switch(int(__ORDER_TYPE)) {
                  case  ORDER_TYPE_BUY_LIMIT: {
                     Buy.CNT_Pending++;
                     break;
                  }
                  case  ORDER_TYPE_BUY_STOP: {
                     Buy.CNT_Pending++;
                     break;
                  }
                  case  ORDER_TYPE_SELL_LIMIT: {
                     Sell.CNT_Pending++;
                     break;
                  }
                  case  ORDER_TYPE_SELL_STOP: {
                     Sell.CNT_Pending++;
                     break;
                  }
                  default: {
                     break;
                  }
                  }


               }


            }
         }
      } /*End : For Active loop + Module*/


      //Print(__FUNCTION__"#", __LINE__, " All.CNT_Avtive : ", All.CNT_Avtive);

      //---

      Buy.Decimal();
      Sell.Decimal();
      All.Decimal();

      //Print(__FUNCTION__"#", __LINE__);
      return            true;
   }

private:
   bool              getZoneStamp(string  OrderComment__)
   {
      Print(__FUNCTION__"#", __LINE__);

      string result[];
      int k = StringSplit(OrderComment__, StringGetCharacter("|", 0), result);

      Print(__FUNCTION__"#", __LINE__, " OrderComment__ : ", OrderComment__," | k:",k);
      if(k == 5) {

         docker.Price_Master      =  StringToDouble(result[Pos_MasterPrice]);
         Print(__FUNCTION__"#", __LINE__, " docker.Price_Master : ", docker.Price_Master);

         docker.Zone_PPlaceMODE   =  ENUM_PlacePending(result[Pos_ModePlace]);
         Print(__FUNCTION__"#", __LINE__, " docker.Zone_PPlaceMODE : ", docker.Zone_PPlaceMODE);

         {
            //Docker_total   = StrToInteger(result[2]);
            string arrDocker_total[];
            k = StringSplit(result[Pos_N1N2], StringGetCharacter(",", 0), arrDocker_total);
            if(k == 2) {
               docker.Docker_total_1 = int(arrDocker_total[0]);
               docker.Docker_total_2 = int(arrDocker_total[1]);
               Print(__FUNCTION__"#", __LINE__, " docker.Docker_total_1 : ", docker.Docker_total_1);
               Print(__FUNCTION__"#", __LINE__, " docker.Docker_total_2 : ", docker.Docker_total_2);

            }

         }

         docker.Docker_DistancePoint = int(StringToInteger(result[Pos_Distance]));
         Print(__FUNCTION__"#", __LINE__, " docker.Point_Distance : ", docker.Docker_DistancePoint);

         Print(__FUNCTION__"#", __LINE__);
         return   true;
      }
      Print(__FUNCTION__"#", __LINE__);
      return   false;
   }

   void              Draw_SumProduct(int OP, double Price, color Clr,string   name = "_SumProduct",bool  IsAdd_IdName = true)
   {
      string ObjTag = (IsAdd_IdName) ?
                      EA_Identity_Short + name + string(OP) :
                      name + string(OP);
      //if(!ObjectCreate(chart_ID, name, OBJ_HLINE, sub_window, 0, price)) {

      if(!ObjectCreate(0,ObjTag, OBJ_HLINE, 0, 0, Price)) {

      }
      if(ObjectMove(0, ObjTag, 0, 0, Price)) {
      }
      ObjectSetInteger(0, ObjTag, OBJPROP_BACK, false);
      ObjectSetInteger(0, ObjTag, OBJPROP_COLOR, Clr);

   }

};

CPort Port  =  new CPort;
//+------------------------------------------------------------------+
#include "inc_Docker.mqh"



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProductLock
{
   string            Account[];
   bool              EA_OrderRem;
public:
   bool              EA_Allow,EA_AllowAccount,EA_AllowDate;
   int               EA_Point,EA_AllowPoint;
   CProductLock(void) {};
   ~CProductLock(void) {};

   bool              Checker()
   {
      /* Bypass */
      double   Bypass   =  "Bypass";
      ProduckLock.EA_Allow = true;
      /* Bypass */

      return   true;
   }

   bool              Passport(bool  action = true)
   {
      if(EA_Point >= EA_AllowPoint) {

         {/* hotfix/CutloseByEQ [v1.644] */

//            if(IsOptimization() || IsTesting())
//               return   true;
//
//            if(action)
//               return   true;

         }

      } else {
         if(action) {
            if(Port.All.CNT_Pending > 0) {
               OrderDeleteAll(__LINE__);
            }
         }
      }
      return   false;
   }
   bool              PassportIsTemp()
   {
      return   true;
      //---

      if(EA_Point == EA_AllowPoint) {
         return   true;
      }
      return   false;
   }
};
//+------------------------------------------------------------------+
CProductLock   ProduckLock();
//+------------------------------------------------------------------+




struct sProgram {
   bool              Running;
   bool              ProduckLock;

   int               State_Ontick;

   sProgram()
   {
      Running        =  false;
      ProduckLock    =  false;

      State_Ontick   =  false;
   }

};
sProgram  Program;


























//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderClose(ulong  position_ticket)
{
   {
      if(!PositionSelectByTicket(position_ticket)) {
         return   false;
      }

      //---

      MqlTradeRequest request;
      MqlTradeResult  result;

      //--- zeroing the request and result values
      ZeroMemory(request);
      ZeroMemory(result);
      //--- setting the operation parameters
      request.action    = TRADE_ACTION_DEAL;       // type of trade operation
      request.position  = position_ticket;         // ticket of the position
      request.symbol    = PositionGetString(POSITION_SYMBOL);         // symbol
      request.volume    = PositionGetDouble(POSITION_VOLUME);       // volume of the position
      request.deviation = 5;                       // allowed deviation from the price
      request.magic     = 0;                       // MagicNumber of the position
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
      //--- set the price and order type depending on the position type

      if(type == POSITION_TYPE_BUY) {
         request.price = SymbolInfoDouble(request.symbol,SYMBOL_BID);
         request.type = ORDER_TYPE_SELL;
      }
      if(type == POSITION_TYPE_SELL) {
         request.price = SymbolInfoDouble(request.symbol,SYMBOL_ASK);
         request.type = ORDER_TYPE_BUY;
      }

      //--- output information about the closure
      PrintFormat("Close #%I64d %s %s",position_ticket,request.symbol,EnumToString(type));
      //--- send the request
      if(!OrderSend(request,result)) {
         Print(__FUNCTION__, "#", __LINE__, " OrderSend error ",GetLastError());                 // if unable to send the request, output the error code
         return   false;
      }
      //--- information about the operation
      Print(__FUNCTION__, "#", __LINE__, " retcode=",result.retcode,"  deal=",result.deal,"  order=",result.order);
      //---
   }
   return   true;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   Zone_getCNT(int   xZone_CNT, int  xZone_CNT_2, int   Zone_PPlaceMODE)
{
   Docker.Global.Docker_total_1 = xZone_CNT;
   Docker.Global.Docker_total_2 = xZone_CNT_2;

   if(Zone_PPlaceMODE == E_PlaceHalfFrist) {
      return   xZone_CNT + xZone_CNT_2 + 2;
   }
   return   xZone_CNT + xZone_CNT_2 + 1;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OrderDocker_Remember()
{
   int   __Port_CNT_Avtive  = PositionsTotal();
   for(int i = 0; i < __Port_CNT_Avtive; i++) {

      if(PositionGetSymbol(i) != _Symbol)
         continue;

      ulong  _PositionGetTicket = PositionGetTicket(i);
      if(_PositionGetTicket != 0 &&
         PositionSelectByTicket(_PositionGetTicket)) {

         long   __POSITION_MAGIC  =  PositionGetInteger(POSITION_MAGIC);
         if(__POSITION_MAGIC == exMagicnumber) {

            long     __POSITION_TYPE      = PositionGetInteger(POSITION_TYPE);
            double   __POSITION_PRICE_OPEN   = PositionGetDouble(POSITION_PRICE_OPEN);
            //---
            if(OrderDocker_RememberFindDock(_PositionGetTicket, __POSITION_PRICE_OPEN, __POSITION_TYPE)) {
               continue;
            }
            //---
         }
      }
   }
//---
   int   __Port_CNT_Pending = OrdersTotal();
   for(int i = 0; i < __Port_CNT_Pending; i++) {

      ulong    _OrderGetTicket = OrderGetTicket(i);
      if(_OrderGetTicket != 0 &&
         OrderSelect(_OrderGetTicket)) {

         if(OrderGetString(ORDER_SYMBOL) != _Symbol)
            continue;

         long   __ORDER_MAGIC  =  OrderGetInteger(ORDER_MAGIC);
         if(__ORDER_MAGIC == exMagicnumber) {

            long     __ORDER_TYPE         =  OrderGetInteger(ORDER_TYPE);;
            double   __ORDER_PRICE_OPEN   =  OrderGetDouble(ORDER_PRICE_OPEN);
            //---
            if(OrderDocker_RememberFindDock(_OrderGetTicket, __ORDER_PRICE_OPEN, __ORDER_TYPE)) {
               continue;
            }
            //---

         }

      }
//---
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderDocker_RememberFindDock(ulong OrderTicket_, double  OrderOpenPrice_, long  OrderType_)
{

   double   BOLD  =  Docker.Global.Price_Distance;

   for(int i = 0; i < Docker.Global.Docker_total; i++) {

      if(OrderOpenPrice_ > Docker.Global.Price_Master) {
         if(OrderType_ == POSITION_TYPE_BUY || OrderType_ == ORDER_TYPE_BUY_STOP) {
            if(Docker.Docker[i].Price_TOP_UP + BOLD >  OrderOpenPrice_ &&
               Docker.Docker[i].Price_TOP_UP - BOLD <= OrderOpenPrice_) {

               Docker.Docker[i].TICKE_TOP_UP  =  OrderTicket_;

               return   true;
            }
         }
         if(OrderType_ == POSITION_TYPE_SELL || OrderType_ == ORDER_TYPE_SELL_LIMIT) {
            if(Docker.Docker[i].Price_TOP_DW + BOLD >= OrderOpenPrice_ &&
               Docker.Docker[i].Price_TOP_DW - BOLD <  OrderOpenPrice_) {

               Docker.Docker[i].TICKE_TOP_DW  =  OrderTicket_;

               return   true;
            }
         }
      }
      if(OrderOpenPrice_ < Docker.Global.Price_Master) {
         if(OrderType_ == POSITION_TYPE_BUY || OrderType_ == ORDER_TYPE_BUY_LIMIT) {
            if(Docker.Docker[i].Price_BOT_UP + BOLD >  OrderOpenPrice_ &&
               Docker.Docker[i].Price_BOT_UP - BOLD <= OrderOpenPrice_) {

               Docker.Docker[i].TICKE_BOT_UP  =  OrderTicket_;

               return   true;
            }
         }
         if(OrderType_ == POSITION_TYPE_SELL || OrderType_ == ORDER_TYPE_SELL_STOP) {
            if(Docker.Docker[i].Price_BOT_DW + BOLD >= OrderOpenPrice_ &&
               Docker.Docker[i].Price_BOT_DW - BOLD <  OrderOpenPrice_) {

               Docker.Docker[i].TICKE_BOT_DW  =  OrderTicket_;

               return   true;
            }
         }
      }

   }

   return   false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderDelete(ulong  OrderDelete_Ticket)
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      return   false;
   }

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
bool  OrderDeleteAll(int  CommandByLine)
{
   if(CommandByLine != -1) {
      Print(__FUNCTION__, "#", __LINE__, " CommandByLine ",CommandByLine);
   }
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
         if(__ORDER_MAGIC == exMagicnumber) {

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
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderCloseAll(ENUM_POSITION_TYPE OP_DIR)
{
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
         if(__POSITION_MAGIC == exMagicnumber) {

            long   __POSITION_TYPE  =  PositionGetInteger(POSITION_TYPE);

            if((OP_DIR == -1) || (OP_DIR != -1 &&  __POSITION_TYPE == OP_DIR)) {

               ORDER_TICKET_CLOSE[i] = _PositionGetTicket;
               CountOfBox++;

            }
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
class CComment
{
public:
   CComment(void)
   {
      text_clear();
      Comment("");
   };
   ~CComment(void) {};

   void              add(string  name, double value, int digit)
   {
      TEXT += name + " : " + DoubleToString(value, digit) + "\n";
   }
   void              add(string  name, int value)
   {
      TEXT += name + " : " + string(value) + "\n";
   }
   void              add(string  name, string value)
   {
      TEXT += name + " : " + value + "\n";
   }
   void              add(string  name, bool value)
   {
      TEXT += name + " : " + string(value) + "\n";
   }
   void              add(string  name)
   {
      TEXT += name + "\n";
   }

   void              newline(string str = "")
   {
      TEXT += str + "\n";
   }
   void              Show()
   {
      if(AccountInfoInteger(ACCOUNT_LOGIN) == 66227421) {
         Comment(TEXT);
         text_clear();
      }
   }
private:
   string            TEXT;
   void              text_clear()
   {
      TEXT = "\n";
   }
};
CComment Comments = new CComment;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
