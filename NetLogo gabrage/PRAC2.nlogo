globals [circlelist turtleblock mean-distance-to-closest-path coverage bewandelbarepatches max-distance-to-closest-path usedpatches radialist]
turtles-own [stappenteller]
patches-own [owned]

to setup
  clear-all
  ask patches [set pcolor brown]  ;Alle patches bruin
  set-patch-size 2

  ;;V Lijst met cirkels uit IAS website
  set circlelist [[225 -82 30] [-227  -82 33] [-92  -22 26] [-147 98 36] [ 82  -25 25][ -61 -69 24] [ 211 -122 28] [ 77 -109 33] [-111 -7 39] [-28 -141 39][-220 -58 29] [-181 -102 23] [ 93   73 37] [ 166 19 31] [110   18 26][ 227 -61 28] [ 28   145 28] [  8  104 37] [ 133 57 36] [ 84 -144 37]]
  set radialist []
  ask patch 0 0 [ask patches in-radius 225 [set pcolor black]] ;;1 zwarte cirkel in het midden

  foreach circlelist [circle-coordinate ->
    let x item 0 circle-coordinate
    let y item 1 circle-coordinate
    let r item 2 circle-coordinate
    ;^Parseren van lijst naar daadwerkelijk bruikbare dingen
      ask patch x y  [ask patches in-radius r [set pcolor brown]
      ]
    ]
  ;^ Van list met cirkels naar een daadwerkelijke cirkels die bruin worden gekleurd

    create-turtles 11 [
    set size 10
    set color cyan
    ask turtle 0 [move-to patch -72 64]
    ask turtle 1 [move-to patch -71 63]
    ask turtle 2 [move-to patch -70 62]
    ask turtle 3 [move-to patch -70 60]
    ask turtle 4 [move-to patch -71 59]
    ask turtle 5 [move-to patch -72 58]
    ask turtle 6 [move-to patch -73 58]
    ask turtle 7 [move-to patch -74 59]
    ask turtle 8 [move-to patch -75 61]
    ask turtle 9 [move-to patch -74 62]
    ask turtle 10 [move-to patch -73 64]

    ;;^ Turtles maken, grootte mag klein zijn, kleur bepaald, locaties zijn verschillend omdat de turtles anders op elkaar botsen en sterven, op deze manier is er genoeg ruimte

    set heading who * 32.7
    ;;^ Rotatie van turtles zodat ze goed verdeeld zijn en alle kanten op gaan (om opnieuw niet te botsen)
    ]

  ask turtles [pen-down]
  ;;^ Turtles moeten een trail hebben

  reset-ticks
end

