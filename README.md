# Exo_Battery_Dim
Dimensioning of a LFP battery for a 3-DOF Lower Limb Exoskeleton

## Introduction
The purpose of the Matlab simulation was to calculate the capacity and power of the battery. The data base are trajectories for five different modes: Walking, Stairs-up, Stairs-Down, Sit-to-stand, Stand-to-sit.

## Structure
1.	Import parameters
2.	Extract trajectory data from scientific literature with [DataThief](https://www.datathief.org/)
3.	Import trajectories (either rpm and torque trajectories or mechanical power)
4.	If rpm and torque imported: calculate mechanical power in W/kg
5.	Get absolute values of mechanical power and add second leg (50% offset for walking, stairs-up and stairs-down)
6.	Calculate efficiency for motor based on rpm vs. efficiency over cycle (see plots)
7.	Calculate electrical power for each mode
8.	Outputs: Average power based on load collective, max. current based on peak power, capacity based on average power and running time

## Contact 
Reach out to hassel@campus.tu-berlin.de 
