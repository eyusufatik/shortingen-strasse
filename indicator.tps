//@version=4

study("shortingen straße by esad", overlay=true)

//INPUT

// from hsm
src = input(close, title="Source")
modeSwitch = input("Hma", title="Hull Variation", options=["Hma", "Thma", "Ehma"])
length = input(60, title="Length(180-200 for floating S/R , 55 for swing entry)")
lengthMult = input(1.0, title="Length multiplier (Used to view higher timeframes with straight band)")

useHtf = input(false, title="Show Hull MA from X timeframe? (good for scalping)")
htf = input("240", title="Higher timeframe", type=input.resolution)

switchColor = input(true, "Color Hull according to trend?")
candleCol = input(false,title="Color candles based on Hull's Trend?")
visualSwitch  = input(true, title="Show as a Band?")
thicknesSwitch = input(1, title="Line Thickness")
transpSwitch = input(40, title="Band Transparency",step=5)

// from qqe
RSI_Period = input(6, title='RSI Length')
SF = input(5, title='RSI Smoothing')
QQE = input(3, title='Fast QQE Factor')
ThreshHold = input(3, title="Thresh-hold")
src3 = input(close, title="RSI Source")


RSI_Period2 = input(6, title='RSI Length')
SF2 = input(5, title='RSI Smoothing')
QQE2 = input(1.61, title='Fast QQE2 Factor')
ThreshHold2 = input(3, title="Thresh-hold")

src2 = input(close, title="RSI Source")

// from osc
shortlen = input(5, minval=1, title = "Short Length")
longlen = input(10, minval=1, title = "Long Length")

//FUNCTIONS

// from hsm
//HMA
HMA(_src, _length) =>  wma(2 * wma(_src, _length / 2) - wma(_src, _length), round(sqrt(_length)))
//EHMA    
EHMA(_src, _length) =>  ema(2 * ema(_src, _length / 2) - ema(_src, _length), round(sqrt(_length)))
//THMA    
THMA(_src, _length) =>  wma(wma(_src,_length / 3) * 3 - wma(_src, _length / 2) - wma(_src, _length), _length)





Mode(modeSwitch, src, len) =>
      modeSwitch == "Hma"  ? HMA(src, len) :
      modeSwitch == "Ehma" ? EHMA(src, len) : 
      modeSwitch == "Thma" ? THMA(src, len/2) : na

//OUT
//hsm
_hull = Mode(modeSwitch, src, int(length * lengthMult))
HULL = useHtf ? security(syminfo.ticker, htf, _hull) : _hull
MHULL = HULL[0]
SHULL = HULL[2]


// osc
var cumVol = 0.
cumVol += nz(volume)

shrt = ema(volume, shortlen)
lng = ema(volume, longlen)
osc = 100 * (shrt - lng) / lng



// qqe
Wilders_Period = RSI_Period * 2 - 1


Rsi = rsi(src3, RSI_Period)
RsiMa = ema(Rsi, SF)
AtrRsi = abs(RsiMa[1] - RsiMa)
MaAtrRsi = ema(AtrRsi, Wilders_Period)
dar = ema(MaAtrRsi, Wilders_Period) * QQE

longband = 0.0
shortband = 0.0
trend = 0

DeltaFastAtrRsi = dar
RSIndex = RsiMa
newshortband = RSIndex + DeltaFastAtrRsi
newlongband = RSIndex - DeltaFastAtrRsi
longband := RSIndex[1] > longband[1] and RSIndex > longband[1] ? 
   max(longband[1], newlongband) : newlongband
shortband := RSIndex[1] < shortband[1] and RSIndex < shortband[1] ? 
   min(shortband[1], newshortband) : newshortband
cross_1 = cross(longband[1], RSIndex)
trend := cross(RSIndex, shortband[1]) ? 1 : cross_1 ? -1 : nz(trend[1], 1)
FastAtrRsiTL = trend == 1 ? longband : shortband


lengthq = input(50, minval=1, title="Bollinger Length")
mult = input(0.35, minval=0.001, maxval=5, step=0.1, title="BB Multiplier")
basis = sma(FastAtrRsiTL - 50, lengthq)
dev = mult * stdev(FastAtrRsiTL - 50, lengthq)
upper = basis + dev
lower = basis - dev
color_bar = RsiMa - 50 > upper ? #00c3ff : RsiMa - 50 < lower ? #ff0062 : color.gray

