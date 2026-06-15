/* ------------- HEADER -------------------------------------------------------------------

 PROGRAM:     rr-surv-heart.sas                                                           
 PURPOSE:     (Academic) Analyze independent hazard ratios of smoking status on mortality 
 DATA SOURCE: sashelp.heart																	
 AUTHOR:      J. Eli Shirley                                                              
 DATE:        June 10th 2026                                                          
 
 -------------- END HEADER ---------------------------------------------------------------- */

/*	=================================================================================
				SECTION 0: DIRECTORY SETUP
	================================================================================= */

/* Setup the working directory for data processing.	*/
%let cwd = /home/u64511502/sasuser.v94/portfolio ; /* change this line to your directory */
libname ws "&cwd./sas-compare-adjusted-risks-cox/workspace";

/*	=================================================================================
				SECTION 1: DATA CLEANING
	================================================================================= */

/* Clean-up the dataset for survival */
data ws.heart_clean;
	set sashelp.heart;
	where AgeAtStart ~= .
		and Cholesterol ~= .
		and Smoking_Status ~= "";
	
	/* Avoid case issues for categorical cols */
	Sex = upcase(Sex);
	BP_Status = upcase(BP_Status);
	Smoking_Status = upcase(Smoking_Status);
	
	/* Determine survival time by simulating observation window */
	/* Right-censoring at `maxtime`, 10 recommended				*/
	%let maxtime = 10;
	if Status = 'Alive' then do;
		TotalYears = &maxtime;
		Event = 0; /* censored */
	end;
	else if Status = 'Dead' then do;
		TotalYears = AgeAtDeath-AgeAtStart;
		if TotalYears > &maxtime then do;
			TotalYears = &maxtime; 
			Event = 0; /* censored */
		end;
		else Event = 1; /* uncensored */
	end;
	
	/* Collapse smoking column into an indicator */
	if Smoking_Status = 'NON-SMOKER' then Smoking_Ind = 0;
	else Smoking_Ind = 1;
	
	/* Drop all unused columns	*/
	keep TotalYears Event Smoking_Ind BP_Status Cholesterol Sex;
	label Smoking_Ind = "Binary Indicator for Being Smoker"
		TotalYears = "Simulated Survival in Years"
		Event = "Binary Indicator for Having Died"
		BP_Status = "Blood Pressure Status"
		Cholesterol = "Standard Cholesterol (mmol/L)"
		Sex = "Standard Binary Indicator for Sex";
run;

/*	===========================================================================
		SECTION 2: VERIFYING PROPORTIONALITY ASSUMPTION
	=========================================================================== */

ODS pdf file="&cwd./sas-compare-adjusted-risks-cox/outputs/report-rr-surv-heart.pdf";

ods graphics on;                    /* Note: Using ods only to suppress lengthy output here */
ods select LogNegLogSurvivalPlot;   /* Comment out all ODS lines to view full report (5000+ lines) */
proc lifetest data=ws.heart_clean plots=loglogs;
	title "Log-Log Survival against Smoking Status";
	time TotalYears*Event(0);
	strata Smoking_Ind;
run; quit;
ods select all;

/*	===========================================================================
		SECTION 3: PROPORTIONAL HAZARDS REGRESSION
	=========================================================================== */

/* Regression results in the output */
proc phreg data=ws.heart_clean;
	title "Proportional Hazards Regression (Cox Method) Results";
	class Sex(ref='FEMALE') BP_Status(ref='NORMAL');
	model TotalYears*Event(0) = Smoking_Ind Cholesterol Sex BP_Status / ties=efron rl;
run; quit;
title;

ODS pdf close;