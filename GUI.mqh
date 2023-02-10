//+------------------------------------------------------------------+
//|                                                     Megalots.mq4 |
//|                                        Copyright 2020, ThongEak. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#include "Megalots.mq5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define     EA_Identity_ShortGUI    "MLO_GUI"

struct sGUI {
   int               column_1, column_s, column_2, column_3;

   int               Row_Start, Row_Step, Row_Save;
   int               Row_StepGroup;

   int               Panel_MaginTop, Panel_MaginRL;

   bool              Panel_Running;
};
sGUI  GUI = {255, 150, 135, 35,
             30, 15, 0,
             9,
             10, 15,
             false
            };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  GUI()
{
   Create_RectLabel("BG1");
   Create_RectLabel("BG2");
   Create_RectLabel("BG3");

   GUI.Row_Save = GUI.Row_Start;
//---
   int   cAcc  =  (ProduckLock.EA_AllowAccount) ? 0 : -1;
   GUI_DrawPair("AccNumber", "Account Number", "", string(AccountInfoInteger(ACCOUNT_LOGIN)), "", false, true, cAcc);


//GUI_DrawPair("CONTRACT_SIZE","CONTRACT_SIZE",_CommaZero(CONTRACT_SIZE,8));

   if(eaLOCK_Date != "") {
      int   cDate  =  (ProduckLock.EA_AllowDate) ? 0 : -1;
      GUI_DrawPair("Exprie", "Exprie", "", eaLOCK_Date, "", false, true, cDate);
   }

   Create_RectLabel("BG2", false,
                    GUI.column_1 + GUI.Panel_MaginRL, GUI.Row_Start - GUI.Panel_MaginTop,
                    GUI.column_1, GUI.Row_Save - GUI.Row_Step);

   GUI_DrawStepGroup();

//GUI_DrawPair("Port.cnt_Buy","Buy Order",string(Port.cnt_Buy),"");
   GUI_DrawPair("Port.sumHold_Buy", "Buy Profit", string(Port.Buy.CNT_Avtive), _CommaZero(Port.Buy.Sum_ActiveHold, 2), "$", false, true, Port.Buy.Sum_ActiveHold, "Buy|Count|Profit");
//GUI_DrawStepGroup();

//GUI_DrawPair("Port.cnt_Sel","Sell Order",string(Port.cnt_Sel));
   GUI_DrawPair("Port.sumHold_Sel", "Sell Profit", string(Port.Sell.CNT_Avtive), _CommaZero(Port.Sell.Sum_ActiveHold, 2), "$", false, true, Port.Sell.Sum_ActiveHold, "Sell|Count|Profit");
   GUI_DrawStepGroup();

   GUI_DrawPair("Port.sumHold_All", "Profit/Loss", string(Port.All.CNT_Avtive), _CommaZero(Port.All.Sum_ActiveHold, 2), "$", true, true, Port.All.Sum_ActiveHold, "ALL|Count|Profit");
   GUI_DrawStepGroup();

   int   Row_BG3 = GUI.Row_Save - 5;

   GUI_DrawPair("Port.sumLot_Buy", "Lot Size Buy", "", _CommaZero(Port.Buy.Sum_Lot, 2), "");
   GUI_DrawPair("Port.sumLot_Sel", "Lot Size Sell", "", _CommaZero(Port.Sell.Sum_Lot, 2), "");
   double   DirectionLot =  Port.Buy.Sum_Lot - Port.Sell.Sum_Lot;
//GUI_DrawPair("DirectionLot","Lot Direction","",_CommaZero(DirectionLot,2),"",false,true,DirectionLot);
   GUI_DrawStepGroup();

   GUI_DrawPair("Port.sumLot_All", "Lot Total", "", _CommaZero(Port.All.Sum_Lot, 2), "", false, false, 0,
                "Lot Total | Direction: " + _CommaZero(DirectionLot, 2));

   int   Digit_Comm = _DigitsByValue(Port.All.CommHarvest, 2);

   GUI_DrawPair("exComm_Lot", "Comm. / Lot Std", "", _CommaZero(exComm_Lot, Digit_Comm), "$");
   GUI_DrawPair("Commission-Harvest", "Comm. - Harvest", "", _CommaZero(Port.All.CommHarvest, Digit_Comm), "$");

   GUI_DrawPair("Profit/Lot Inc.Lot", "Profit Inc.Lot", "", _CommaZero(Port.All.Profit_Inc, Digit_Comm), "$", true, true, Port.All.Profit_Inc,
                "Inc.Lot | [Comm/Harvest] : " + _CommaZero(exComm_Lot, Digit_Comm) + "/" + _CommaZero(Port.All.CommHarvest, Digit_Comm));
   GUI_DrawStepGroup(GUI.Row_Step);

   double   Balance  =  AccountInfoDouble(ACCOUNT_BALANCE);
   double   Drawdown =  (Port.All.Sum_ActiveHold / Balance) * 100;
   GUI_DrawPair("Spread", "Spread", "", IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)), "P");
   GUI_DrawPair("Drawdown", "Drawdown", "", _CommaZero(Drawdown, _DigitsByValue(Drawdown)), "%", false, true, Drawdown);
   GUI_DrawPair("Balance", "Balance", "", _CommaZero(Balance, 2), "$");
   GUI_DrawPair("Equity", "Equity", "", _CommaZero(AccountInfoDouble(ACCOUNT_EQUITY), 2), "$");
   GUI_DrawStepGroup(GUI.Row_Step);

   Create_RectLabel("BG3", false,
                    GUI.column_1 + GUI.Panel_MaginRL, Row_BG3,
                    GUI.column_1, GUI.Row_Save - Row_BG3 - 5);

   double   Zone_Length =  (Docker.Global.Price_Max - Docker.Global.Price_Min) / _Point;
   GUI_DrawPair("ZONE.Length", "Length [" + string(exZone_CNT) + "," + string(exZone_CNT_2) + "]", "", _CommaZero(Zone_Length, 0), "P");
   GUI_DrawPair("ZONE.Max", "Max", "", DoubleToString(Docker.Global.Price_Max, _Digits));
   GUI_DrawPair("ZONE.Min", "Min", "", DoubleToString(Docker.Global.Price_Min, _Digits));
   GUI_DrawStepGroup();

