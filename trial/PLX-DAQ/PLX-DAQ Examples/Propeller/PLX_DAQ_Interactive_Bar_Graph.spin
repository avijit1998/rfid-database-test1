{{
 ************* Interactive Bar Graph PLX-DAQ Example **************
  Program will send data on to be placed in 2 cells in PLX-DAQ
  which will be graphed as bar graphs.
  Use the "Inteactive Bar Graph" sheet in PLX-DAQ.

  Change the "Delay" time in Excel to be read by the Propeller

  Check "Reset on Connect" to catch configuration data.

  January, 2007
  By Martin Hebel
  SelmaWare Solutions - www.selmaware.com
  Southern Illinois University Carbondale - www.siu.edu/~isat/est

  USE F11 WHEN DOWLOADING TO SAVE TO EEPROM AS PLX-DAQ WILL CYCLE DTR if selected  

  The PLX-DAQ Object Library must be created and started
                ┌────────────────────────────────────────────────┐   
                │ OBJ                                            │
                │  PDAQ : "PLX-DAQ"                              │
                │                                                │
                │ Pub Start | Angle, Row                         │
                │  PDAQ.start(31,30,0,9600) ' Rx,Tx, Mode, Baud  │
                └────────────────────────────────────────────────┘

 ***************** PLX-DAQ data structures used ****************

  PLX-DAQ directives used and how called:
  CELL,SET      Sets the specified cell in Excel to the value
                number or string.
                PLX-DAQ String: CELL,SET,A2,Hello
                Note that CellSet works only with hex values for columns A to F
               ┌────────────────────────────────────────────────┐   
               │ PDAQ.CellSet($B3,100)                          │
               │ PDAQ.CellSetText($A4,String("Hello"))          │
               │ PDAQ.CellSetDiv($D4,1234,100)      ' 1234/100  │   
               └────────────────────────────────────────────────┘  

  CELL,GET      Gets the specified cell's integer value (no text or decimals) in Excel
                to be accepted by the BASIC Stamp
                PLX-DAQ String: CELLGET,D5
                Note that CellSet works only with hex values for columns A to F
               ┌────────────────────────────────────────────────┐   
               │ X := PDAQ.CellGet($A3)                         │
               └────────────────────────────────────────────────┘

  USER1,LABEL   Sets the User1 checkbox in the control to string specified
                PLX-DAQ String: USER1,LABEL,Check me!
               ┌────────────────────────────────────────────────┐   
               │ PDAQ.User1Label(String("Check me!"))           │
               └────────────────────────────────────────────────┘

  USER1,GET     Returns the value of the USER1 checkbox back.
                PLX-DAQ String: USER1,GET
                User1Get returns a True/False condition
               ┌────────────────────────────────────────────────┐                   
               │ IF PDAQ.User1Get == False                      │
               └────────────────────────────────────────────────┘

  USER1,SET     Sets the USER1 check box to checked (1) or unchecked (0)
                PLX-DAQ String: USER1,SET,0
                User1Set accepts a true/false
               ┌────────────────────────────────────────────────┐                                   
               │ PDAQ.User1Set(True)      'sets state           │
               └────────────────────────────────────────────────┘
  MSG           Sets a text message in the PLX-DAQ control
                PLX-DAQ String: MSG,hello
               ┌────────────────────────────────────────────────┐                                   
               │ PDAQ.Msg(string("Hello"))                      │
               └────────────────────────────────────────────────┘

}} 

CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

    CR = 13
    Delay_Cell_Label =  $A4
    Delay_Cell_Text  =  $C4
    SIN_Cell_Label =    $A6
    COS_Cell_Label =    $A7

    Delay_Cell =        $B4
    SIN_Cell =          $B6
    COS_Cell =          $B7

Var
   long DelayTime    
                       
OBJ
   PDAQ : "PLX-DAQ"     

Pub Start  | Angle, x
  DelayTime := 1000
  PDAQ.start(31,30,0,9600)  ' Rx,Tx, Mode, Baud
 

  PDAQ.CellSetText(Delay_Cell_Label,string(" Delay (mSec)"))     ' Label delay cell
  PDAQ.CellSetText(Delay_Cell_Text,string(" Change value and click 'Update Delay' on control."))     
  PDAQ.CellSet(Delay_Cell,DelayTime)                             ' Time into Delay value
  PDAQ.CellSetText(SIN_Cell_Label,string(" SIN x 100"))          ' Label value cell for SIN
  PDAQ.CellSetText(COS_Cell_Label,string(" COS x 100"))          ' Label value cell for COS

  PDAQ.User1Label(string("Update Delay"))                        ' Label USER1
    
  repeat
    repeat Angle from 0 to 359                                   ' Count from 0 to 359
      PDAQ.CellSetDiv(SIN_Cell,Sin(angle)*100,1000)              ' Update Cell with SIN value * 100 / 1000
      PDAQ.CellSetDiv(COS_Cell,Cos(angle)*100,1000)              ' Update Cell with SIN value * 100 / 1000
      x := PDAQ.user1get
        If PDAQ.User1Get                                         ' Check User1 check box
          PDAQ.msg(string("getting delay"))
          x := PDAQ.CellGet(Delay_Cell)                            ' If true, read delay time
           if x > 0
              DelayTime := x
              PDAQ.User1Set(false)                                     ' Clear User1
              PDAQ.Msg(string("Changing Delay Time"))                  ' Post message to control
                  
      PDAQ.Pause(DelayTime)                                      ' delay for time specified

PUB Sin(angle)                  ' SIN angle is 13-bit ; Returns a 16-bit signed value
                                ' Code adapted from Parallax forums to use internal SIN tables
    Angle := (Angle * 1024)/45
    Result := angle << 1 & $FFE
    if angle & $800
       Result := word[$F000 - Result]
    else
       Result := word[$E000 + Result]
    if angle & $1000
       -Result
    Result := (Result * 1000/65535)

PRI Cos(angle)
  Result := Sin(angle + 90)