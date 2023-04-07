//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+

#define     eaLOCK_Account ""
/*
   #Example.
   "45843128,80000007"     => allow 2 acc.
   ""                      => Account not locked

*/
#define     eaLOCK_Date    ""
/*
   - Compared to the center time +0
   #Example.
   "31.12.2023"   => Day,Month,Year
   ""             => Unlimited

*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define EA_Version   "1.71mt5D1.00"   //Megalots
//---
#property copyright "Copyright 2023 Thongeak - Development."
#property link      "https://www.facebook.com/lapukdee/"
#property version    EA_Version;

#property   description    "Account Allow : "+eaLOCK_Account
#property   description    "Expire Date : "+eaLOCK_Date

/**
https://www.mql5.com/en/articles/81    MQL4  to MQL5
**/

#define     EA_Identity          "MLot"    //OrderName
#define     EA_Identity_Short    "MLO"

#include "inc.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//bool  DEV_Clear   =  0;
//---

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
//--- create timer
   EventSetTimer(60);

   Print(" ----------------------------------------------------------------------------------------- ");
   Print(" ----------------------------------------------------------------------------------------- ");

   {
      ChartSetInteger(0, CHART_SHOW_GRID, false);
      //---

      Program.Running   =  false;
      Print(__FUNCTION__, "#", __LINE__, " Check Init Start | Program.Running : ", Program.Running);
      //---

      int   reason   =  UninitializeReason() ;
      Print(__FUNCTION__, "#", __LINE__, " UninitializeReason()  : ", UninitializeReason(reason));

      {
         esStopLoss_Distance_Point = NormalizeDouble(exStopLoss_Distance_Point * -1, _Digits);
      }

      Port.Order_Callculator();
      Print(__FUNCTION__, "-->Port.Order_Callculator()", "#", __LINE__, " Port.All.CNT_Avtive : ", Port.All.CNT_Avtive);

      {
         ProduckLock.Checker();
         //Program.ProduckLock =  ProduckLock.EA_Allow;
      }
      if(reason == REASON_CHARTCHANGE/*3*/) {
         //return(INIT_SUCCEEDED);

         Print(__FUNCTION__, "#", __LINE__, " Port.Price_Master : ", Port.docker.Price_Master);
         Program.Running = ProduckLock.Passport(false);

      } else {
         Print(__FUNCTION__, "#", __LINE__, " Port.Price_Master : ", Port.docker.Price_Master);

         Program.Running = false;
         Print(__FUNCTION__, "#", __LINE__, " Port.All.CNT_Avtive : ", Port.All.CNT_Avtive);

         if(Port.All.CNT_Avtive > 0) {
            Print(__FUNCTION__, "#", __LINE__);

            Docker.Global.Price_Master =  Port.docker.Price_Master;

            if(UninitializeReason() == REASON_PARAMETERS) {

               Dev.LINE_Init = __LINE__;
               Print(__FUNCTION__, "#", __LINE__, " UninitializeReason()  : ", UninitializeReason(reason));

               Docker.Global.Zone_PPlaceMODE  =  Port.docker.Zone_PPlaceMODE;

               Docker.Global.Docker_total   = Zone_getCNT(exZone_CNT, exZone_CNT_2, Docker.Global.Zone_PPlaceMODE);

               Docker.Global.Point_Distance = exZone_Distance;
               Docker.Global.Price_Distance = exZone_Distance * _Point;

            } else {

               Dev.LINE_Init = __LINE__;
               Print(__FUNCTION__, "#", __LINE__);
               Print(__FUNCTION__, "#", __LINE__, " UninitializeReason()  : ", UninitializeReason(reason));

               Docker.Global.Zone_PPlaceMODE  =  Port.docker.Zone_PPlaceMODE;

               Print(__FUNCTION__, "#", __LINE__, " Port.docker.Price_Master : ", Port.docker.Price_Master);

               Print(__FUNCTION__, "#", __LINE__, " Port.docker.Docker_total_1 : ", Port.docker.Docker_total_1);
               Print(__FUNCTION__, "#", __LINE__, " Port.docker.Docker_total_2: ", Port.docker.Docker_total_2);

               Print(__FUNCTION__, "#", __LINE__, " Port.docker.Zone_PPlaceMODE : ", Port.docker.Zone_PPlaceMODE);
               Print(__FUNCTION__, "#", __LINE__, " Port.docker.Docker_DistancePoint : ", Port.docker.Docker_DistancePoint);

               Docker.Global.Docker_total =   Zone_getCNT(Port.docker.Docker_total_1, Port.docker.Docker_total_2, Docker.Global.Zone_PPlaceMODE);

               Docker.Global.Docker_total_1 = Port.docker.Docker_total_1;
               Docker.Global.Docker_total_2 = Port.docker.Docker_total_2;

               Docker.Global.Point_Distance = Port.docker.Docker_DistancePoint;
               Docker.Global.Price_Distance = Docker.Global.Point_Distance * _Point;

            }

            //--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            {
               Docker.Global.Docker_total   =  ArrayResize(Docker.Docker, Docker.Global.Docker_total);
               Print(__FUNCTION__, "#", __LINE__, " Docker_total : ", Docker.Global.Docker_total);
               Print(__FUNCTION__, "#", __LINE__, " Docker_total_1 : ", Docker.Global.Docker_total_1);
               Print(__FUNCTION__, "#", __LINE__, " Docker_total_2 : ", Docker.Global.Docker_total_2);

               {
                  ObjectsDeleteAll(0, 0, -1);

                  //---Order_Close
                  //__Order_Close(-1);

                  //--- OrderDelete
                  OrderDeleteAll(__LINE__);
               }

               Docker.Docker_Define();
               Docker.Docker_ObjDrawing();

               {
                  Print(__FUNCTION__, "#", __LINE__);
                  Port.docker.Clear();
                  OrderDocker_Remember();
               }
            }

         } else { /*--- None Active Case ---*/

            Dev.LINE_Init = __LINE__;
            Print(__FUNCTION__, "#", __LINE__);
            Print(__FUNCTION__, "#", __LINE__, " UninitializeReason()  : ", UninitializeReason(reason));

            int   Reason   =  UninitializeReason();
            Print("Reason : ", Reason);

            if(Reason == REASON_PARAMETERS ||
               Reason == 0) {

               if(exZone_PriceStart >= 0) {

                  Dev.LINE_Init = __LINE__;

                  double   DEV_Price_Master_Carry = 0 * _Point;
                  Docker.Global.Price_Master = (exZone_PriceStart == 0) ?
                                               SymbolInfoDouble(_Symbol, SYMBOL_BID) - DEV_Price_Master_Carry :
                                               exZone_PriceStart;

                  Docker.Global.Docker_total   = Zone_getCNT(exZone_CNT, exZone_CNT_2, exZone_PPlaceMODE);

                  Docker.Global.Point_Distance = exZone_Distance;
                  Docker.Global.Price_Distance = exZone_Distance * _Point;
                  //---

                  Docker.Global.Docker_total   =  ArrayResize(Docker.Docker, Docker.Global.Docker_total);
                  Print(__FUNCTION__, " Docker_total : ", Docker.Global.Docker_total);
                  Print(__FUNCTION__, " Docker_total_1 : ", Docker.Global.Docker_total_1);
                  Print(__FUNCTION__, " Docker_total_2 : ", Docker.Global.Docker_total_2);

                  {
                     ObjectsDeleteAll(0, 0, -1);

                     //---Order_Close
                     //__Order_Close(-1);

                     //--- OrderDelete
                     OrderDeleteAll(__LINE__);
                  }

                  Docker.Docker_Define();
                  Docker.Docker_ObjDrawing();

               } else { /*--- Master Prive are negative ---*/

                  Dev.LINE_Init = __LINE__;
                  Print(__FUNCTION__, "#", __LINE__);

                  //--- Stop

                  {
                     ObjectsDeleteAll(0, 0, -1);

                     //---Order_Close
                     //__Order_Close(-1);

                     //--- OrderDelete
                     OrderDeleteAll(__LINE__);
                  }

               }
            }

         }
         //---
         {
            Print(__FUNCTION__, "#", __LINE__);

            ObjectsDeleteAll(0, EA_Identity_Short, 0, OBJ_HLINE);
            ObjectsDeleteAll(0, EA_Identity_Short, 0, OBJ_LABEL);
            ObjectsDeleteAll(0, EA_Identity_Short, 0, OBJ_EDIT);
            ObjectsDeleteAll(0, EA_Identity_Short, 0, OBJ_BUTTON);
            ObjectsDeleteAll(0, EA_Identity_Short, 0, OBJ_RECTANGLE_LABEL);

            Port.Order_Callculator();
            GUI();

         }
         {
            Print(__FUNCTION__, "#", __LINE__);
            Program.Running = ProduckLock.Passport(false);
            //Program.Running   = true;
         }
      }
   }
   {
      Print(__FUNCTION__, "#", __LINE__, " Dev.LINE_Init : ", Dev.LINE_Init);
   }
   {
      Print(__FUNCTION__, "#", __LINE__);

      Comments.add("#Version", EA_Version);

      Comments.add("Dev.LINE_Init", Dev.LINE_Init, 0);
      Comments.newline();

      Comments.add("Docker_total", Docker.Global.Docker_total, 0);
      Comments.add("Docker.Global.Price_Master", Docker.Global.Price_Master, _Digits);

      Comments.add("cnt_All", Port.All.CNT_Avtive);
      //Comments.newline();

      //Comments.add("sumHold_Buy",Port.sumHold_Buy,2);
      //Comments.add("sumHold_Sel",Port.sumHold_Sel,2);

      Comments.add("Port.ActivePlace_TOP", Port.docker.ActivePlace_TOP, _Digits);
      Comments.add("Port.ActivePlace_BOT", Port.docker.ActivePlace_BOT, _Digits);

      Comments.Show();
   }

   Print(__FUNCTION__, "#", __LINE__, " Check Init End | Program.Running : ", Program.Running);
   Print(" ----------------------------------------------------------------------------------------- ");
   Print(" ----------------------------------------------------------------------------------------- ");

   Print(__FUNCTION__, "#", __LINE__, " OnTick() in init...");
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