to start

  ask turtles [
    ;V Een variabele die per turtle uitmaakt of hij geblockt wordt of niet
    set turtleblock false
    let cone [pcolor] of patches in-cone look-forward look-aside
    let brcone [pcolor] of patches in-cone look-forward look-aside
    ;^Twee cones die alle patches in zich hebben van voor de turtle
    if member? 85 cone [set turtleblock true]
    if member? 35 brcone [set turtleblock true]
    ;^Beide cones checken of er cyaan of bruin in zit; dan is er een blokkade

    ;V Situatie: turtle loopt of -van canvas af of -tegen iets bruins aan of -tegen iets cyaans aan; dan maar kind maken
    if not can-move? (look-forward) or turtleblock = true [
      ;V Kind maken, 1) stappenteller resetten voor dit kind (was nog van zn ouder) & 2) een rotatie meegeven
      hatch 1 [
        set stappenteller 0 ;1)
        lt min-angle + random rand-extra-angle ;2)
        if not can-move? (look-forward) or turtleblock = true [
          die
          ; ^ Kan het kind zodra het geboren is niks, mag dood
        ]
        fd 1
        ;^Kan het wel bewegen, mag ie doorlopen (vanaf nu is hij deel van alle turtles)
        ;Ik laat hem hier nog wel 1 maal bewegen anders is er kans dat hij zn ouder ziet als blokkade
      ]
      ;V Originele stappenteller ook resetten; hij mag weer hatchmodulus lopen
      set stappenteller 0
      ;V Origineel beta graden naar rechts draaien
      rt min-angle + random rand-extra-angle
      fd 1 ;Ik laat hem hier nog wel 1 maal bewegen anders is er kans dat zichzelf ziet als blokkade
      ;V Kan hij  na de roteer wel bewegen? ff checken, anders sterf
      if not can-move? (look-forward) or turtleblock = true [
          die
        ]
    ]

    ;V Te lang rechtdoor gelopen, is saai: ga maar splitsen
    if stappenteller > hatch-modulus [
      ;V Kind maken, 1) stappenteller resetten voor dit kind (hij had hem van zn ouder gekopieerd) & 2) een rotatie meegeven
      hatch 1 [
        set stappenteller 0 ;1)
        lt min-angle + random rand-extra-angle ;2)
        fd 1
        ;^Kan het wel bewegen, mag ie doorlopen (vanaf nu is hij deel van alle turtles)
        ;^Ik laat hem hier nog wel 1 maal bewegen anders is er kans dat hij zn ouder ziet als blokkade
      ]
      ; V Originele stappenteller ook resetten; hij mag weer hatchmodulus lopen
      set stappenteller 0
      ;V Origineel beta graden naar rechts draaien
      rt min-angle + random rand-extra-angle
      fd 1
      ;^Ik laat hem hier nog wel 1 maal bewegen anders is er kans dat zichzelf ziet als blokkade
    ]

    ;V Failsafe voor errors mbt nobody (hij gaat van het canvas af, hij heeft hiervoor al een kind gemaakt, dus nu mag hij dood)
    if patch-ahead look-forward = nobody [
      die
    ]

    ; V Normale situatie, plek om vooruit te gaan
    if [pcolor] of patch-ahead look-forward = black [
      set pcolor color ;Trail
      set stappenteller stappenteller + 1
      forward 1 ;Turtle mag vooruit
    ]

  ]

  ;plot voor turtlecount
  let explorers (count turtles)

  create-temporary-plot-pen "pen"
  set-current-plot "turtlecount"
  plot explorers




  ;Alle patches die blauw zijn zijn bewandeld
  set usedpatches (count patches with [pcolor = cyan])
  ;let #usedpatches (smoothness * usedpatches + (1 - smoothness) * explorers)

  ;Alle patches die zwart zijn zijn nog bewandelbaar
  set bewandelbarepatches (count patches with [pcolor = black])
  ;let #bewandelbarepatches (smoothness * bewandelbarepatches + (1 - smoothness) * explorers)

  ;; Berekening coverage
  set coverage ((usedpatches / bewandelbarepatches) * 100 )
  ;let #coverage (smoothness * coverage + (1 - smoothness) * explorers)



  ;if count turtles = 0 [print "stop"] ;Werkt niet omdat er turtles blijven leven (10 - 20 stuks); weet alleen niet waarom en het is irritant

end

to afstand-dichtsbijzijnde-pad
  ask patches [set owned false]
  ask patches with [pcolor = cyan][set owned true]
  ask patches with [pcolor = brown][set owned true]
  ; ^ Alle patches die niet zwart zijn owned= true geven

  let radius 2
  ask patches with [pcolor = black]
  [
    set radius 2
    set owned false
    ;^Alle zwarte patches owned = false geven
    let success false
    while [success = false]
    [
      ;V voor alle zwarte patches constant een cirkel maken, checken of er blauwe patches in zitten
      ask patches in-radius radius [if pcolor = cyan [set success true]]
      set radius (radius * 1.5) ;Is dit niet zo, verhoog de radius (1.5 geeft prima performance, en ver weg hoef je toch niet veel detail te zien)
      ]
       if (success = true and radius > 2) [set pcolor scale-color yellow (log radius 3) 0 (1 / color-intensity)
       set radialist lput radius radialist
      ; ^ alle radiuses worden in een lijst geplaatst voor de histogram
    ]
    ; ^Is dit wel zo, zet de kleur van de patch naar een gradient van geel op basis van de radius en sliders
  ]

  ;Monitors aanvullen met statistiek; men neme mean of max uit onze radialist
  set mean-distance-to-closest-path (mean radialist)
  set max-distance-to-closest-path (max radialist)

  ;HISTOGRAM voor radialist lijst
  set-current-plot "Distribution of distance to closest path"
  set-plot-x-range 0 (round max-distance-to-closest-path)
  create-temporary-plot-pen "histopen"
  set-plot-pen-mode 1
  histogram radialist

end


