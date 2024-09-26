# Exo_Battery_Dim
Dimensioning of a LFP battery for a 4-DOF Lower Limb Exoskeleton

## Introduction
The purpose of the Matlab simulation was to calculate the capacity and power of the battery. The data base are trajectories for five different modes: Walking, Stairs-up, Stairs-Down, Sit-to-stand, Stand-to-sit.

## Structure
1.	Read in parameters
2.	Extract trajectory data from scientific literature with [DataThief](https://www.datathief.org/)
3.	Read in trajectories (either rpm and torque trajectories or mechanical power torque)
4.	(calculate mechanical power in W/kg)
5.	Get absolute values of mechanical power and add second leg (50% offset for walking, stairs-up and stairs-down)
6.	Calculate efficiency for motor based on rpm vs. efficiency over cycle (see plots)
7.	Calculate electrical power for each mode
8.	Outputs: Average power based on load collective, Max. current based on peak power, Capacity based on average power and running time

## Contact 
Reach out to hassel@campus.tu-berlin.de 