//---
//---

   int   BTN_High =   24;
   int   BTN_wide =  GUI.column_1 - (GUI.Panel_MaginTop + GUI.Panel_MaginRL) ;

   string  TextRunning = "PAUSE";
   color   clrRunning = clrLightSteelBlue;
   if(Program.Running) {

      GUI.Panel_Running = !GUI.Panel_Running;
      string   run_symbol = (GUI.Panel_Running) ? "X" : "O";
      TextRunning = "Running... " + run_symbol;
      clrRunning = clrMediumBlue;
   }

   Create_Button(EA_Identity_ShortGUI + "|PAUSE|0", TextRunning, GUI.column_1, GUI.Row_Save, BTN_wide, int(BTN_High * 1.25), clrWhite, clrRunning, clrNONE);
   GUI_DrawStepGroup(int(BTN_High * 1.25 + 10));

   Create_Button(EA_Identity_ShortGUI + "|Close|0","Close Buy",GUI.column_1,GUI.Row_Save,int(BTN_wide * 0.495),BTN_High,clrWhite,clrBrown,clrNONE);
   Create_Button(EA_Identity_ShortGUI + "|Close|1","Close Sell",int(GUI.column_1 - (BTN_wide * 0.505)),GUI.Row_Save,int(BTN_wide * 0.495),BTN_High,clrWhite,clrBrown,clrNONE);
   GUI_DrawStepGroup(BTN_High + 3);

   Create_Button(EA_Identity_ShortGUI + "|Close|-1", "Close Order ALL", GUI.column_1, GUI.Row_Save, BTN_wide, BTN_High, clrWhite, clrBrown, clrNONE);
   GUI_DrawStepGroup(BTN_High + 10);

