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

      All.Sum_ActiveHold += AccountInfoDouble(ACCOUNT_PROFIT);

      All.CNT_Avtive  = PositionsTotal();

      All.CNT_Pending = OrdersTotal();

      //Print(__FUNCTION__"#", __LINE__, " All.CNT_Avtive : ", All.CNT_Avtive);

      //---
      return   true;
   }
};
CPort Port  =  new CPort;
//+------------------------------------------------------------------+
