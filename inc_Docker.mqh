//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
enum ENUM_ProfitTake
   {
   ENUM_ProfitTakeBuySell,    //+ Buy,Sell [Update v1.7]
   ENUM_ProfitTakeAll,        //+ Original(Holding.Nav)
   ENUM_ProfitTakeAllInc      //+ Profit + Lot Inc.Lot
   };
enum ENUM_PlacePending     //*v1.6+
   {
   E_PlaceNormal,    //+ Normal
   E_PlaceHalfFrist  //+ HalfFrist
   };
enum ENUM_OrderCommentPos
   {
   Pos_Name,
   Pos_MasterPrice,
   Pos_ModePlace,
   Pos_N1N2,
   Pos_Distance
   };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input   string               exOrder           = " --------------- Setting --------------- ";   // --------------------------------------------------
input   int                  exMagicnumber     =  26102022;         //• Magicnumber
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDocker
   {
   public:

      //--- Start : Struct Define
      struct SDocker
         {
         double            Price_TOP_UP;     //OP_BUY
         double            Price_TOP_DW;     //OP_SELL
         ulong             TICKE_TOP_UP;     //OP_BUY
         ulong             TICKE_TOP_DW;     //OP_SELL

         double            Price_BOT_UP;     //OP_BUY
         double            Price_BOT_DW;     //OP_SELL
         ulong             TICKE_BOT_UP;     //OP_BUY
         ulong             TICKE_BOT_DW;     //OP_SELL

         double            Lot_Buy, Lot_Sell;
         };
      SDocker        Docker[];

      struct sGlobal
         {
         int               Docker_total;
         int               Docker_total_1;
         int               Docker_total_2;

         double            Price_Master;

         int               Point_Distance;
         double            Price_Distance;

         double            Price_Max;
         double            Price_Min;

         ENUM_PlacePending Zone_PPlaceMODE;
         sGlobal()
            {
            Docker_total   =  -1;
            Price_Master   =  -1;

            Point_Distance =  -1;
            Price_Distance =  -1;

            Price_Max   =  -1;
            Price_Min   =  -1;

            Zone_PPlaceMODE   =  -1;
            }
         };
      sGlobal        Global;
      //--- End : Struct Define


      CDocker(void)
         {
         Print(__FUNCTION__"#", __LINE__);

            {
            double   DEV_Price_Master_Carry = 0 * _Point;
            Global.Price_Master = (exZone_PriceStart == 0) ?
                                  SymbolInfoDouble(Symbol(),SYMBOL_BID) - DEV_Price_Master_Carry :
                                  exZone_PriceStart;

            Global.Docker_total   = Zone_getCNT(exZone_CNT, exZone_CNT_2, exZone_PPlaceMODE);

            Global.Point_Distance = exZone_Distance;
            Global.Price_Distance = exZone_Distance * _Point;
            //---

            Global.Docker_total   =  ArrayResize(Docker, Global.Docker_total);
            Print(__FUNCTION__, " Docker_total : ", Global.Docker_total);
            Print(__FUNCTION__, " Docker_total_1 : ", Global.Docker_total_1);
            Print(__FUNCTION__, " Docker_total_2 : ", Global.Docker_total_2);

               {
               ObjectsDeleteAll(0, 0, -1);

               //---Order_Close
               //__Order_Close(-1);

               //--- OrderDelete
               //Order_PendingDelete();      ***
               }

            Docker_Define();
            Docker_ObjDrawing();
            }

         };
      ~CDocker(void)
         {
         };

      int            Zone_getCNT(int   xZone_CNT, int  xZone_CNT_2, int   Zone_PPlaceMODE)
         {
         Global.Docker_total_1 = xZone_CNT;
         Global.Docker_total_2 = xZone_CNT_2;

         if(Zone_PPlaceMODE == E_PlaceHalfFrist)
            {
            return   xZone_CNT + xZone_CNT_2 + 2;
            }
         return   xZone_CNT + xZone_CNT_2 + 1;
         }

      void           Docker_Define()
         {
         if(exZone_PPlaceMODE == E_PlaceNormal)
            {
            double   Price_TOP_DW = Global.Price_Master + Global.Price_Distance;
            double   Price_TOP_UP = Price_TOP_DW + Global.Price_Distance;

            double   Price_BOT_UP = Global.Price_Master - Global.Price_Distance;
            double   Price_BOT_DW = Price_BOT_UP - Global.Price_Distance;

            //apply
            for(int i = 0; i < Global.Docker_total; i++)
               {
               Docker[i].Price_TOP_DW = Price_TOP_DW;
               Docker[i].Price_TOP_UP = Price_TOP_UP;

               Docker[i].Price_BOT_UP = Price_BOT_UP;
               Docker[i].Price_BOT_DW = Price_BOT_DW;

               Price_TOP_DW = NormalizeDouble(Price_TOP_UP + Global.Price_Distance,_Digits);;
               Price_TOP_UP = NormalizeDouble(Price_TOP_DW + Global.Price_Distance,_Digits);;

               Price_BOT_UP = NormalizeDouble(Price_BOT_DW - Global.Price_Distance,_Digits);;
               Price_BOT_DW = NormalizeDouble(Price_BOT_UP - Global.Price_Distance,_Digits);;

               if(i < Global.Docker_total_1)
                  {
                  Docker[i].Lot_Buy  = exOrder_Lot_Buy;
                  Docker[i].Lot_Sell = exOrder_Lot_Sel;
                  }
               else
                  {
                  Docker[i].Lot_Buy  = exOrder_Lot_Buy_2;
                  Docker[i].Lot_Sell = exOrder_Lot_Sel_2;
                  }

               }
            }

         //---

         if(exZone_PPlaceMODE == E_PlaceHalfFrist)
            {
            double   Price_TOP_DW = Global.Price_Master + Global.Price_Distance;    //Buy
            double   Price_TOP_UP = Global.Price_Master + Global.Price_Distance;    //Sell

            double   Price_BOT_UP = Global.Price_Master - Global.Price_Distance;    //Buy
            double   Price_BOT_DW = Global.Price_Master - Global.Price_Distance;    //Sell
            //---
            int i = 0;
            Docker[i].Price_TOP_DW = -1;              //Buy
            Docker[i].Price_TOP_UP = Price_TOP_UP;    //Sell

            Docker[i].Price_BOT_UP = -1;              //Buy
            Docker[i].Price_BOT_DW = Price_BOT_DW;    //Sell

            Docker[i].Lot_Buy  = exOrder_Lot_Buy;
            Docker[i].Lot_Sell = exOrder_Lot_Sel;
            //---

            //apply
            Price_TOP_DW = Price_TOP_UP + Global.Price_Distance;    //Buy
            Price_TOP_UP = Price_TOP_DW + Global.Price_Distance;           //Sell

            Price_BOT_UP = Price_BOT_DW - Global.Price_Distance;    //Buy
            Price_BOT_DW = Price_BOT_UP - Global.Price_Distance;           //Sell

            for(i = 1; i < Global.Docker_total; i++)
               {

               Docker[i].Price_TOP_DW = Price_TOP_DW;    //Buy
               Docker[i].Price_TOP_UP = Price_TOP_UP;    //Sell

               Docker[i].Price_BOT_UP = Price_BOT_UP;    //Buy
               Docker[i].Price_BOT_DW = Price_BOT_DW;    //Sell

               Price_TOP_DW = NormalizeDouble(Price_TOP_UP + Global.Price_Distance,_Digits);
               Price_TOP_UP = NormalizeDouble(Price_TOP_DW + Global.Price_Distance,_Digits);

               Price_BOT_UP = NormalizeDouble(Price_BOT_DW - Global.Price_Distance,_Digits);
               Price_BOT_DW = NormalizeDouble(Price_BOT_UP - Global.Price_Distance,_Digits);

               if(i < Global.Docker_total_1)
                  {
                  Docker[i].Lot_Buy  = exOrder_Lot_Buy;
                  Docker[i].Lot_Sell = exOrder_Lot_Sel;
                  }
               else
                  {
                  Docker[i].Lot_Buy  = exOrder_Lot_Buy_2;
                  Docker[i].Lot_Sell = exOrder_Lot_Sel_2;
                  }

               }
            }
         }

      //---

      void           Docker_ObjDrawing()
         {
         bool  ShowGuide  = true;
//---
         color  clrMaster = clrDeepPink, clrBuy =  clrRoyalBlue, clrSell =  clrTomato;
//---
         HLineCreate("Docker[0].Master", Global.Price_Master, clrMaster);

         bool  IsShowPrice =  true;
         IsShowPrice = !IsShowPrice;
//---
         for(int i = 0; i < Global.Docker_total; i++)
            {
            //--- Group Top
            if(i != Global.Docker_total - 1)
               {
               if(ShowGuide)
                  HLineCreate("Docker[" + string(i + 1) + "].Price_TOP_UP", Docker[i].Price_TOP_UP, clrBuy, IsShowPrice);
               }
            else
               {
               Global.Price_Max = Docker[i].Price_TOP_DW;
               HLineCreate("Docker.Price_Max", Global.Price_Max, clrSell, false);
               }
            //
            if(ShowGuide)
               HLineCreate("Docker[" + string(i + 1) + "].Price_TOP_DW", Docker[i].Price_TOP_DW, clrSell, IsShowPrice);


            //--- Group Bot
            if(ShowGuide)

               HLineCreate("Docker[" + string(i + 1) + "].Price_BOT_UP", Docker[i].Price_BOT_UP, clrBuy, IsShowPrice);
            //
            if(i != Global.Docker_total - 1)
               {
               if(ShowGuide)
                  HLineCreate("Docker[" + string(i + 1) + "].Price_BOT_DW", Docker[i].Price_BOT_DW, clrSell, IsShowPrice);
               }
            else
               {
               Global.Price_Min  =  Docker[i].Price_BOT_UP;
               HLineCreate("Docker.Price_Min", Global.Price_Min, clrBuy, false);
               }

            //---
            // OrderTagsCMM :: ZONE.POS.ROOM
            //         if(false) {
            ////            Docker[i].TICKE_TOP_DW = Order_Place(Docker[i].Price_TOP_DW,OP_SELL,"1.0." + string(i));
            ////            Docker[i].TICKE_TOP_UP = Order_Place(Docker[i].Price_TOP_UP,OP_BUY,"1.1." + string(i));
            ////
            ////            Docker[i].TICKE_BOT_UP = Order_Place(Docker[i].Price_BOT_UP,OP_BUY,"0.1." + string(i));
            ////            Docker[i].TICKE_BOT_DW = Order_Place(Docker[i].Price_BOT_DW,OP_SELL,"0.0." + string(i));
            //         }
            }
         }
   private:
      bool           HLineCreate(const string          name = "HLine",    // line name
                                 double                price = 0,         // line price
                                 const color           clr = clrRed,      // line color
                                 const bool            back = false,      // in the background

                                 const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                                 const int             width = 1,         // line width
                                 const bool            selection = false,  // highlight to move
                                 const bool            hidden = false,     // hidden in the object list
                                 const long            z_order = 0)       // priority for mouse click
         {
         if(price == -1)
            {
            return   false;
            }

         int             sub_window = 0;    // subwindow index
         long            chart_ID = 0;      // chart's ID

         if(!price)
            price = SymbolInfoDouble(Symbol(), SYMBOL_BID);

         ResetLastError();

         if(!ObjectCreate(chart_ID, name, OBJ_HLINE, sub_window, 0, price))
            {

            }
         if(ObjectMove(chart_ID, name, 0, 0, price))
            {
            ObjectSetString(chart_ID, name, OBJPROP_TEXT, DoubleToString(price, _Digits) + "|" + name);
            }
         ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
         ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
         ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
         ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
         ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
         ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
         ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
         ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
         return(true);
         }

   };
CDocker Docker  =  new CDocker;
//+------------------------------------------------------------------+
