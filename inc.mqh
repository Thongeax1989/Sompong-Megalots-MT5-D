//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#define EA_Version   "1.00"
int   test  =  1668;

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
      //---


      /* Mock Data*/
      int   __EA_Magic  =  0;
      //---


      int   __Port_CNT_Avtive  = PositionsTotal();
      {/* For Active loop*/
         for(int i = 0; i < __Port_CNT_Avtive; i++) {

            if(PositionGetSymbol(i) != _Symbol)    continue;

            ulong  _PositionGetTicket = PositionGetTicket(i);
            if(_PositionGetTicket != 0 &&
               PositionSelectByTicket(_PositionGetTicket)) {

               Print(__FUNCTION__"#", __LINE__, " _PositionGetTicket : ", _PositionGetTicket);

               long   __POSITION_MAGIC  =  PositionGetInteger(POSITION_MAGIC);
               if(__POSITION_MAGIC == __EA_Magic) {

                  long     __POSITION_TYPE      = PositionGetInteger(POSITION_TYPE);

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

                  //
                  All.Sum_ActiveHold = __POSITION_PROFIT;

               }
            }
         }
      }/*End : For Active loop*/

      int   __Port_CNT_Pending = OrdersTotal();
      {/* For Pending loop*/}






      //Print(__FUNCTION__"#", __LINE__, " All.CNT_Avtive : ", All.CNT_Avtive);

      //---
      Buy.Decimal();
      Sell.Decimal();
      All.Decimal();
      return   true;
   }
};
CPort Port  =  new CPort;
//+------------------------------------------------------------------+
