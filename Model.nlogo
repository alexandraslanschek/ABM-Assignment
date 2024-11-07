globals [number-of-ticks-per-day productivity team-colors x-coordinates y-coordinates]

;; Types of agents
breed [absentees absentee] ;; Miss work when sick (if allowed)
breed [presentees presentee] ;; Work when sick

;; Agent properties
turtles-own [effective-recovery-days immune infected out sick sick-leave-days team work]

to setup
  clear-all

  ;; Empty list for final outcome
  set productivity []

  ;; Set number of ticks per day
  set number-of-ticks-per-day 4

  ;; Assign colors to teams
  set team-colors [yellow orange pink violet blue sky turquoise green brown]

  ;; Assign patches to teams
  set x-coordinates [1 2 3 1 2 3 1 2 3]
  set y-coordinates [3 3 3 2 2 2 1 1 1]

  ;; Set movement across teams to 0 if number of teams is 1
  if number-of-teams = 1 [
    set movement-across-teams 0
  ]

  ;; Create absentees
  create-absentees (1 - share-of-presentees) * number-of-workers [
    set shape "person"
    set size 0.3

    ;; Randomly assign workers to teams
    set team random number-of-teams + 1

    ;; Assign colors and patches to workers, based on teams
    set color item (team - 1) team-colors
    setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
  ]

  ;; Create presentees
  create-presentees share-of-presentees * number-of-workers [
    set shape "person"
    set size 0.3

    ;; Randomly assign workers to teams
    set team random number-of-teams + 1

    ;; Assign colors and patches to workers, based on teams
    set color item (team - 1) team-colors
    setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45

    ;; Presentees work always
    set work true
  ]

  ;; Assume that everybody is healthy (but nobody immune) at beginning
  ask turtles [
    set infected false
    set sick false
  ]

  ;; Since everybody is healthy, absentees work in the first period too
  ask absentees [
    set work true
  ]

  ;; PLOT: Set maximum values of y axes
  if count absentees > 0 [
    set-current-plot "absentee-behavior"
    set-plot-y-range 0 count absentees
  ]

  if count presentees > 0 [
    set-current-plot "presentee-behavior"
    set-plot-y-range 0 count presentees
  ]

  set-current-plot "sickness"
  set-plot-y-range 0 count turtles

  reset-ticks
end

