breed [agricultores agricultor]
breed [desplazados desplazado]
breed [guerrilleros guerrillero]
breed [vecinos vecino]


globals[
  total-Agricultores           ; Variable que almacena el numero de agricultores presentes en el modelo actualmente
  total-Citadinos-Vecinos      ; Variable que almacena el numero de vecinos presentes en el modelo actualmente
  total-Desplazados            ; Variable que almacena el numero de desplazados presentes en el modelo actualmente
  total-Guerrilleros           ; Variable que almacena el numero de guerrilleros presentes en el modelo actualmente
  total-Desplazados-en-Bogota  ; Numero de desplazados que van entrando a la capital
  vecinos-desplazados          ; Conocer la cantidad de Vecinos desplazados Cercanos con el fin de saber cuando me debo desplazar
  desplazados-con-hogar        ; Variable que me permite conocer cuandos desplazados encontraron hogar
  iniciar-vecinos              ; Variable que me permite activar el proceso de los vecinos
  predio-invadido              ; Variable que me permite conocer la cantidad de predios invadidos
  predio-ocupado               ; Variable que me permite conocer la cantidad de predios ocupados
]

guerrilleros-own[
  buscar                       ; Variable en la que se almacena el agricultor mas cercano en un radio de 60 patches.
  encontrado                   ; Variable en la que se almacena el nombre de los agricultores mas cercano.
  agricultor-mas-cercano       ; Varible en la que se guarda el nombre del agricultor mas cercano.
  parar?                       ; Variable de estado que indica cuando un guerrillero debe parar de buscar agricultores.
  ]

desplazados-own[
  con-dinero?                  ; Variable que me indica si un desplazado tiene un capital
  capital                      ; Capital con el que cuenta un Desplazado para Conseguir Vivienda.
  busqueda-lugar               ; Variable en la que se almacenan los patches que cumplen la condicion de que el color del Patch sea un valor X que representaria los puntos de llegada de los desplazados.
  encontrado                   ; Variable en la que se almacenan los puntos encontrados.
  barrio-mas-cercano           ; Variable en la que se alamacena el punto mas cercano de los puntos encontrados.
  lugar-encontrado?            ; Indica si se ha encontrado un lugar
  llegue-lugar?                ; Indica si el desplazado ha llegado al lugar trazado



  revisar-casas                ; Variable en la que se almacenan los patches que cumplen la condicion de que el color del Patch sea un valor X que representaria los hogares a los que se pueden dirigir los desplazados.
  target-casa                  ; Variable en la que se almacenan los puntos encontrados.
  escoger-casa                 ; Variable en la que se alamacena el punto mas cercano de los puntos encontrados.
  Hogares-encontrados?         ; Indica si se ha encontrado un lugar
  llegue-hogar?                ; Indica si el desplazado ha llegado al lugar trazado



]

vecinos-own[
  valor                        ; Variable que indica el valor del predio el precio puede variar entre 3000000 o 300000
  buscar-nuevo-hogar           ; Variable en la que se almacenan los patches que cumplen la condicion de que el color del Patch sea un valor X que representaria los puntos de llegada de los vecinos.
  target-hogar                 ; Variable en la que se almacenan los puntos encontrados.
  escoger-nuevo-hogar          ; Variable en la que se alamacena el punto mas cercano de los puntos encontrados.
  Hogar-encontrado?            ; Indica si se ha encontrado un lugar
  estoy-en-casa?               ; Indica si el desplazado ha llegado al lugar trazado


  ]


agricultores-own[
  desplazado?                  ; Variable que indica si un agricultor ha sido desplazado
  asustado                     ; Variable en la que se almacena si existe un guerrillero cerca en un radio de 1 patch
  guerrillero-cerca            ; Variable en la que se almacena la distancia del guerrillero cerca
  ]


patches-own[

  libre?                       ; Variable que indica si un predio esta libre o no
]



