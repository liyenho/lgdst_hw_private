** This design also has the tp_45 which is the custom chip select from the atmel 
   also the bugs in the readback have been cleared out.

** This design has the tcl file for the automatic update of the year and date.

**In This design, the ouput pin tp_50 is being changed to the input and is being driven by the atmel.
**The led Wifi goes high if the tp_50 is high and if not it changes to ts_valid if the signal goes low

This is the original version of the rxcpld with the resync algorithm in it.
This design is a new project for the revision 2 board