//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  DockerDefine()
{
   Print(__FUNCTION__);
   
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
      //ObjectsDeleteAll(0, 0, -1);

      //---Order_Close
      //__Order_Close(-1);

      //--- OrderDelete
      OrderDeleteAll(__LINE__);
   }

   Docker.Docker_Define();
   Docker.Docker_ObjDrawing();
}
//+------------------------------------------------------------------+