;------------------- Configuracion del Mundo ---------------------
to cargar-mapa
  import-pcolors-rgb "Mapa/San_Cristobal.bmp"
end




to create-agentes

 create-vecinos numero-citadinos [

   let random-zone random 2

   if (random-zone = 1)[
   setxy (random (63 - 51)+ 51) (random  (101 - 25) + 25)]
   if (random-zone = 0)[
     setxy (random (73 - 39)+ 39) (random  (92 - 62) + 62)]


   set color orange
   set size 1.5
   set Hogar-encontrado? false
   set estoy-en-casa? false

   set valor random ((3000000 - 450000) + 450000)
   ifelse (valor >= 2100000)
   [set pcolor yellow - 2]                                               ; yellow - 2 color de predios posibles para ocupar
   [set pcolor brown + 2]

  ]

  create-agricultores numero-agricultores [
    let random-zone-agri random 2
    set size 1.5
    ifelse  (random-zone-agri = 1 ) [
    setxy (random (174 - 152) + 152) (random (20 - 8) + 8)]
    [
    setxy (random (174 - 152) + 152) (random (115 - 110) + 110)]

    set color black

  ]


  create-guerrilleros (random (10 - 5) + 5)[
    set size 1.5
    let random-zone random 2
    ifelse (random-zone = 1 ) [

      setxy (random (178 - 175) + 175) (random (20 - 8) + 8)]
    [
      setxy (random (178 - 175) + 175) (random (115 - 110) + 110)
      ]

    set color red
  ]


end

to definir-predios

  ask n-of random ((20 -  10) + 10) patches with[
    pcolor = [204 213 193]][

      set pcolor brown - 1                                         ; brown - 1 color de predios posibles para ocupar

      set libre? true
      ]

  ask patches with [pcolor = brown + 2][set libre? true]
  ask patches with [pcolor = yellow - 2][set libre? false]
end

to setup
  ca
  set-default-shape guerrilleros "person soldier"
  set-default-shape agricultores "person farmer"
  set-default-shape vecinos "person business"
  set-default-shape desplazados "person"
  set iniciar-vecinos 0
  set desplazados-con-hogar 0
  cargar-mapa

  create-agentes
  definir-predios

  reset-ticks
end

;-------------------------- Simulacion ------------------------------------


;--------------------------------------------------------------------------
;---------------------------Comportamiento Guerrilleros -------------------
to comportamiento-guerrilleros

   if any? other turtles-here with [color = black]  ; si el guerrillero se encuentra con un agricultor le cambia su raza a desplazado
   [desplazar]
   buscar-agricultores
   ifelse any? encontrado
   [desplazar-agricultores][ fd 0]

end

to buscar-agricultores
  set buscar agricultores in-radius 60
  set encontrado (turtle-set buscar)
end

to desplazar-agricultores
  set agricultor-mas-cercano min-one-of encontrado [distance myself]
  face agricultor-mas-cercano
  if any? other turtles-here
  [desplazar]


end

to desplazar
  ask agricultores-on patch-here [set breed desplazados set color blue set con-dinero? false set lugar-encontrado? false set llegue-lugar? false set Hogares-encontrados? false set llegue-hogar? false] ; se cambia la raza del agricultor a desplazado
end
;----------------------------------------------------------------------------
;---------------------Comportamiento Agricultores ---------------------------

to comportamiento-agricultores

    revisar-zona
    ifelse any? asustado [huir-zona][]


end

to revisar-zona
  set asustado guerrilleros in-radius 1
end

to huir-zona
  set guerrillero-cerca min-one-of asustado [distance myself]
  face guerrillero-cerca
  rt 180
end


;----------------------------------------------------------------------------
;--------------------Comportamiento Desplazados -----------------------------


;---------------------Movimiento hacia la Ciudad ----------------------------

to calcular-ahorro
  if (con-dinero? = false)[
   set capital random ((1000000 - 400000) + 400000)
   set con-dinero? true
   ]
end