string   CMM_Dock_UP = "\n";
string   CMM_Dock_DW = "\n";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Program.Running   =  false;
      Print(__LINE__, "#", __FUNCTION__, " Program.Running : ", Program.Running);
   } else {
      //Print(__FUNCSIG__,"#",__LINE__,"__Module Frisrt * Else | !IsExpertEnabled() = ",!IsExpertEnabled()," | Program.Running = ",Program.Running);
   }
   {
      Port.Order_Callculator();
      //Print(__FUNCTION__, "#", __LINE__);

      if(Port.All.CNT_Avtive == 0 &&
         Program.State_Ontick == eStateTick_CloseAll) {

         Program.State_Ontick   = eStateTick_Normal;
      }

      if(Program.Running && ProduckLock.PassportIsTemp() &&
         (Port.All.CNT_Avtive == 0 || Port.All.CNT_Pending == 0)) {

         ProduckLock.Checker();

         Program.Running   =  ProduckLock.Passport(false);
         Print(__LINE__, "#", __FUNCTION__, " Program.Running : ", Program.Running);

         if(ProduckLock.EA_Allow == false) {
            OrderDeleteAll(__LINE__);
         }
      }

      GUI();
      //Print(__FUNCTION__, "#", __LINE__);
   }
//---
   bool  OnClose  = false;
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && Program.Running &&
      Port.All.CNT_Avtive > 0) {
      bool  IsCloseAll  =  false;

      if(exProfit_MODE == ENUM_ProfitTakeTypeD) {

         if(
            (Port.All.Sum_ActiveHold >= 0 ) &&
            (Port.Buy.CNT_Avtive) >= 2 &&
            (Port.Buy.Sum_Lot == Port.Sell.Sum_Lot)) {
            Print("");
            Print(__FUNCTION__, __LINE__, " exProfit_MODE : ", exProfit_MODE);

            {
               OrderCloseAll(-1);
               OnClose     = true;

               IsCloseAll  = true;
            }
         }

         if(Port.All.Sum_ActiveHold >= exProfit_TakeTraget) {

            Print("");
            Print(__FUNCTION__, __LINE__, " exProfit_MODE : ", exProfit_MODE);
            Print(__FUNCTION__, __LINE__, " Order_Close(-1) | ", Port.All.Sum_ActiveHold, ">=", exProfit_TakeTraget);

            OrderCloseAll(-1);
            OnClose     = true;

            IsCloseAll  = true;
         }
      }

      if(exProfit_MODE == ENUM_ProfitTakeAll) {
         if(Port.All.Sum_ActiveHold >= exProfit_TakeTraget) {

            Print("");
            Print(__FUNCTION__, __LINE__, " exProfit_MODE : ", exProfit_MODE);
            Print(__FUNCTION__, __LINE__, " Order_Close(-1) | ", Port.All.Sum_ActiveHold, ">=", exProfit_TakeTraget);

            OrderCloseAll(-1);
            OnClose     = true;

            IsCloseAll  = true;
         }
      }
      if(exProfit_MODE == ENUM_ProfitTakeAllInc) {
         if(Port.All.Profit_Inc >= exProfit_TakeTraget) {
            Print("");
            Print(__FUNCTION__, __LINE__, " exProfit_MODE : ", exProfit_MODE);
            Print(__FUNCTION__, __LINE__, " Order_Close(-1) | ", Port.All.Profit_Inc, ">=", exProfit_TakeTraget);

            OrderCloseAll(-1);
            OnClose     = true;

            IsCloseAll  = true;
         }
      }

      if(exProfit_MODE == ENUM_ProfitTakeBuySell) {      /*** v1.70+ ***/

         if(Port.Buy.Sum_ActiveHold >= exProfit_TakeTraget_BUY_) {
            Print("");
            Print(__FUNCTION__, __LINE__, " exProfit_MODE : ", exProfit_MODE);
            Print(__FUNCTION__, __LINE__, " Order_Close(POSITION_TYPE_BUY) | ", Port.Buy.Sum_ActiveHold, ">=", exProfit_TakeTraget_BUY_);
            OrderCloseAll(POSITION_TYPE_BUY);
            OnClose  = true;
         }
         if(Port.Sell.Sum_ActiveHold >= exProfit_TakeTraget_SELL) {
            Print("");
            Print(__FUNCTION__, __LINE__, " exProfit_MODE : ", exProfit_MODE);
            Print(__FUNCTION__, __LINE__, " Order_Close(POSITION_TYPE_SELL) | ", Port.Sell.Sum_ActiveHold, ">=", exProfit_TakeTraget_SELL);
            OrderCloseAll(POSITION_TYPE_SELL);
            OnClose  = true;
         }

      }

      {
         /*** v1.64+ ***/ /*** StopLoss ***/
         if(Port.All.CNT_Avtive > 0 && Port.All.Sum_ActiveHold < 0) {
            //---
            if(exStopLoss_EQ_IO) {
               double   Act_EQ = AccountInfoDouble(ACCOUNT_EQUITY);

               if(Act_EQ <= exStopLoss_EQ_CutValue) {

                  //PlaySound("alert");
                  Print(__LINE__, "#", __FUNCTION__, " Stoploss-Equity | ", Act_EQ, " : ", exStopLoss_EQ_CutValue);
                  OrderCloseAll(-1);
                  OrderDeleteAll(__LINE__);     //My Order

                  Program.Running   =  false;
                  Print(__LINE__, "#", __FUNCTION__, " Program.Running : ", Program.Running);

                  OnClose           = true;

               }

            }
            //---
            if(exStopLoss_Distance_IO) {

               if(exStopLoss_Distance_Point > 0) {

                  if(Port.docker.ActivePoint_TOP <= esStopLoss_Distance_Point ||
                     Port.docker.ActivePoint_BOT <= esStopLoss_Distance_Point) {

                     Print(__LINE__, "#", __FUNCTION__, " Stoploss-Point | ", esStopLoss_Distance_Point, "P ", "[", DoubleToString(Port.docker.ActivePoint_TOP, 0), "TopPoint,", DoubleToString(Port.docker.ActivePoint_BOT, 0), "TopPoint]");
                     OrderCloseAll(-1);
                     OrderDeleteAll(__LINE__);     //My Order

                     Program.Running   =  false;
                     Print(__LINE__, "#", __FUNCTION__, " Program.Running : ", Program.Running);

                     OnClose           = true;

                  }
               }

            }
            //---
         }
      }

      if(OnClose) {

         if(exPlaysound_OnClose) {
            PlaySound("alert");
         }

         Port.Order_Callculator();
         ProduckLock.Checker();
         GUI();

         if(IsCloseAll) {
            if(Port.All.CNT_Avtive > 0) {
               Program.State_Ontick   = eStateTick_CloseAll;   //Hold Close all
            }
         }

      }
   }