to go
  if ticks mod number-of-ticks-per-day = 0 and ticks != 0 [ ;; First tick of a day
    ;; Decide what to do today
    ask absentees [
      ;; If infected yesterday
      ifelse infected [
        ;; Sick today
        set sick true
        set infected false ;; Should be true if and only if infected today

        ;; If still allowed to take sick leave
        ifelse sick-leave-days < max-sick-leave-days [
          ;; Miss work
          set work false

          ;; Assign grey and patches on edge to workers at home
          set color grey
          let at-home one-of patches with [pxcor = 0 or pxcor = 4 or pycor = 0 or pycor = 4]
          setxy [pxcor] of at-home - random-float 0.45 + random-float 0.45 [pycor] of at-home - random-float 0.45 + random-float 0.45
        ][ ;; If not anymore allowed to take sick leave
          ;; Work
          set work true

          ;; Assign red to sick workers at office
          set color red

          ;; Assign patches to workers, based on teams (we assume that workers start within teams)
          setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
        ]
      ][
        ;; If sick
        ifelse sick [
          ;; If not anymore allowed to take sick leave
          if sick-leave-days >= max-sick-leave-days [
            ;; Go back to work
            set work true

            ;; Assign red to sick workers at office
            set color red

            ;; Assign patches to workers, based on teams
            setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
          ]
        ][ ;; If healthy
          ;; Work
          set work true

          ;; Assign colors and patches to workers, based on teams
          set color item (team - 1) team-colors
          setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
        ]
      ]
    ]

    ask presentees [
      ;; If infected yesterday
      ifelse infected [
        ;; Sick today
        set sick true
        set infected false ;; Should be true if and only if infected today

        ;; Assign red to sick workers at office
        set color red

        ;; Assign patches to workers, based on teams
        setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
      ][
        ;; If sick
        ifelse sick [
          ;; Assign red to sick workers at office
          set color red

          ;; Assign patches to workers, based on teams
          setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
        ][ ;; If healthy
          ;; Assign colors and patches to workers, based on teams
          set color item (team - 1) team-colors
          setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
        ]
      ]
    ]
  ]

  if ticks mod number-of-ticks-per-day != 0 and (ticks + 1) mod number-of-ticks-per-day != 0 [ ;; Intermediate ticks of a day
    ;; Randomly infect workers, based on contagiousness and number of sick workers on patches
    infect

    ;; If there are multiple teams, move workers
    if number-of-teams > 1 [
      move
    ]
  ]

  if (ticks + 1) mod number-of-ticks-per-day = 0 [ ;; Last tick of a day
    ;; Randomly infect workers, based on contagiousness and number of sick workers on patches
    infect

    ;; If there are multiple teams, move workers
    if number-of-teams > 1 [
      move
    ]

    ;; Randomly infect workers, based on contagiousness and number of sick workers on patches
    infect

    ;; PLOT: Plot today's mean productivity by agent type
    set-current-plot "mean-productivity"
    set-current-plot-pen "workers"
    set productivity lput mean-productivity turtles productivity ;; For final outcome
    plot last productivity

    if count absentees > 0 [
      set-current-plot-pen "absentees"
      plot mean-productivity absentees
    ]

    if count presentees > 0 [
      set-current-plot-pen "presentees"
      plot mean-productivity presentees
    ]

    ;; PLOT: Plot today's absentee behavior
    set-current-plot "absentee-behavior"
    set-current-plot-pen "healthy-at-work"
    plot count absentees with [sick = false and work = true]

    set-current-plot-pen "sick-at-home"
    plot count absentees with [sick = true and work = false]

    set-current-plot-pen "sick-at-work"
    plot count absentees with [sick = true and work = true]

    ;; PLOT: Plot today's presentee behavior
    set-current-plot "presentee-behavior"
    set-current-plot-pen "healthy-at-work"
    plot count presentees with [sick = false and work = true]

    set-current-plot-pen "sick-at-home"
    plot count presentees with [sick = true and work = false] ;; If not 0, something is wrong

    set-current-plot-pen "sick-at-work"
    plot count presentees with [sick = true and work = true]

    ;; PLOT: Plot today's prevalence
    set-current-plot "sickness"
    set-current-plot-pen "prevalence"
    plot count turtles with [sick = true]

    ;; PLOT: Plot today's endogenous incidence
    set-current-plot-pen "endogenous-incidence"
    plot count turtles with [infected = true]

    ;; Randomly infect workers exogenously
    let endogenous-incidence count turtles with [infected = true] ;; For plot
    ask turtles with [sick = false and immune = 0] [
      set infected infected or random-float 1 < exogenous-sickness ;; Some healthy and vulnerable workers may be infected already
    ]

    ;; PLOT: Plot today's exogenous incidence
    set-current-plot-pen "exogenous-incidence"
    plot count turtles with [infected = true] - endogenous-incidence

    ;; PLOT: Plot today's immunity
    set-current-plot-pen "immunity"
    plot count turtles with [immune > 0]

    ;; Update immunity (nothing changes for vulnerable workers)
    ask turtles with [immune > 0] [
      ;; Workers who remain immune
      ifelse immune < immunity-days [
        ;; Increase counters
        set immune immune + 1
      ][ ;; Workers who lose immunity
        set immune 0
      ]
    ]

    ;; Recovery of sick workers
    ask turtles with [sick = true] [
      ;; If at home
      ifelse not work [
        ;; Normal recovery
        set effective-recovery-days effective-recovery-days + 1

        ;; Count sick leave days since beginning of year
        set sick-leave-days sick-leave-days + 1
      ][ ;; If at office
        ;; Slower recovery
        set effective-recovery-days effective-recovery-days + slower-recovery
      ]

      ;; If fully recovered
      if effective-recovery-days >= recovery-days [
        ;; Healthy
        set sick false
        set effective-recovery-days 0 ;; Should be 0 at beginning of next sickness

        ;; Immune
        if immunity-days > 0 [
          set immune 1
        ]
      ]
    ]
  ]

  ;; Simulate a year
  if ticks = 260 * number-of-ticks-per-day - 1 [
    ;; Final outcome
    output-print word "Mean productivity = " (word precision mean productivity 4)

    stop
  ]
  tick
end