to buscar-bogota
  set busqueda-lugar patches with [pcolor = brown - 1]  ; 1
  set encontrado (patch-set busqueda-lugar) ;2
end

to desplazarse
  if (lugar-encontrado? = false)[
  set barrio-mas-cercano one-of encontrado                 ; Se almacena el lugar hacia donde se dirigirá el desplazado. ;3
  set lugar-encontrado? true
  ]
  face barrio-mas-cercano                                  ; Se le indica que se mueva hacia el lugar seleccionado.   ;4

end


to desplazarce-bogota

    calcular-ahorro
    buscar-bogota

    ifelse any? encontrado
    [desplazarse][]

    revisar-llegada

    ifelse (llegue-lugar? = false)[fd 0.8][fd 0]


end


to revisar-llegada                                           ; Revisar si el desplazado llego al punto de destino

  let coordinate word ("x") barrio-mas-cercano
  let xcoord substring coordinate 8 10
  let ycoord substring coordinate 11 13
  let xcoor read-from-string xcoord
  let ycoor read-from-string ycoord

  if ((round(xcor) = xcoor) and (round(ycor) = ycoor ))[
     if (llegue-lugar? = false)[
       set llegue-lugar? true
     ]

   ]
end


;---------------------------------------------------------------------------

to buscar-vivienda
  if (llegue-lugar? = true)[

  buscar-hogar

  ifelse any? revisar-casas
    [desplazarse-casas][]

  analizar-hogar

  ifelse (llegue-hogar? = false)[fd 0.8][fd 0]
  ]
end

to buscar-hogar

    set target-casa  patches with [libre? = true]  ; 1


    set revisar-casas (patch-set target-casa) ; 2

end

to desplazarse-casas

    if (Hogares-encontrados? = false)[

    set escoger-casa one-of revisar-casas ;3 ; revisar si se puede escoger al random y no una de esas
    set Hogares-encontrados? true
    ]

    face escoger-casa ;4

end

to analizar-hogar
  let coordinate word ("x") escoger-casa

  let xcoord substring coordinate 8 10
  let ycoord substring coordinate 11 13

  let xcoor read-from-string xcoord
  let ycoor read-from-string ycoord

  if ((round(xcor) = xcoor) and (round(ycor) = ycoor ))
  [

     ifelse (pcolor = brown + 2)[
     set pcolor black
     set iniciar-vecinos 1
     set predio-ocupado predio-ocupado + 1
     set desplazados-con-hogar desplazados-con-hogar + 1


     ][
     if (pcolor = brown - 1)[

       ifelse (capital <= 500000)[
         set pcolor red
         set predio-invadido predio-invadido + 1
         set desplazados-con-hogar desplazados-con-hogar + 1
         ]
       [ set pcolor orange set desplazados-con-hogar desplazados-con-hogar + 1 set predio-ocupado predio-ocupado + 1]

       ]]

     if (llegue-hogar? = false)
     [

       set llegue-hogar? true

    ]
    set libre? false

   ]

end

;----------------------------------------------------------------------------
;----------------------Comportamiento Vecinos -------------------------------

to conocer-vecino-desplazado
  set vecinos-desplazados count (turtles-on patch-here) with [color = blue]

end

to buscar-nuevo-hogar-cercano
  conocer-vecino-desplazado


    set target-hogar  patches with [pcolor = [202 217 253]]                                    ; Los vecinos se dirigen a los lotes de color [202 217 253]
    set buscar-nuevo-hogar (patch-set target-hogar)

  end

to desplazarce-to-hogar
    if (Hogar-encontrado? = false)[

    set escoger-nuevo-hogar  one-of buscar-nuevo-hogar
    set Hogar-encontrado? true
    ]

    face escoger-nuevo-hogar ;4

end