//---


//+------------------------------------------------------------------+//+------------------------------------------------------------------+
//+------------------------------------------------------------------+//+------------------------------------------------------------------+

   if(ProduckLock.Passport() &&
      !OnClose &&                                     // Not while CloseAll Process
      Program.State_Ontick   == eStateTick_Normal) {   // Checkup CloseAll Process is done
      //Print(__FUNCTION__, "#", __LINE__);

      //Print(__LINE__,"#",__FUNCTION__," Program.Running : ",Program.Running);
      if(Program.Running) {

         {/*** Type D :: PriceStart_Auto ***/
            if(exZone_PriceStart_Auto) {
               //Print(__FUNCTION__, __LINE__, " OnClose : ", OnClose, " | exZone_PriceStart_Auto : ", exZone_PriceStart_Auto);

               if(Port.All.CNT_Avtive == 0) {
                  Print(__FUNCTION__, __LINE__, " Port.All.CNT_Avtive : ", Port.All.CNT_Avtive);

                  DockerDefine();

               }
            }

         }

         CMM_Dock_UP = "\n";
         CMM_Dock_DW = "\n";

         //if(!IsExpertEnabled()) {
         //   Program.Running   =  false;
         //}

         int retCode = -1;
         for(int i = 0; i < Docker.Global.Docker_total; i++) {
            //---
            if(false) {
               CMM_Dock_UP += "D[" + string(i) + "].UP" + " : " +  string(Docker.Docker[i].TICKE_TOP_UP) + "@" +  DoubleToString(Docker.Docker[i].Price_TOP_UP, _Digits) +  "\n";
               CMM_Dock_UP += "D[" + string(i) + "].DW" + " : " +  string(Docker.Docker[i].TICKE_TOP_DW) + "@" +  DoubleToString(Docker.Docker[i].Price_TOP_DW, _Digits) +  "\n";

               CMM_Dock_DW += "D[" + string(i) + "].UP" + " : " +  string(Docker.Docker[i].TICKE_BOT_UP) + "@" +  DoubleToString(Docker.Docker[i].Price_BOT_UP, _Digits) +  "\n";
               CMM_Dock_DW += "D[" + string(i) + "].DW" + " : " +  string(Docker.Docker[i].TICKE_BOT_DW) + "@" +  DoubleToString(Docker.Docker[i].Price_BOT_DW, _Digits) +  "\n";

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
   }
//CMM += CMM_Dock_UP;
//CMM += "Mid \n";
//CMM += CMM_Dock_DW;

//---
//Comment(CMM);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Order_Select(ulong  Ticket_Check, double  Price_Check, int   &retDevCode, int   DevLine)
{
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
            if(__POSITION_MAGIC == exMagicnumber) {                  //*__EA_Magic fillter
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
               if(__ORDER_MAGIC == exMagicnumber
                 ) {                        //*__EA_Magic fillter

                  //long     __ORDER_TYPE      = OrderGetInteger(ORDER_TYPE);

                  {
                     /*** Mian Funtion ***/
                     double   __ORDER_PRICE_OPEN = OrderGetDouble(ORDER_PRICE_OPEN);
                     if(__ORDER_PRICE_OPEN != Price_Check) {
                        if(OrderDelete(_OrderGetTicket)) {
                           Print(__FUNCTION__"#", __LINE__, " OrderDelete(", _OrderGetTicket, ") : ", __ORDER_PRICE_OPEN, " != ", Price_Check, " | get != Check");

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
//OnTick();
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
//--- Check the event by pressing a mouse button
   if(id == CHARTEVENT_OBJECT_CLICK) {

      ChartRedraw();

      string result[];
      if(ObjectGetInteger(0, sparam, OBJPROP_TYPE) == OBJ_BUTTON)
         if(StringSplit(sparam, StringGetCharacter("|", 0), result) == 3) {
            if(result[0] == EA_Identity_ShortGUI) {
               Print(__FUNCTION__, " sparam* : ", sparam);

               if(result[1] == "PAUSE") {
                  if(!Program.Running && !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
                     int  MessageBox_ = MessageBox("Expert Disable !! : Running can't Setting", EA_Identity + " :: Program Status", MB_ICONWARNING | MB_OK);
                  } else {

                     string   str =  "Do you want to [[ Running ]] the program (Full auto Pendding and TakeProfit)";
                     if(Program.Running)
                        str = "Do you want to [[ PAUSE ]] the program (stop Place Pending)";

                     int  MessageBox_ = MessageBox(str, EA_Identity + " :: Program Status", MB_ICONWARNING | MB_YESNO | MB_DEFBUTTON2);
                     Print(__FUNCTION__, " MessageBox_* (IDYES=6): ", MessageBox_);

                     if(MessageBox_ == IDYES) {
                        Program.Running =  !Program.Running;
                     }
                     Print(__FUNCTION__, "#", __LINE__, " Program.Running : ", Program.Running);

                  }
               }

               if(result[1] == "Close") {
                  if(Port.All.CNT_Avtive > 0) {
                     ENUM_POSITION_TYPE   Type  =  ENUM_POSITION_TYPE(result[2]);
                     string   Type_str =  "All";
                     if(Type == POSITION_TYPE_BUY)
                        Type_str = "BUY";
                     if(Type == POSITION_TYPE_SELL)
                        Type_str = "SELL";

                     int  MessageBox_ = MessageBox("Do you want to Close Order [[ " + Type_str + " ]]", EA_Identity + " :: Order Close", MB_ICONWARNING | MB_YESNO | MB_DEFBUTTON2);
                     Print(__FUNCTION__, " MessageBox_* : ", MessageBox_);

                     if(MessageBox_ == IDYES) {
                        Program.Running = false;
                        Print(__FUNCTION__, "#", __LINE__, " Program.Running : ", Program.Running);

                        OrderCloseAll(Type);
                     }
                  } else {
                     ChartRedraw();
                  }
               }

               if(result[1] == "Clear") {

                  int   Type  =  int(result[2]);
                  string   Type_str =  "[[  All in Port  ]]";
                  if(Type == 1)
                     Type_str = "[[  In The " + EA_Identity + "  ]]";

                  int  MessageBox_ = MessageBox("Do you want to Claer Pending... \n" + Type_str, EA_Identity + " :: Pending Clear", MB_ICONWARNING | MB_YESNO | MB_DEFBUTTON2);
                  Print(__FUNCTION__, " MessageBox_* : ", MessageBox_);

                  if(MessageBox_ == IDYES) {

                     Program.Running = false;
                     Print(__FUNCTION__, "#", __LINE__, " Program.Running : ", Program.Running);

                     if(Type == 1) {
                        Print(__LINE__);
                        OrderDeleteAll(__LINE__);     //My Order
                     }
                     if(Type == 2) {
                        Print(__LINE__);
                        OrderDeleteAll(__LINE__);     //My Order
                        //Print(__LINE__);
                        //Order_PendingDelete(-2);   //Etc all imp
                     }
                  }
               }
            }
         }
   }

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
   double __BID = SymbolInfoDouble(_Symbol, SYMBOL_BID);

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
   request.magic    = exMagicnumber;                                    // MagicNumber of the order

   request.action   = TRADE_ACTION_PENDING;                            // type of trade operation
   request.type     = OP_DIR;                                           // order type
   request.symbol   = Symbol();                                        // symbol

   request.price    = NormalizeDouble(price, _Digits);                // normalized opening price
   request.volume   = lot;
   request.deviation = 0;                                              // allowed deviation from the price

   request.comment   =  OrderTagsCMM;

//--- send the request
   if(!OrderSend(request, result))
      Print(__FUNCTION__, "#", __LINE__, " OrderSend error ", GetLastError());                // if unable to send the request, output the error code
//--- information about the operation
   Print(__FUNCTION__, "#", __LINE__, " retcode=", result.retcode, "  deal=", result.deal, "  order=", result.order);

//---
   return   result.order;
}
//+------------------------------------------------------------------+
string   UninitializeReason(int  reason)
{
   switch(reason) {
   case  REASON_PROGRAM :
      return   "	0	-	REASON_PROGRAM	-	Expert Advisor terminated its operation by calling the ExpertRemove() function	";
   case  REASON_REMOVE :
      return   "	1	-	REASON_REMOVE	-	Program has been deleted from the chart	";
   case  REASON_RECOMPILE :
      return   "	2	-	REASON_RECOMPILE	-	Program has been recompiled	";
   case  REASON_CHARTCHANGE :
      return   "	3	-	REASON_CHARTCHANGE	-	Symbol or chart period has been changed	";
   case  REASON_CHARTCLOSE :
      return   "	4	-	REASON_CHARTCLOSE	-	Chart has been closed	";
   case  REASON_PARAMETERS :
      return   "	5	-	REASON_PARAMETERS	-	Input parameters have been changed by a user	";
   case  REASON_ACCOUNT :
      return   "	6	-	REASON_ACCOUNT	-	Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings	";
   case  REASON_TEMPLATE :
      return   "	7	-	REASON_TEMPLATE	-	A new template has been applied	";
   case  REASON_INITFAILED :
      return   "	8	-	REASON_INITFAILED	-	This value means that OnInit() handler has returned a nonzero value	";
   case  REASON_CLOSE :
      return   "	9	-	REASON_CLOSE	-	Terminal has been closed	";
   default:
      break;
   }
   return   "-";
}
//+------------------------------------------------------------------+