to infect
  ;; Only healthy and vulnerable workers can be infected
  ask turtles with [sick = false and immune = 0] [
    let contagious-workers count turtles-here with [sick = true]
    repeat contagious-workers [
      set infected random-float 1 < contagiousness
      if infected [
        stop
      ]
    ]
  ]
end

to move
  ;; Move only workers at office
  ask turtles with [work = true] [
    ;; Draw workers who move to other teams
    ifelse random-float 1 < movement-across-teams [
      ;; Draw teams
      set out random number-of-teams + 1

      ;; Make sure that workers move to other teams
      while [out = team] [
        set out random number-of-teams + 1
      ]

      ;; Move workers to other teams
      setxy item (out - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (out - 1) y-coordinates - random-float 0.45 + random-float 0.45
    ][ ;; Remaining workers
      ;; If in other teams
      if out > 0 [
        ;; Return
        setxy item (team - 1) x-coordinates - random-float 0.45 + random-float 0.45 item (team - 1) y-coordinates - random-float 0.45 + random-float 0.45
        set out 0 ;; Should be greater than 0 if and only if in other teams
      ]
    ]
  ]
end

to-report mean-productivity [x]
  let sum-of-productivity 0
  ask x [
    if work = true [
      set sum-of-productivity (ifelse-value
        sick = true [sum-of-productivity + (1 - severity)]
        [sum-of-productivity + 1])
    ]
  ]

  let number-of-x count x

  report sum-of-productivity / number-of-x
end
@#$#@#$#@
GRAPHICS-WINDOW
526
18
1061
554
-1
-1
105.4
1
10
1
1
1
0
0
0
1
0
4
0
4
0
0
1
ticks
30.0

SLIDER
20
197
230
230
number-of-teams
number-of-teams
1
9
5.0
1
1
NIL
HORIZONTAL

INPUTBOX
20
116
230
176
number-of-workers
100.0
1
0
Number

SLIDER
19
307
231
340
share-of-presentees
share-of-presentees
0
1
0.45
0.01
1
NIL
HORIZONTAL

BUTTON
20
18
111
69
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
281
322
494
355
slower-recovery
slower-recovery
0
1
0.3
0.01
1
NIL
HORIZONTAL

INPUTBOX
281
237
493
297
recovery-days
7.0
1
0
Number

INPUTBOX
17
477
494
537
max-sick-leave-days
10.0
1
0
Number

BUTTON
137
18
228
69
NIL
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

SLIDER
19
252
231
285
movement-across-teams
movement-across-teams
0
1
0.25
0.01
1
NIL
HORIZONTAL

INPUTBOX
280
379
493
439
immunity-days
60.0
1
0
Number

SLIDER
281
180
493
213
severity
severity
0
1
0.25
0.01
1
NIL
HORIZONTAL

PLOT
1096
17
1876
263
mean-productivity
days
mean-productivity
0.0
260.0
0.0
1.0
false
true
"" ""
PENS
"workers" 1.0 0 -16777216 true "" ""
"absentees" 1.0 0 -7500403 true "" ""
"presentees" 1.0 0 -2674135 true "" ""

PLOT
1097
565
1485
861
absentee-behavior
NIL
NIL
0.0
260.0
0.0
1.0
false
true
"" ""
PENS
"healthy-at-work" 1.0 0 -16777216 true "" ""
"sick-at-home" 1.0 0 -7500403 true "" ""
"sick-at-work" 1.0 0 -2674135 true "" ""

PLOT
1489
565
1875
861
presentee-behavior
NIL
NIL
0.0
260.0
0.0
1.0
false
true
"" ""
PENS
"healthy-at-work" 1.0 0 -16777216 true "" ""
"sick-at-home" 1.0 0 -7500403 true "" ""
"sick-at-work" 1.0 0 -2674135 true "" ""

PLOT
1096
291
1878
537
sickness
NIL
NIL
0.0
260.0
0.0
1.0
false
true
"" ""
PENS
"prevalence" 1.0 0 -2674135 true "" ""
"endogenous-incidence" 1.0 0 -1184463 true "" ""
"exogenous-incidence" 1.0 0 -16777216 true "" ""
"immunity" 1.0 0 -10899396 true "" ""

INPUTBOX
281
18
493
78
exogenous-sickness
0.005
1
0
Number

INPUTBOX
281
99
495
159
contagiousness
0.0111
1
0
Number

OUTPUT
525
565
1062
619
13

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
NetLogo 6.4.0
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
