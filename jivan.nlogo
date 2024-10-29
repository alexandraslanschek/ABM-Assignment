

; General commentary:
; 1. The idea is to create a random network influenced by the team attribution and having the link
;    representing the interactions between the agents.
; 2. The agents are divided into two groups: high-tolerance and low-tolerance agents.
; 3. The agents are divided into teams.
; 4. The agents are distributed randomly in the network. Though we will need to ensure this attribution is impacted by the team attribute.


; The process of the code per tick should look like:
; 1. The agents are checked for infection, work from home, and other attributes.
; 2. The agents links are randomly removed or added based on the team attribute.
; 3. The agents interact with each other based on the links. I suggest applying a first order proximity.
; 4. The agents status are updated.



; set up globals
globals [team-assignments team-colors]

turtles-own 
[
    team; team attribution
    infected? ; infected status
    home? ; work from home status
    ticks-since-infection ; time since infection, its a counter
    tolerance; the tolerance of the agent. I prefer to use it as a status of a turtle rather than as a breed.
]


; Set up the initial conditions
to setup
    clear-all

    set team-assignments n-values number-of-teams [random number-of-teams] 
    setup-nodes ; set up the nodes
    setup-links ; set up the links
    start-outbreak ; initial "shock" to the system

    reset-ticks 
end

to go
    ; to set up
end

; Change of status function

to spread-virus ; thsi function is replicated from the virus model
  ask turtles with [infected?]
    [ ask link-neighbors with [not home?] ; we can add also immunity here. No spread if at home.
        ; to calibrate the spread of the virus
        [ if tolerance == 1 ; this is the high tolerance group
            [ if random-float 1 < high-spread-chance; <- this is the chance of spreading the virus. we must introduce the tolerance here
                [ become-infected ] ] ]
        [ elif tolerance == 2 ; this is the low tolerance group
            [ if random-float 1 < low-spread-chance; 
                [ become-infected ] ] ]         
end

to get-better
    ask turtles with [infected?]
    [ if ticks-since-infection > recovery-time ; this is as a hard constraint. We can also add a probability of recovery.
        [ become-healthy ] ]
    [ elif random-float 100 < recovery-chance; <- this is the chance of recovery. we can create a
        [ become-healthy ] ]
end

to become-infected
    set infected? true
    set color red ; Initially for visual inspection
    ; add infected ticks counter?
end

to become-healthy
    set infected? false
    set color white 
end

to sent-Work_from_home
    set home? true
    set color grey 
end

to sent-back_to_work
    set home? false
    set color blue
end

; Set up the network

to setup-nodes
    ; to set up
end

to setup-links
    ; to set up -> here is where we need to use the teams for changing the impact of the teams attributes on to their interactions.
    ; the 
end

to update-links
    ; to set up
end

to distrute-tolerance
    set tolerance random 2 + 1 ; this is a random number between 1 and 2
end



to start-outbreak
    ask n-of initial-infections turtles ; this is replicated from the virus model
    [ become-infected ]
end
