Axon Hillock Subcircuit

.include '65nm_bulk.pm'

.TEMP 25

.option measform = 3

.GLOBAL vdd 
.OPTION 
+ ARTIST=2
+ INGOLD=2
**+ PSF=2
 **********************************************************************************************************
**************************** Parameters *********************************

.unprotect         
.param wl1=1
.param clamp1=0.8
.param nw=2u
.param sdw=1.7u
.param pw=2u
.param dgen1=0.3

.param supply=0.5
.param bounce=0m

.param thin  = 1.65e-9
.param thick = 1.85e-9
.param tox = thin 
.param vtK=0

.param w_inp = 1X
.param w_lay = w_inp
.param w_lay2 = w_inp
.param w_lay3 = w_inp
.param w_test = 1X
.param period = 200n
.param duty_on = 50n
.ic nc3=0


************************************  Simple Inverter Subcircuit **********************
.SUBCKT inverterS inv invb

Mpx2 Vdd  inv invb Vdd pmos   w=8*65n  l=65n  tox = thick vtK=0      $ Transistor
Mnx2 invb inv 0      0 nmos   w=2*65n  l=65n  tox = thick  vtK=0          $ Transistor


.ENDS inverterS



************************************  Inverter Subcircuit **********************
.SUBCKT inverter inv invb

Mpx1 Vdd inv invb Vdd pmos   w=8*65n  l=65n  tox = thick vtK=0      $ Transistor
Mnx1 invb inv 0 0 nmos       w=4*65n  l=65n  tox = thick  vtK=0          $ Transistor


.ENDS inverter

************************************  Synapse Subcircuit **********************
.SUBCKT synapse inp inpb inpf strength=0.5X

R100 inp inp_t strength

Mp100 inp_t inpb inpf Vdd pmos   w=2*65n  l=2*65n        $ Transistor

.ENDS synapse


************************************  Neuron Subcircuit **********************
************************************************************************
************************************************************************

.SUBCKT axon_inp inp out out_b

************************************ Capacitor **********************
R1 A inp 1m
C1 A 0 0.1p

************************************ Amplifier **********************
Xinv1 A B   inverter
Xinv2 B out inverter

C2 out A 0.1p

************************************ Reset Circuit **********************

M1 A out C  0   nmos   w=2.2*65n  l=65n      $ Transistor

M2 C Vp  0  0   nmos   w=15*65n  l=65n      $ Transistor

Xinv3 out out_b inverterS

.ENDS axon_inp

************************************************************************
************************************************************************
************************************************************************


**R2 vinp  l1_inp1  w_inp
**R3 vinp2 l1_inp2  w_inp
**R4 vinp3 l1_inp3  w_inp

Xinv4 vinp  vinpb  inverterS
Xinv5 vinp2 vinp2b inverterS
Xinv6 vinp3 vinp3b inverterS

Xsyn1 vinp  vinpb  l1_inp1 synapse strength=w_inp 
Xsyn2 vinp2 vinp2b l1_inp2 synapse strength=w_inp 
Xsyn3 vinp3 vinp3b l1_inp3 synapse strength=w_inp 

XNeu1_L1 l1_inp1 l1_out1 l1_out1b axon_inp
XNeu2_L1 l1_inp2 l1_out2 l1_out2b axon_inp
XNeu3_L1 l1_inp3 l1_out3 l1_out3b axon_inp


Xsyn4 l1_out1 l1_out1b l2_inp1 synapse strength=w_test
Xsyn5 l1_out2 l1_out2b l2_inp1 synapse strength=w_lay2
Xsyn6 l1_out3 l1_out3b l2_inp1 synapse strength=w_lay3


Xsyn7 l1_out1 l1_out1b l2_inp2 synapse strength=w_test
Xsyn8 l1_out2 l1_out2b l2_inp2 synapse strength=w_lay2
Xsyn9 l1_out3 l1_out3b l2_inp2 synapse strength=w_lay3


Xsyn10 l1_out1 l1_out1b l2_inp3 synapse strength=w_test
Xsyn11 l1_out2 l1_out2b l2_inp3 synapse strength=w_lay2
Xsyn12 l1_out3 l1_out3b l2_inp3 synapse strength=w_lay3

**R20 l1_out1 l2_inp1 w_lay
**R21 l1_out2 l2_inp1 w_lay
**R22 l1_out3 l2_inp1 w_lay

**R23 l1_out1 l2_inp2 w_lay2
**R24 l1_out2 l2_inp2 w_lay2
**R25 l1_out3 l2_inp2 w_lay2

**R26 l1_out1 l2_inp3 w_lay
**R27 l1_out2 l2_inp3 w_lay
**R28 l1_out3 l2_inp3 w_lay


XNeu1_L2 l2_inp1 l2_out1 l2_out1b axon_inp
XNeu2_L2 l2_inp2 l2_out2 l2_out2b axon_inp
XNeu3_L2 l2_inp3 l2_out3 l2_out3b axon_inp

C3 Vdd 0 1m


*******************************
***** Signals **********************

**I1 inp 0 -200n
**I1 inp1 0 pulse   0 -200n  10n  50p 50p 25n  50n
V1 vinp   0 pulse   0 1      10n  50p 50p duty_on  period
V5 vinp2  0 pulse   0 1      10n  50p 50p duty_on  period
V6 vinp3  0 pulse   0 1      10n  50p 50p duty_on  period
V2 Vdd   0 1
V3 Vp    0 0.5
V4 gnd   0 0



.MEASURE tran spike1 TRIG AT = 10n TARG V(l2_out1) VAL=0.5 rise = 1
.MEASURE tran spike2 TRIG AT = 10n TARG V(l2_out1) VAL=0.5 rise = 2
.MEASURE tran spikediff TRIG V(l2_out1) VAL=0.5 RISE=1 TARG V(l2_out1) VAL=0.5 RISE=2
.MEASURE tran avgpow AVG(POWER)

.print  I(R2)
.print  I(R3)
.print I1
.PRINT POWER


.tran   1n 0.05m SWEEP w_test 1X 10X 1X

.end 