QQEzlong = 0
QQEzlong := nz(QQEzlong[1])
QQEzshort = 0
QQEzshort := nz(QQEzshort[1])
QQEzlong := RSIndex >= 50 ? QQEzlong + 1 : 0
QQEzshort := RSIndex < 50 ? QQEzshort + 1 : 0

Wilders_Period2 = RSI_Period2 * 2 - 1


Rsi2 = rsi(src2, RSI_Period2)
RsiMa2 = ema(Rsi2, SF2)
AtrRsi2 = abs(RsiMa2[1] - RsiMa2)
MaAtrRsi2 = ema(AtrRsi2, Wilders_Period2)
dar2 = ema(MaAtrRsi2, Wilders_Period2) * QQE2
longband2 = 0.0
shortband2 = 0.0
trend2 = 0

DeltaFastAtrRsi2 = dar2
RSIndex2 = RsiMa2
newshortband2 = RSIndex2 + DeltaFastAtrRsi2
newlongband2 = RSIndex2 - DeltaFastAtrRsi2
longband2 := RSIndex2[1] > longband2[1] and RSIndex2 > longband2[1] ? 
   max(longband2[1], newlongband2) : newlongband2
shortband2 := RSIndex2[1] < shortband2[1] and RSIndex2 < shortband2[1] ? 
   min(shortband2[1], newshortband2) : newshortband2
cross_2 = cross(longband2[1], RSIndex2)
trend2 := cross(RSIndex2, shortband2[1]) ? 1 : cross_2 ? -1 : nz(trend2[1], 1)
FastAtrRsi2TL = trend2 == 1 ? longband2 : shortband2

QQE2zlong = 0
QQE2zlong := nz(QQE2zlong[1])
QQE2zshort = 0
QQE2zshort := nz(QQE2zshort[1])
QQE2zlong := RSIndex2 >= 50 ? QQE2zlong + 1 : 0
QQE2zshort := RSIndex2 < 50 ? QQE2zshort + 1 : 0

Greenbar1 = RsiMa2 - 50 > ThreshHold2
Greenbar2 = RsiMa - 50 > upper

Redbar1 = RsiMa2 - 50 < 0 - ThreshHold2
Redbar2 = RsiMa - 50 < lower


//oscCond = osc[shortlen-1]
//mhullCond = close < MHULL[length-1]
//qqeCond = (Redbar1[SF-1] and Redbar2[SF2-1] == 1)
hullColor = switchColor ? (HULL > HULL[2] ? #00ff00 : #ff0000) : #ff9800

oscCond = osc[0]>=0
mhullCond = close < MHULL[0] and (hullColor == #ff0000)
qqeCond = (Redbar1[0] and Redbar2[0] == 1) and (not Redbar1[1] or Redbar2[1] != 1)

shortCond = oscCond and mhullCond and qqeCond


mhullCond2 = close > MHULL[0] and (hullColor == #00ff00)
qqeCond2 = (Greenbar1[0] and Greenbar2[0] == 1) and (not Greenbar1[1] or Greenbar2[1] != 1)

longCond = oscCond and mhullCond2 and qqeCond2




alertcondition(shortCond, title="Short signal", message="Shortoş")
plotshape(shortCond, style=shape.triangledown, color=color.red, transp=0, size=size.normal)

alertcondition(longCond, title="Long signal", message="Longoş")
plotshape(longCond, style=shape.triangleup, location=location.belowbar, color=color.green, transp=0, size=size.normal)



Fi1 = plot(MHULL, title="MHULL", color=hullColor, linewidth=thicknesSwitch, transp=50)
Fi2 = plot(visualSwitch ? SHULL : na, title="SHULL", color=hullColor, linewidth=thicknesSwitch, transp=50)
///< Ending Filler
fill(Fi1, Fi2, title="Band Filler", color=hullColor, transp=transpSwitch)
///BARCOLOR
barcolor(color = candleCol ? (switchColor ? hullColor : na) : na)