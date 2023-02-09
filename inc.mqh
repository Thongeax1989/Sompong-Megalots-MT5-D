//+------------------------------------------------------------------+
//|                                                     Megalots.mq5 |
//|                           Copyright 2023 Thongeak - Development. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#define EA_Version   "1.00"
//int   test  =  1668;

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
               if(__POSITION_MAGIC == __EA_Magic) {                  //*__EA_Magic fillter

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

                  //
                  All.Sum_ActiveHold = __POSITION_PROFIT;

               }
            }
         }
      } /*End : For Active loop + Module*/



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
               if(__ORDER_MAGIC == __EA_Magic) {                  //*__EA_Magic fillter

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
      return            true;
   }

};

CPort Port  =  new CPort;
//+------------------------------------------------------------------+
#include "inc_Docker.mqh"
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
         PrintFormat(__LINE__ + "OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
         return   false;
      }
      //--- information about the operation
      PrintFormat(__LINE__ + "retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      //---
   }
   return   true;
}
//+------------------------------------------------------------------+
