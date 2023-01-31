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
         int               TICKE_TOP_UP;     //OP_BUY
         int               TICKE_TOP_DW;     //OP_SELL

         double            Price_BOT_UP;     //OP_BUY
         double            Price_BOT_DW;     //OP_SELL
         int               TICKE_BOT_UP;     //OP_BUY
         int               TICKE_BOT_DW;     //OP_SELL

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


      CDocker(void);
      ~CDocker(void);

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

               Price_TOP_DW = Price_TOP_UP + Global.Price_Distance;
               Price_TOP_UP = Price_TOP_DW + Global.Price_Distance;

               Price_BOT_UP = Price_BOT_DW - Global.Price_Distance;
               Price_BOT_DW = Price_BOT_UP - Global.Price_Distance;

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

               Price_TOP_DW = Price_TOP_UP + Global.Price_Distance;
               Price_TOP_UP = Price_TOP_DW + Global.Price_Distance;

               Price_BOT_UP = Price_BOT_DW - Global.Price_Distance;
               Price_BOT_DW = Price_BOT_UP - Global.Price_Distance;

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

   };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
