

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
to become-infected
    ; to set up
end

to become-healthy
    ; to set up
end

to sent-Work_from_home
    ; to set up
end

to sent-back_to_work
    ; to set up
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

to update-status
    ; to set up
end

to start-outbreak
    ; to set up -> this one is for the initial outbreak
end