to analizar-hogar-citadino
  let coordinate word ("x") escoger-nuevo-hogar

  let xcoord substring coordinate 8 10
  let ycoord substring coordinate 11 13

  let xcoor read-from-string xcoord
  let ycoor read-from-string ycoord

  if ((round(xcor) = xcoor) and (round(ycor) = ycoor ))
  [



     if (estoy-en-casa? = false)
     [

       set estoy-en-casa? true
       set pcolor magenta + 1
    ]


   ]

end

to desplazarce-nuevo-barrio


    buscar-nuevo-hogar-cercano

    ifelse any? buscar-nuevo-hogar
    [desplazarce-to-hogar][]

    analizar-hogar-citadino

    ifelse (estoy-en-casa? = false)[fd 0.8][fd 0]


end
;----------------------------------------------------------------------------
;--------------------- Inicio de Simulacion ---------------------------------

to go
  actualizar-variables-globales


  repeat 1 [ask agricultores [comportamiento-agricultores fd 0.1]]


  repeat 2 [
    ask guerrilleros
    [
      ifelse (total-agricultores > 0)[
      comportamiento-guerrilleros fd 0.2]
      [set parar? true]

      if (parar? = true)[fd 0]
    ]
    ]


 ask desplazados [
   desplazarce-bogota                                   ; Buscar algun lugar al cual movilizarse
   buscar-vivienda                                      ; Despues de llegar al punto de destino el desplazado busca un hogar en el cual pueda habitar
   ]

 if (iniciar-vecinos = 1) [
   ask vecinos [
       desplazarce-nuevo-barrio                         ; Buscar algun lugar al cual movilizarse
     ]
   ]

  tick
end


to actualizar-variables-globales
  set total-Agricultores (count agricultores)
  set total-Citadinos-Vecinos (count vecinos)
  set total-Desplazados (count desplazados)
  set total-Guerrilleros (count guerrilleros)
  set total-Desplazados-en-Bogota count desplazados with [llegue-lugar? = true]
end
@#$#@#$#@
GRAPHICS-WINDOW
228
10
1324
815
-1
-1
6.0
1
10
1
1
1
0
1
1
1
0
180
0
128
0
0
1
ticks
30.0

BUTTON
42
31
105
64
NIL
setup
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
40
98
212
131
numero-citadinos
numero-citadinos
0
60
8
1
1
NIL
HORIZONTAL

SLIDER
41
143
213
176
numero-agricultores
numero-agricultores
0
50
18
1
1
NIL
HORIZONTAL

BUTTON
42
202
167
235
Iniciar Simulacion
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1349
13
1709
207
Numero de Desplazados
Tiempo
# De Desplazados
0.0
50.0
0.0
50.0
true
true
"" ""
PENS
"Desplazados" 1.0 0 -13345367 true "" "plot count desplazados"
"Agricultores" 1.0 0 -7500403 true "" "plot count agricultores"

BUTTON
44
249
166
285
Paso a Paso
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1350
215
1708
401
Numero de Desplazados LLegan a la Capital
Tiempo
# de Desplazados
0.0
50.0
0.0
50.0
true
true
"" ""
PENS
"Desplazados" 1.0 0 -2674135 true "" "plot total-Desplazados-en-Bogota"

MONITOR
1724
91
1836
136
NIL
total-Desplazados
17
1
11

MONITOR
1720
271
1894
316
NIL
total-Desplazados-en-Bogota
17
1
11

PLOT
1352
410
1710
604
# de Desplazados que Encuentran  Hogar
Tiempo
# de Desplazados
0.0
50.0
0.0
50.0
true
true
"" ""
PENS
"Desplazados" 1.0 0 -13345367 true "" "plot desplazados-con-hogar"

PLOT
1352
615
1708
765
# Comportamiento predios Acupados
Tiempo
Numero de Predios
0.0
50.0
0.0
25.0
true
true
"" ""
PENS
"Predios Ocupados" 1.0 0 -13840069 true "" "plot predio-ocupado"
"Predios Invadidos" 1.0 0 -2674135 true "" "plot predio-invadido"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
