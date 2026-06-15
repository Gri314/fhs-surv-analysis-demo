# 10-Year Smoking Mortality Risks: A Cox Proportional Hazards Analysis
## Overview
This repository contains an independent data-cleaning and analysis for an investigation into the long-term effects of smoking on mortality. Using the observational cohort from the *Framingham Heart Study* (`sashelp.heart`), we build a simple, semi-parametric survival model with the goal of finding hazard ratios for smoking -- whilst adjusting for the critical confounders: sex, cholesterol, and blood pressure. 

This project serves as a self-contained portfolio piece demonstrating advanced programming, data manipulation, censoring configuration, and regression matrix interpretation. 

## Dataset Characteristics and Summary
- Source: `sashelp.heart`: Framingham Heart Study. [Link to their website](https://www.framinghamheartstudy.org).
- Type: Longitudinal observational study with continued admittance.
- Samle Size (N = 5049): Incomplete observations were omitted for a complete-case analysis. 
- Event: Mortality (`Status = 'Dead'`).
- Time-scale: Measured continuous years elapsed since enrollment. 

## Methodology
### 1. Complete-case analysis & data cleansing.
To help ensure model convergence, all observations with missing/null covariate vector elements were omitted, leaving N=5049 obsevations from the original dataset's 5209 observations. All categorical variables were recasted to uppercase for in-code validation. 

### 2. The simulation of an observation window.
The Cox proportional hazards model requires an "observational window". To achieve this, two columns were added: `TotalYears` and `Event`. The simulated window (`maxtime` in code) for this analysis is 10-years, so `TotalYears` is assigned to 10 for all patients who lived longer than 10 years in the study. Patients who experienced the event (death) are coded with `Event` being 1 (not censored), while patients who die after 10 years are coded with `Event` being 0 (not censored). 

### 3. Collapsing the Smoking variable.
The `Smoking_Status` variable presents categorically with several options. To simplify the model for demonstration purposes, this variable was collapsed to a new variable: `Smoking_Ind`, an indicator for whether the patient was considered a smoker or not, with smokers receiving a `1` and non-smokers recieving a `0`. This indicator will act as the bifurcating "treatment" variable for the comparison. 

### 4. Validations of the semi-parametric Cox model.
The Cox method assumes that each individual observation's hazard funtion is proportional to some unchanging baseline function over time. To verify this, the `lifetest` procedure is implemented. 

## Model Fit Evaluation
The covariate matrix drastically minimized thresholds for badness-of-fit relative to the intercept-only configuration. This means the model is robust. For example (included in the report): the log likelihood decreased from 3640.375 (intercept only) to 3534.681 (covariates included). 

## Executing and Using this Program Yourself
Since SAS is a proprietary software, the user wishing to replicate these results or run this code themselves must be eligable for SAS OnDemand for Academics [link](https://www.sas.com/en_us/software/on-demand-for-academics.html). Please note that the program is **not universal** and requires slight adjustments in-code to run on a given user's machine. 

### How-To
1. Simply download the file (the dataset is local to most SAS installations) or clone this repo to your machine. 

2. In the SAS file `rr-surv-heart.sas`, locate and edit the line just underneath the header (line 16). After `%let cwd = ` alter the entire path to match your directory. Ensure the path is changed to the *master folder* containing the same strucutre as the Github repo. In SAS Studio, you can do this by right-clicking the folder and selecting "Properties", then copying the location. 

3. If the local directory is set up the same way (folders called `output`, `programs`, and `workspace`), the program should execute correctly. 

### Built-in Flexibility
This program features one macro titles `maxtime` which is found on line 37: `%let maxtime = 10;`. By changing this number, the user can perform their own simulation at a different length and reproduce the results for a different time frame. For example, changing `maxtime` to 20 will alter the entire report (including the assumption testing). 

Note that this functionality is intended only for the user's personal curiosity -- and the statistical validity of the study depends widly upon the simulated window (`maxtime`). If the window is too short, then the effects of smoking may not take hold, whereas a window that is too long allows for covariate factors to build influence and must be re-evaluated. 