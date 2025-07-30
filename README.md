# SURF_2025
Lunar landings, including those in NASA’s Artemis program, must address plume-surface interactions (PSI) where rocket exhaust impinges on lunar regolith during landing and takeoff. This generates high-speed ejecta that can destabilize landers, degrade infrastructure, and threaten orbiting assets. To address these risks, this research advances predictive PSI modeling for rarefied flow in vacuum conditions using a Direct Simulation Monte Carlo (DSMC) solver implemented in OpenFOAM. 

Completed work includes a gas-phase DSMC simulation of a single rocket lander on a flat surface, focused on the plume flow field without particle coupling. This replicates Fontes et al. (2022), who modeled near-field gas flow in a simplified lunar descent scenario. A custom axisymmetric mesh is constructed, and the gas particle velocity distributions are validated against Fontes et al.’s published results. 

A separate outlet boundary temperature sensitivity analysis is conducted through 20 parameterized simulations on ERAU’s HPC, providing velocity, temperature, and density fields across varying thermal boundary conditions.  

The next stage introduces time-resolved one-way coupling, using a regolith particle tracking model that samples DSMC gas fields to simulate transport and impact behavior. This aims to complete the validation process of this study’s DSMC solver through comparison with results published by Fontes et al. (2022). Future work includes implementing a two-way regolith-gas coupling that can be utilized for mission parameters such as lunar landing pad design and surface infrastructure risk assessment. 

This model is intended to be open source, providing validated tools for PSI modeling to support safe, sustainable lunar infrastructure and mission design. 
