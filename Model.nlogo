globals [number-of-ticks-per-day productivity team-colors x-coordinates y-coordinates]

;; Types of agents
breed [absentees absentee] ;; Miss work when sick (if allowed)
breed [presentees presentee] ;; Work when sick

;; Agent properties
turtles-own [effective-recovery-days immune infected infections out sick sick-leave-days team work]

to setup
  clear-all

  ;; Set number of ticks per day
  set number-of-ticks-per-day 4 ;; Since contagiousness of cold is estimated for 2 hours (see Info tab), assume two-hour rhythm

  ;; Empty list for final outcome
  set productivity []

  ;; Assign colors to teams
  set team-colors [yellow orange pink violet blue sky turquoise green brown]

  ;; Assign patches to teams
  set x-coordinates [1 2 3 1 2 3 1 2 3]
  set y-coordinates [3 3 3 2 2 2 1 1 1]

  ;; Color patches
  ask patches [
    set pcolor 9
  ]

  ask patch 1 3 [
    set pcolor 49
  ]
  ask patch 2 3 [
    set pcolor (ifelse-value
      number-of-teams >= 2 [29]
      [black])
  ]
  ask patch 3 3 [
    set pcolor (ifelse-value
      number-of-teams >= 3 [139]
      [black])
  ]
  ask patch 1 2 [
    set pcolor (ifelse-value
      number-of-teams >= 4 [119]
      [black])
  ]
  ask patch 2 2 [
    set pcolor (ifelse-value
      number-of-teams >= 5 [109]
      [black])
  ]
  ask patch 3 2 [
    set pcolor (ifelse-value
      number-of-teams >= 6 [99]
      [black])
  ]
  ask patch 1 1 [
    set pcolor (ifelse-value
      number-of-teams >= 7 [79]
      [black])
  ]
  ask patch 2 1 [
    set pcolor (ifelse-value
      number-of-teams >= 8 [59]
      [black])
  ]
  ask patch 3 1 [
    set pcolor (ifelse-value
      number-of-teams >= 9 [39]
      [black])
  ]

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
  if ticks mod number-of-ticks-per-day = 0 and ticks != 0 [ ;; First tick of day
    ;; Decide what to do today
    ask absentees [
      ;; If infected yesterday
      ifelse infected [
        ;; Sick today
        set sick true
        set infected false ;; Should be true if and only if infected today
        set infections infections + 1 ;; Count infections since beginning of year

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
        set infections infections + 1 ;; Count infections since beginning of year

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

  if ticks mod number-of-ticks-per-day != 0 and (ticks + 1) mod number-of-ticks-per-day != 0 [ ;; Intermediate ticks of day
    ;; Randomly infect workers, based on contagiousness and number of sick workers on patches
    infect

    ;; If there are multiple teams, move workers
    if number-of-teams > 1 [
      move
    ]
  ]

  if (ticks + 1) mod number-of-ticks-per-day = 0 [ ;; Last tick of day
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

  ;; Simulate year
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
200.0
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
0.51
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
0.67
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
5.0
1
0
Number

INPUTBOX
17
477
494
537
max-sick-leave-days
260.0
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
0.3
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
65.0
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
0.40
0.3
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
0.0
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
0.0
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
0.003
1
0
Number

INPUTBOX
281
99
495
159
contagiousness
0.09
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
# WHAT IS IT?

The key objective of our model is analyse the relationship between sick leave policy and office productivity while capturing emergent dynamics that can only be captured through an agent-based modelling approach At its core, the approach consists in assuming a distribution of workers between two types: (i) presentees – worker that stay at work while being sick and (ii) absentees – workers that use there sick leaves.

## Phenomenon: Presenteeism vs. Absenteeism

At its core, our model seeks to illustrate the inherent tension in sick leave policies between maintaining productivity and preventing the spread of disease.

On the one hand, absenteeism leads to significant productivity losses during sick leave. In our model, workers on sick leave are assumed to be completely unproductive. On the other hand, presenteeism affects productivity because employees work at a reduced capacity and also spread illness to their colleagues.

Recognising that organisations are complex social systems in which team-based interactions can give rise to emergent behaviours, our model aims to address the limitations of traditional approaches that analyse the relationship between sick-leave policies and productivity only at an aggregate level. By adopting a bottom-up, agent-based modelling approach, our model captures the nuanced dynamics and emergent patterns that arise from individual behaviours, team structures and disease transmission processes within the workplace.

## Research Question 

This model attempts to evaluate and explain the trade-offs faced by managers in determining the maximum number of sick days allowed to employees. More specifically, it attempts to answer the following two research questions:

>
  1. What is the relationship between the maximum number of sick leave days and productivity?
  2. Should firm owners rather forbid employees to work in the office when they are sick?
>

While the first question is a positivist one, then end aim is to provide a model that enable to consider different illness and their resulting normative insight(s).

## Hypothesis

## Key assumptions & associated limitations
>
- Workers are evenly distributed across teams at start.
- There are two types of workers: absent and present. The population is therefore heterogeneous only to this extent.
- The population is initially healthy (but no one is immune).
- The conditional probability of infection is (effectively) a binomial distribution.
- The working population is exposed to a constant exogenous infection rate.
- The productivity losses associated with sickness, conditional on type, are constant and deterministic.  
- The probability of leaving a team once during a day is (effectively) a binomial distribution. Movements between teams are random, so there is an equal probability of moving to a particular team if a worker leaves his own team. 
>

These assumptions exclude certain facets of the phenomenon:

- There are no seasonal patterns of exogenous infection exposure. 
- Heterogeneity of the worker population beyond the absentee/presentee dichotomy.
- The population is only exposed to a single infectious disease. By extension, this also excludes any form of interaction with additional diseases.
- Productivity losses result only from the productivity loss of being ill at work or being ill at home. There is no interaction within the team of being ill at home on the team's productivity. I.e. there is no burn-out and overwork effect due to the illness of team members.

# HOW IT WORKS

## Overiew

![logic_map](file:logic_map.png) 


### Initialisation

At the start the model is initialised. As mentionned under the **Key Assumption** section, the model parameterisation and initialisation assumes a no immunity and sickness as the starting condition. The default parameters are defined under the **HOW TO USE IT** section with explanation of our model calibration choices. We also invite you to look at the **EXPERIMENTS** to replicate our own experiements.

### Process

The model has a unique features that is introduces two temporal layer. 

	1. Tick-base time: at each tick i.e. the model's time increament, a sequence of functions are activiated.
2. Day counts: The model time convention is that a day is 4 ticks and the model runs up to 260 days, which represents a year of work days. Moreover, certain functions are only activated at specific time of the days.

The process is illustrated in the pseudo code below

![pseudo_code](file:pseudo_code.png)


### Stopping Condition

The model automatically stops when the day count reach 260, which is the set number for the number of work day in a year. The rational of the stopping condition is that the model is used to be measures on a standardised time span. 










## HOW TO USE IT

Click on the SETUP button to initialize the model.

Click on the GO button to run the model. The clock will advance until you press the button again or 1 year is simulated (260 working days).

The NUMBER-OF-WORKERS input (integer) controls the size of the office. We calibrated the model with 200 workers (as a compromise between smoothness of the plots and computational complexity), but any other value is possible.

The NUMBER-OF-TEAMS slider controls the number and therefore the size of teams. It should be noted that every team is equally large in expectation. We calibrated the model with 5 teams (simply the middle).

The MOVEMENT-ACROSS-TEAMS slider controls the share of workers who are not in their own teams in the second, third, and fourth ticks of a day (everybody starts the day in their own team). A worker interacts 3 * MOVEMENT-ACROSS-TEAMS with other teams in expectation (out of four interactions) and the probability that a worker interacts only with their own team is (1 - MOVEMENT-ACROSS-TEAMS)<sup>3</sup> a day. We calibrated the model with 0.3.

The SHARE-OF-PRESENTEES slider controls the share of workers who work when they are sick. We microcalibrated the share of presentees to 0.51, which is an estimate for Switzerland (Grebner et al., 2010, p. 81). However, many other values are realistic: Estimates range from 0.30 (Sweden) to 0.80 (US) (Blanchet Zumhofen et al., 2022, p. 254; Henneberger & Gämperli, 2014, pp. 13–14). You can even choose 0, which simulates the sick leave policy of forbidding workers to work when they are sick.

The EXOGENOUS-SICKNESS input (double) controls the probability of catching a cold after work (independent of the prevalence). Since everybody is healthy at the beginning (and possibly again later), EXOGENOUS-SICKNESS should be strictly larger than 0. Otherwise, the results are trivial. Since infections after work are not entirely explained by the model, we calibrated the model with a very small value (0.003).

The CONTAGIOUSNESS input (double) controls how contagious the illness is. More specifically, CONTAGIOUSNESS is the probability of infection for a healthy and vulnerable worker if one sick worker is in the same team. If there are more, the probability increases concavely. We microcalibrated the contagiousness to 0.09, which is the only available estimate for the cold (Lovelock et al., 1952, as cited in Andrup et al., 2023, p. 946).

The SEVERITY slider controls how productive sick workers are. While healthy workers produce 1, sick workers produce 1 - SEVERITY a day. We microcalibrated the severity to 0.3, which is an estimate specifically for the cold (Blanchet Zumhofen et al., 2022, p. 260). A more general study shows that values up to 0.4 are realistic (Kramer et al., 2013, p. 6).

The RECOVERY-DAYS input (integer) controls how many days a sick worker needs to recover at home. We microcalibrated the recovery days to 5, which is the lower bound of the average duration of colds for adults (Pappas, 2017, p. 200). It should be noted that the model excludes weekends, so 5 days in the model correspond to 7 days in reality, which is the upper bound of the average duration of colds for adults.

The SLOWER-RECOVERY slider controls how strongly presenteeism slows recovery. More specifically, RECOVERY-DAYS / SLOWER-RECOVERY is how many days a presentee needs to recover. We microcalibrated SLOWER-RECOVERY to 0.67, which results in 8 recovery days. On the one hand, it is now well established from a variety of studies that presenteeism slows recovery (Henneberger & Gämperli, 2014, p. 27). On the other hand, 10 days are still a common duration of colds for adults (remember that the model excludes weekends). For example, the NHS recommends seeing a doctor only then (2024).

The IMMUNITY-DAYS input (integer) controls how many days a recovered worker is fully protected from sickness. We macrocalibrated the immunity days to 65. As a result, workers are sick 3 times on average, which is what empirical data indicates (Pappas, 2017, p. 200).

Importantly, while we focus on the cold, any illness can be simulated by changing CONTAGIOUSNESS, SEVERITY, RECOVERY-DAYS, SLOWER-RECOVERY, and IMMUNITY-DAYS accordingly.

The MAX-SICK-LEAVE-DAYS input (integer) controls how many days workers are allowed to miss work a year. We calibrated the model with the sick leave policy of no maximum (MAX-SICK-LEAVE-DAYS = 260), which is legally enforced in Switzerland (approximately), in order to be consistent with the share of presentees.











# MODEL SENSITIVTIY

After the calibration process, we have analysed the sensitivity of the model to all parameters. The top three most sensitive parameters are the following:

	1. NUMBER-OF-WORKERS:
_We tested the range from 100 to 2000 thereby encompassing medium to larger size companies. As the number of workers increases, the mean productivity of the turtles declines significantly during a wave of the common cold. A larger workforce leads to a higher frequency of infections per employee each year, which in turn amplifies the spread of illness. Consequently, average office productivity becomes highly sensitive to the size of the employee base. Furthermore, illness spikes occur within a narrower range of ticks as the employee count rises, indicating a more concentrated and rapid spread of infections in larger groups._

  2. RECOVERY-DAYS
_This range has been tested on the understanding that colds are typically resolved within a period of no longer than two weeks, namely from 1 to 15 days. An extended recovery period results in the prolongation of illness waves, which in turn gives rise to a greater incidence of severe productivity losses. This is consistent with the premise that the greater the severity of the illness, the greater the impact on office productivity. Furthermore, extended recovery periods limit the number of illness waves that can occur within a given period of time._


# EXPERIMENTS



**Experiment A. Large vs Small Companies**
You can replicate experiment A by changing XX to XX. As you can observe

**Experiment B. Changing Share of Presentees**
XXX

** Experiment C. Changing the Movement Across Teams**
XXX


# RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

The model is related to two models indirectly. 

**Virus on a Network model** 
(Stonedahl, F. and Wilensky, U., 2008)

In the first phase of the modelling, we explored the possibility of relying on its network-based approach to virus propagation as the workhorse model. At the time, we identified the following advantages and shortcomings:

**Advantages**:
  a. Ready-made base model.
  b. Easy to scale the number of teams and workers.

**Disadvantages**: 
  a. The office space is harder to interpret.
  b. The randomisation of the network structure limited replicability of each experiment.
  c. Hard to add additional phenomenon on top of the existing structure.
  d. Difficult to isolate the source of complexity and understand how the adds-on would change the behaviour of the model.

**El Farol Model**
(Rand, W. & Wilensky, U., 2007) 

We also inspired ourself from the El Farol Model primarily for the use of space in the characterisation of the office space compartimentalisation of team interactions. In the first version of the model, we identified that the use of a "Room-based Partitioning" had the following advantages and shortcomings:

**Advantages**:
  a. Easy visualisation.
  b. Leverages better the NetLogo interface.

**Disadvantages**: 
  a. Could not be used as a workhorse model
  b. Purely batch-based spatial model limit scaling possibilities.
  c. Drastically different in its logic structure than the phenomenon our model aim to study. 

Therefore, the current version of the model inspired itself from the use of spatial visualisation of the teams while allowing greater flexibility in terms of the scaling of the model by defining the team variable as an turtle attribute directly rather than on the spatial one.

## Our Model's Noteworthy Features

**Day count**
The model dual day and tick count allow to model action at different intraday frequencies.

An example is of this day of time specific activation function is illustrated below:

```
if ticks mod number-of-ticks-per-day = 0 and ticks != 0 [ 
;; First tick of day
…
]
```
**Binomial Infection Probability Distribution**
This allow us to make depend the infection spread incidence to the number of sick 


```
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
```
`
**3. XXX**

# Extending the Model

1. Unjustified absenteeism
2. Forward looking anticipation of sick days decision
3. Work distribution within teams with burnout dynamics
4. Remote work

# CREDITS AND REFERENCES

## Related Models
Stonedahl, F. and Wilensky, U. (2008). Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Rand, W. & Wilensky, U. (2007). El Farol Model. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

 
## Bibliography 


Van Wormer, J. J., King, J. P., Gajewski, A., McLean, H. Q., & Belongia, E. A. (2017). Influenza and workplace productivity loss in working adults. Journal of Occupational and Environmental Medicine, 59(12), 1135–1139. https://doi.org/10.1097/JOM.0000000000001120

Daniels, S., Wei, H., Han, Y., et al. (2021). Risk factors associated with respiratory infectious disease-related presenteeism: A rapid review. BMC Public Health, 21, 1955. https://doi.org/10.1186/s12889-021-12008-9

Blanchet Zumofen, M. H., Frimpter, J., & Hansen, S. A. (2023). Impact of influenza and influenza-like illness on work productivity outcomes: A systematic literature review. PharmacoEconomics, 41(3), 253–273. https://doi.org/10.1007/s40273-022-01224-9

U.S. Department of Labor. (n.d.). Sick leave. Retrieved from https://www.dol.gov/general/topic/workhours/sickleave

Swiss Confederation. (n.d.). Inability to work and sick leave. Retrieved from https://www.kmu.admin.ch/kmu/en/home/concrete-know-how/personnel/employment-law/working-hours/inability-work-sick-leave.html

Heymann, J., Rho, H. J., Schmitt, J., & Earle, A. (2010). Ensuring a healthy and productive workforce: Comparing the generosity of paid sick day and sick leave policies in 22 countries. International Journal of Health Services, 40(1), 1–22. https://doi.org/10.2190/HS.40.1.a

Turner, R. B. (2012). The common cold. Goldman’s Cecil Medicine, 2089–2091. https://doi.org/10.1016/B978-1-4377-1604-7.00369-9

Kirkpatrick, G. L. (1996). The common cold. Primary Care: Clinics in Office Practice, 23(4), 657–675. https://doi.org/10.1016/S0095-4543(05)70355-9

Andrup, L., et al. (2023). Transmission route of rhinovirus - the causative agent for common cold: A systematic review. American Journal of Infection Control, 51(8), 938–957. https://doi.org/10.1016/j.ajic.2023.04.005

Blanchet Zumofen, M. H., Frimpter, J., & Hansen, S. A. (2023). Impact of influenza and influenza-like illness on work productivity outcomes: A systematic literature review. PharmacoEconomics, 41(3), 253–273. https://doi.org/10.1007/s40273-022-01224-9

Fauceglia, D. (n.d.). Absentismus in der Schweiz: Eine empirische Analyse [Master’s thesis, Universität St. Gallen]. Referent: PD Dr. Alfonso Sousa-Poza.

Grebner, S., Berlowitz, I., Alvarado, V., & Cassina, M. (n.d.). Stress bei Schweizer Erwerbstätigen. SECO | Arbeitsbedingungen.

Henneberger, F., & Gämperli, M. (2014). Präsentismus: Ein kurzer Überblick über die ökonomische Relevanz eines verbreiteten Phänomens. Diskussionspapiere des Forschungsinstituts für Arbeit und Arbeitsrecht an der Universität St. Gallen, (129).

Jacobshagen, N. (2020). Was Führung mit Präsentismus zu tun hat. Seminar WOTD, HS 2020, Termin 6 – 24.06.2020. Universität Bern.

Kopp, N. (2024). Fiebrig und fröstelnd vor dem Bildschirm. Warum tun wir uns das an? NZZ.

Kramer, F., Gämperli, M., & Henneberger, F. (2013). Präsentismus: Verlust von Gesundheit und Produktivität. IGA-Fakten, Nr. 6. Initiative Gesundheit und Arbeit (IGA). Retrieved from http://www.iga-info.de

Pappas, D. E. (2017). The common cold. In J. E. Bennett, R. Dolin, & M. J. Blaser (Eds.), Mandell, Douglas, and Bennett's principles and practice of infectious diseases (8th ed., pp. 199–202). Elsevier.


________

![sensitivity](file:Sensitivity_Tests.png)
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
<experiments>
  <experiment name="calibration" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - teams" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-teams" first="1" step="1" last="9"/>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - workers" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <steppedValueSet variable="number-of-workers" first="100" step="100" last="2000"/>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - movement-across-teams" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="movement-across-teams" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - share-of-presentees" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="share-of-presentees" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - exogenous-sickness" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <steppedValueSet variable="exogenous-sickness" first="0.001" step="0.001" last="0.01"/>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - contagiousness" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <steppedValueSet variable="contagiousness" first="0.01" step="0.01" last="0.99"/>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - severity" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <steppedValueSet variable="severity" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - recovery-days" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="recovery-days" first="1" step="1" last="14"/>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - slower-recovery" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="slower-recovery" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - immunity-days" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <steppedValueSet variable="immunity-days" first="5" step="5" last="260"/>
    <enumeratedValueSet variable="max-sick-leave-days">
      <value value="260"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity test - max-sick-leave-days" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [infections] of turtles</metric>
    <metric>mean [infections] of absentees</metric>
    <metric>mean [infections] of presentees</metric>
    <metric>mean-productivity absentees</metric>
    <metric>mean-productivity presentees</metric>
    <metric>mean-productivity turtles</metric>
    <metric>count turtles with [infected = True]</metric>
    <metric>count turtles with [sick = True]</metric>
    <metric>count turtles with [immune &gt; 0]</metric>
    <runMetricsCondition>(ticks + 1) mod number-of-ticks-per-day = 0</runMetricsCondition>
    <enumeratedValueSet variable="number-of-workers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-teams">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-across-teams">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share-of-presentees">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exogenous-sickness">
      <value value="0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contagiousness">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="severity">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery-days">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slower-recovery">
      <value value="0.67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immunity-days">
      <value value="65"/>
    </enumeratedValueSet>
    <steppedValueSet variable="max-sick-leave-days" first="0" step="5" last="260"/>
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
0
@#$#@#$#@
