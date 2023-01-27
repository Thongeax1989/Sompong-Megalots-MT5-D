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
      Order_Callculator();

      Print(__FUNCTION__"#", __LINE__, " Buy.CNT_Avtive : ", Buy.CNT_Avtive);
   };
                    ~CPort()
   {
      Print(__FUNCTION__"#", __LINE__);
   };
   //------

   bool              Order_Callculator()
   {
      All.Clear();
      //---

      /* Mock Data*/
      int   __EA_Magic  =  123;
      //---

      All.Sum_ActiveHold = AccountInfoDouble(ACCOUNT_PROFIT);

      int   __Port_CNT_Avtive  = PositionsTotal();
      {/* For Active loop*/
         for(int i = 0; i < __Port_CNT_Avtive; i++) {

            if(PositionGetSymbol(i) != _Symbol)    continue;

            ulong  _PositionGetTicket = PositionGetTicket(i);
            if(_PositionGetTicket != 0) {
            Print(__FUNCTION__"#", __LINE__, " _PositionGetTicket : ", _PositionGetTicket);

            }

         }
      }



      int   __Port_CNT_Pending = OrdersTotal();
      {/* For Pending loop*/}

      //Print(__FUNCTION__"#", __LINE__, " All.CNT_Avtive : ", All.CNT_Avtive);

      //---
      All.Decimal();
      return   true;
   }
};
CPort Port  =  new CPort;
//+------------------------------------------------------------------+
