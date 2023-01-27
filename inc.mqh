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
      double         Sum_Active;
      double         Sum_Product;
      double         Sum_Lot;
   };
   SOrder            Buy, Sell, All;

                     CPort() {};
                    ~CPort() {};
};
CPort Port  =  new CPort;
//+------------------------------------------------------------------+
