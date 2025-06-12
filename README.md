# Dynamic-Modular-Framework-for-Predicting-Water-System-Performance

This repository contains the code of the Bachelor final project, aiming to create a model that can predict the performance of water systems.
This is done in an effort to help create sustainalbe water systems for the future.

To run a simulation, first run the selecting data script, inside of the harvester folder, to load the weather data.
Next open the simulink simulation you want to run, and run it for max 365x24 hours. Ensure solver is set to ODE1 and step time below 0.5.
When done, run the model output analyzer script which will process all the model output data.