//Create_Button(EA_Identity_ShortGUI + "|Clear|1", "Clear Pending", GUI.column_1, GUI.Row_Save, BTN_wide, BTN_High, clrWhite, clrRed, clrNONE);
//GUI_DrawStepGroup(BTN_High + 3);
   Create_Button(EA_Identity_ShortGUI + "|Clear|2", "Clear Pending ALL", GUI.column_1, GUI.Row_Save, BTN_wide, BTN_High, clrBlack, clrGold, clrNONE);
   GUI_DrawStepGroup(BTN_High + 3);
   GUI_DrawPair("Program-Version", "", "", "*v" + EA_Version);

   Create_RectLabel("BG1", false,
                    GUI.column_1 + GUI.Panel_MaginRL, GUI.Row_Start - GUI.Panel_MaginTop,
                    GUI.column_1, GUI.Row_Save - GUI.Row_Step);
   {
      Comments.add("#Version", EA_Version);
      Comments.add("ACCOUNT_TRADE_EXPERT", string(bool(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))));

      Comments.add("Program.Running ", Program.Running );
      Comments.newline();

      Comments.add("Port.ActivePlace_TOP", DoubleToString(Port.docker.ActivePlace_TOP, _Digits) + " => " + DoubleToString(Port.docker.ActivePoint_TOP,0));
      Comments.add("Port.ActivePlace_BOT", DoubleToString(Port.docker.ActivePlace_BOT, _Digits) + " => " + DoubleToString(Port.docker.ActivePoint_BOT,0));
      Comments.newline();

      Comments.add("Docker_total", Docker.Global.Docker_total, 0);
      Comments.add("Docker.Global.Price_Master", Docker.Global.Price_Master, _Digits);
      Comments.newline();

      Comments.add("Buy",string(Port.Buy.CNT_Avtive) + " / " + string(Port.Buy.CNT_Pending) + " = " + DoubleToString(Port.Buy.Sum_ActiveHold,4));
      Comments.add("Sell",string(Port.Sell.CNT_Avtive) + " / " + string(Port.Sell.CNT_Pending) + " = " + DoubleToString(Port.Sell.Sum_ActiveHold,4));
      Comments.add("All",string(Port.All.CNT_Avtive) + " / " + string(Port.All.CNT_Pending) + " = " + DoubleToString(Port.All.Sum_ActiveHold,4));
      Comments.newline();

      {/* exStopLoss_Distance_IO */
         Comments.add("StopLoss_Distance_IO",exStopLoss_Distance_IO);
         Comments.add("Port.ActivePlace_TOP", Port.docker.ActivePlace_TOP, _Digits);
         Comments.add("Port.ActivePlace_BOT", Port.docker.ActivePlace_BOT, _Digits);
         Comments.add("Port.Point_TOP", Port.docker.ActivePoint_TOP, _Digits);
         Comments.add("Port.Point_BOT", Port.docker.ActivePoint_BOT, _Digits);
         Comments.add("esStopLoss_Distance_Point : ", esStopLoss_Distance_Point, _Digits);
      }

      //---
      //---
      Comments.Show();
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  GUI_DrawPair(string  name, string text_header,
                   string text_value_1,
                   string text_value, string   text_vale_symbol = "", bool Is_value = false, bool Is_valueColor = false, double Raw_value = 0,
                   string text_tooltip = "")
{
   if(text_tooltip == "") {
      text_tooltip = text_header;
   }

   Create_Label(EA_Identity_ShortGUI + "|Head|" + name, text_header, clrWhite, GUI.column_1, GUI.Row_Save, text_tooltip);
   if(text_header != "") {
      //text_vale_symbol = (text_vale_symbol == "") ? "" : text_vale_symbol;
      if(text_value_1 == "") {
         Create_Label(EA_Identity_ShortGUI + "|Split|" + name, "-", clrYellow, GUI.column_s, GUI.Row_Save, text_tooltip);
      } else {
         Create_Label(EA_Identity_ShortGUI + "|Split|" + name, text_value_1, clrWhite, GUI.column_s, GUI.Row_Save, text_tooltip);
      }
   }
//---
   color clrBoder = (Is_value) ? clrDimGray : clrBlack;
//---
   color clrText = clrWhite;
   if(Is_valueColor) {
      //clrText = clrDodgerBlue;
      if(Raw_value != 0) {
         if(Raw_value > 0)
            clrText = clrLime;
         else
            clrText = clrRed;
      }
      //---
      if(Is_value) {
         clrBoder =  clrText;
      }
   }
//---
   Create_Edit(EA_Identity_ShortGUI + "|Value|" + name, text_value, GUI.column_2, GUI.Row_Save, GUI.column_2 - GUI.column_3 - 4, 16,
               clrText, clrBlack, clrBoder,
               text_tooltip);

//Create_Edit(EA_Identity_ShortGUI + "|N|" + name,text_vale_symbol,GUI.column_3,GUI.Row_Save,GUI.column_3 - (GUI.Panel_Magin) - 2,16,
//            clrWhite,clrBlack,clrBlack);
   Create_Label(EA_Identity_ShortGUI + "|N|" + name, text_vale_symbol,       clrText, GUI.column_3, GUI.Row_Save,
                text_tooltip);

//---
   GUI.Row_Save += GUI.Row_Step;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  GUI_DrawStepGroup(int  step = 0)
{
   if(step == 0)
      step = GUI.Row_StepGroup;

   GUI.Row_Save += step;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Create_Label(const string            name = "Label",           // label name
                  const string            text = "Label",           // text

                  const color             clr = clrRed,             // color

                  const int               x = 0,                    // X coordinate  /RL
                  const int               y = 0,                    // Y coordinate  /UD

                  string   text_toolstip = "",
//---
                  const int               font_size = 10,           // font size
                  const string            font = "Arial ",           // font

                  const ENUM_BASE_CORNER  corner = CORNER_RIGHT_UPPER, // chart corner for anchoring
                  const double            angle = 0.0,              // text slope
                  const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type
                  const bool              back = false,             // in the background
                  const bool              selection = false,        // highlight to move
                  const bool              hidden = false,            // hidden in the object list
                  const long              z_order = 100)              // priority for mouse click
{

   const long              chart_ID = 0;             // chart's ID
   const int               sub_window = 0;           // subwindow index
//--- reset the error valu
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID, name, OBJ_LABEL, sub_window, 0, 0)) {

   }

   ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, text_toolstip);