to reset-afstand
  ; V Alle geelgekleurde patches (die ooit zwart waren en dus owned = false hadden) weer zwart maken)
  ask patches with [owned = false][
    set pcolor black
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
187
10
1117
621
-1
-1
2.0
1
10
1
1
1
0
0
0
1
-230
230
-150
150
0
0
1
ticks
30.0

BUTTON
64
49
127
82
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
64
92
127
125
go
start
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
10
235
182
268
min-angle
min-angle
0
90
3.0
1
1
NIL
HORIZONTAL

SLIDER
10
270
182
303
rand-extra-angle
rand-extra-angle
0
90
90.0
1
1
NIL
HORIZONTAL

SLIDER
10
130
182
163
hatch-modulus
hatch-modulus
1
20
4.0
1
1
NIL
HORIZONTAL

SLIDER
10
165
182
198
look-forward
look-forward
1
40
8.0
1
1
NIL
HORIZONTAL

SLIDER
10
200
182
233
look-aside
look-aside
60
120
80.0
1
1
NIL
HORIZONTAL

BUTTON
6
364
183
397
NIL
afstand-dichtsbijzijnde-pad
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
530
182
563
color-intensity
color-intensity
0.01
0.3
0.15
0.01
1
NIL
HORIZONTAL

TEXTBOX
24
406
174
521
Waarschuwing: Dit kan lang duren als er veel lege plekken aanwezig zijn!\n\nWaarschuwing: Zet eerst 'go' uit voordat je deze knop gebruikt!\n
11
0.0
1

BUTTON
40
565
147
598
NIL
reset-afstand
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1130
21
1312
66
coverage %
coverage
2
1
11

PLOT
1360
15
1624
232
turtlecount
time
turtles
0.0
500.0
0.0
200.0
false
false
"" "\n"
PENS

MONITOR
1132
185
1264
230
zwarte pacthes
bewandelbarepatches
17
1
11

MONITOR
1130
128
1312
173
NIL
mean-distance-to-closest-path
17
1
11

MONITOR
1132
75
1304
120
NIL
max-distance-to-closest-path
17
1
11

PLOT
1132
240
1623
623
Distribution of distance to closest path
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

MONITOR
1270
185
1350
231
blauw
usedpatches
17
1
11

@#$#@#$#@
## WHAT IS IT?

### GRANULAR FLUID SYSTEM
Een systeem dat zich zou voordoen wanneer men water tussen twee platen platdrukt.


## HOW IT WORKS

De turtles starten op dezelfde positie, en hebben elk hun eigen rotatie. De turtles beginnen te lopen. 
### REGELS
Turtles kunnen enkel door zwarte patches heen, niet door bruine of door blauwe.
Zodra turtles een blokkade tegenkomen proberen ze te splitsen. Beide turtles krijgen dan een verandering in hoek mee die door de gebruiker is in te stellen. 
Als de turtle-ouder hierna niets kan sterft deze. De kloon heeft ook nog een kans om te ontsnappen. Als ook deze opnieuw geblokkeerd is, sterft deze ook.
Als turtles een te lange tijd rechtdoor gaan kunnen deze ook uitzichzelf beslissen om op te splitsen. 


## HOW TO USE IT

Gebruik eerst _setup_ om het speelveld te maken.
Hierna kan men de parameters instellen, en op _go_ drukken.
### PARAMETERS
**hatch-modulus** is de afstand die een turtle ongeblokkeerd kan doorlopen voordat deze uit zichzelf splitst.
**look-forward** is de afstand waarin, als er een blokkade zich voordoet, de turtle deze ook daadwerkelijk ziet. Als deze waarde hoog ligt zal de turtle dus al sneller stoppen als het ziet dat hij over een tijd een blokkade tegenkomt (en hij zal dus proberen te splitsen).
**look-aside** is de hoek waarin de turtle scant op blokkade's. Het is aangeraden deze op 30 te houden. De turtle maakt als het ware een conus.
**min-angle** is de hoek die een kloon meegegeven krijgt zodra hij afsplitst van zijn ouder. De ouder zelf krijgt deze hoek ook mee, enkel de andere kant op.
**max-rand-angle** is de maximale deviatie van de minimale hoek die hierboven beschreven staat. Er zal dus een hoeveelheid toegevoegd worden aan die hoek, hiermee kan de hoeveelheid chaos vergroot worden.

## FEATURES

Nadat de simulatie compleet is (vergeet niet _go_ weer uit te zetten) kan men een heatmap maken van het speelveld. De intensiteit van de kleur kan ook worden ingesteld. 
Hoe geler een patch is, hoe verder weg er zich een bewandeld pad bevindt.
Men kan de gele kleur weer weg halen door op _reset-afstand_ te klikken.

Men kan met behulp van NetLogo's BahaviourSpace een perfecte combo vinden tussen de parameters.

## STATISTIEK
Verscheidene output-waarden staan aan de rechterkant beschreven.
Ook zijn er grafieken waarvan sommigen pas werken wanneer de heatmap gebruikt is.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>start</go>
    <timeLimit steps="800"/>
    <metric>count coverage</metric>
    <enumeratedValueSet variable="look-forward">
      <value value="1"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rand-extra-angle">
      <value value="0"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-aside">
      <value value="60"/>
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-angle">
      <value value="0"/>
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch-modulus">
      <value value="1"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
