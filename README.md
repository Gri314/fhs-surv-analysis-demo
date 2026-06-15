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
The Cox proportional hazards model requires an "observational window". To achieve this, two columns were added: `TotalTime` and `Event`. The simulated window (`maxtime` in code) for this analysis is 10-years, so `TotalTime` is assigned to 10 for all patients who lived longer than 10 years in the study. Patients who experienced the event (death) are coded with `Event` being 1 (not censored), while patients who die after 10 years are coded with `Event` being 0 (not censored). 

### 3. Collapsing the Smoking variable.
The `Smoking_Status` variable presents categorically with several options. To simplify the model for demonstration purposes, this variable was collapsed to a new variable: `Smoking_Ind`, an indicator for whether the patient was considered a smoker or not, with smokers receiving a `1` and non-smokers recieving a `0`. 

### 4. Validations of the semi-parametric Cox model.
The Cox method assumes that each individual observation's hazard funtion is proportional to some unchanging baseline function over time. 


## Model Fit Evaluation

## Executing and Using this Program Yourself
### How-To
### Built-in Flexibility