//--- set label coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
//--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Create_Edit(const string           name = "Edit",            // object name
                 const string           text = "Text",            // text

                 const int              x = 0,                    // X coordinate
                 const int              y = 0,                    // Y coordinate
                 const int              width = 50,               // width
                 const int              height = 18,              // height

                 const color            clr = clrWhite,           // text color
                 const color            back_clr = clrBlack,      // background color
                 const color            border_clr = clrDimGray,     // border color

                 string   text_toolstip = "",
//---


                 const string           font = "Arial",           // font
                 const int              font_size = 10,           // font size

                 const ENUM_ALIGN_MODE  align = ALIGN_RIGHT,     // alignment type
                 const bool             read_only = true,        // ability to edit
                 const ENUM_BASE_CORNER corner = CORNER_RIGHT_UPPER, // chart corner for anchoring

                 const bool             back = false,             // in the background
                 const bool             selection = false,        // highlight to move
                 const bool             hidden = false,            // hidden in the object list
                 const long             z_order = 100)              // priority for mouse click
{
   const long             chart_ID = 0;             // chart's ID
   const int              sub_window = 0;           // subwindow index

//--- reset the error value
   ResetLastError();
//--- create edit field
   bool  res   =  ObjectCreate(chart_ID, name, OBJ_EDIT, sub_window, 0, 0);
//--- set object coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set object size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);

//--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);

   ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, text_toolstip);

   if(!res) {
      return   true;
   }
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID, name, OBJPROP_ALIGN, align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID, name, OBJPROP_READONLY, read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Create_RectLabel(string           name,
                      bool  IsCallShort =  true,

                      const int              x = -1,                    // X coordinate
                      const int              y = -1,                    // Y coordinate
                      const int              width = 50,               // width
                      const int              height = 18,              // height

                      const color            clr = clrSlateGray,        // flat border color (Flat)
                      const color            back_clr = clrBlack,       // background color

                      const ENUM_BORDER_TYPE border = BORDER_FLAT,         // border type
                      const ENUM_BASE_CORNER corner = CORNER_RIGHT_UPPER, // chart corner for anchoring
                      const ENUM_LINE_STYLE  style = STYLE_SOLID,      // flat border style
                      const int              line_width = 1,           // flat border width
                      const bool             back = false,             // in the background
                      const bool             selection = false,        // highlight to move
                      const bool             hidden = true,            // hidden in the object list
                      const long             z_order = 0)              // priority for mouse click
{
   const long             chart_ID = 0;             // chart's ID
   const int              sub_window = 0;           // subwindow index

   name  =  EA_Identity_ShortGUI + "|" + name;

//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0)) {
      if(IsCallShort)
         return   IsCallShort;
   }
   if(x == -1) {
      return   false;
   }
