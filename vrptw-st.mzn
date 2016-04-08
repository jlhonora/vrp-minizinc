%------------------------------------------------------------------------------%
% vrptw-st.mzn
% Vehicle routing problem with time windows and service times
% Jose Honorato
% April 2016
% Based on Jakob Puchinger's VRP work
%------------------------------------------------------------------------------%

    % The number of Nodes, Node 0 corresponds to the depot
int: N;
    % Time between the nodes
array[1..N+1, 1..N+1] of int: TravelTimes;
    % Decision variables, is arc ij part of a route?
array[0..N, 0..N] of var 0..1: x;
    % Time windows
array[1..N, 1..2] of int: TimeWindows;
    % Departure times
array[1..N+1] of var int: DepartureTimes;
    % Service times
array[1..N] of int: ServiceTimes;

    % Indegree constraints
constraint
    forall(j in 1..N)(
        sum(i in 0..N)(x[i, j]) = 1
    );

    % Outdegree constraints
constraint
    forall(i in 1..N)(
        sum(j in 0..N)(x[i, j]) = 1
    );

    % Departure time constraints
constraint
    forall(i in 1..N, j in 1..N)(
        DepartureTimes[i] + ServiceTimes[i] + TravelTimes[i, j] - DepartureTimes[j] <= (1 - x[i, j]) * 1000000
    );

    % Time windows constraints
constraint
    forall(i in 1..N)(
        TimeWindows[i, 1] <= DepartureTimes[i]
    );

constraint
    forall(i in 1..N)(
        DepartureTimes[i] <= TimeWindows[i, 2]
    );

var int: objective =
    sum( i in 0..N, j in 0..N ) (TravelTimes[i+1, j+1] * x[i, j]);

solve
    :: int_search(DepartureTimes ++ [x[i, j] | i in 1..N, j in 1..N],
        first_fail, indomain_min, complete)
    minimize objective;

output [
    "x = ", show(x), "\n",
    "objective = ", show(objective),"\n"
];