//--- set label coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set label size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border type

   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set flat border width
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Create_Button(const string            name = "Button",          // button name
                   const string            text = "Button",          // text
                   const int               x = 0,                    // X coordinate
                   const int               y = 0,                    // Y coordinate
                   const int               width = 50,               // button width
                   const int               height = 18,              // button height

                   const color             clr = clrBlack,           // text color
                   const color             back_clr = C'236,233,216', // background color
                   const color             border_clr = clrNONE,     // border color

                   const string            font = "Arial Black",           // font
                   const int               font_size = 11,           // font size

                   const ENUM_BASE_CORNER  corner = CORNER_RIGHT_UPPER, // chart corner for anchoring

                   const bool              state = false,            // pressed/released
                   const bool              back = false,             // in the background
                   const bool              selection = false,        // highlight to move
                   const bool              hidden = false,            // hidden in the object list
                   const long              z_order = 100)              // priority for mouse click
{
   const long              chart_ID = 0;             // chart's ID
   const int               sub_window = 0;           // subwindow index
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0)) {
      //Print(__FUNCTION__,
      //      ": failed to create the button! Error code = ",GetLastError());
      //return(false);
   }
//--- set button coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set button size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- set button state
   ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _CommaZero(double v, int Digit, string charSub = ",")
{
   string   res   = "";

//v = 123456;

   string   temp        =  DoubleToString(MathAbs(v), Digit);

   string   temp_Digits =  "";
   int   DotFind = StringFind(temp, ".", 0);
   if(DotFind > 0) {
      temp_Digits =  StringSubstr(temp, DotFind, Digit + 1);
      temp        =  StringSubstr(temp, 0, DotFind);
   }

   int      n     =  StringLen(temp);

   if(n >= 4) {
      int   f     =  int(MathMod(double(n), 3));

      string   sf = "";
      if(f > 0)   sf =  StringSubstr(temp, 0, f);

      int      secN     =  (n - f) / 3;
      string   secArr[];
      ArrayResize(secArr, secN);

      int   _dig  =  f;
      for(int i = 0; i < secN; i++) {
         secArr[i] = StringSubstr(temp, _dig, 3);
         _dig += 3;
      }

      res = sf;
      for(int i = 0; i < secN; i++) {
         res += charSub + secArr[i];
      }

      if(sf == "") {
         res    =  StringSubstr(res, 1);
      }

   } else {
      res = temp;
   }

   string   negSymbol =  (v < 0) ? "- " : "";
   return   negSymbol + res + temp_Digits;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   _DigitsByValue(double Drawdown, int   digitDefalt = 2)
{
   if(Drawdown == 0) {
      return   digitDefalt;
   }
   if(Drawdown < 1 && Drawdown > -1) {
      string   str   =  DoubleToString(MathAbs(Drawdown), 8);
      int   DotFind  = StringFind(str, ".", 0);
      if(DotFind > 0) {
         string   temp_Digits =  StringSubstr(str, DotFind + 1);
         //Print(temp_Digits);

         int   len =  StringLen(temp_Digits);

         int i = 0;
         for(; i < len; i++) {
            if(StringSubstr(temp_Digits, i, 1) != "0")
               return   i + digitDefalt;
         }
      }
   }

   return   digitDefalt;

}
//+------------------------------------------------------------------+
