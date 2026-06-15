* ------------- HEADER --------------------------------------------------------------------	;
* PROGRAM:     rr-surv-heart.sas                                                           	;
* PURPOSE:     (Academic) Analyze independent hazard ratios of smoking status on mortality 	;
* DATA SOURCE: sashelp.heart																;
* AUTHOR:      J. Eli Shirley                                                              	;
* DATE:        June 10th 2026                                                              	;
* -------------- END HEADER ----------------------------------------------------------------;

* Setup the working directory for data processing.	;
%let cwd = /home/u64511502/sasuser.v94/portfolio ; ** change this line to your directory ;
libname ws "&cwd./sas-compare-adjusted-risks-cox/workspace";

* Clean-up the dataset for survival	;
data ws.heart_clean;
	set sashelp.heart;
	where AgeAtStart ~= .
		and Cholesterol ~= .
		and Smoking_Status ~= "";
	
	**Avoid case issues for categorical cols   ;
	Sex = upcase(Sex);
	BP_Status = upcase(BP_Status);
	Smoking_Status = upcase(Smoking_Status);
	
	** Determine survival time by simulating observation window			;
	** Right-censoring at `maxtime`, 10 recommended				;
	%let maxtime = 10;
	if Status = 'Alive' then do;
		TotalYears = &maxtime;
		Event = 0; ** censored;
	end;
	else if Status = 'Dead' then do;
		TotalYears = AgeAtDeath-AgeAtStart;
		if TotalYears > &maxtime then do;
			TotalYears = &maxtime; 
			Event = 0; ** censored		;
		end;
		else Event = 1; ** uncensored	;
	end;
	
	** Collapse smoking column into an indicator	;
	if Smoking_Status = 'NON-SMOKER' then Smoking_Ind = 0;
	else Smoking_Ind = 1;
	
	** Drop all unused columns	;
	keep TotalYears Event Smoking_Ind BP_Status Cholesterol Sex;
	label Smoking_Ind = "Binary Indicator for Being Smoker"
		TotalYears = "Simulated Survival in Years"
		Event = "Binary Indicator for Having Died"
		BP_Status = "Blood Pressure Status"
		Cholesterol = "Standard Cholesterol (mmol/L)"
		Sex = "Standad Binary Indicator for Sex";
run;

** Creating a cumulative distribution plot for assumption checking  ;
data ws.cumulativesTable;
	set ws.heart_clean end=LastObs;
	
	array EventCumul {&maxtime} (&maxtime*0);
	array NonEventCumul {&maxtime} (&maxtime*0);
	
	** Separate the smoker totals and the non-smoker totals to compare groups ; 
	do i=1 to TotalYears;
		if Smoking_Ind=1 then EventCumul{i} = EventCumul{i}+1;
		else NonEventCumul{i} = NonEventCumul{i}+1;
	end;
	
	** Reformat the entire table to be suitable for plotting  ;
	if LastObs then do;
		TempCol1 = EventCumul{1};
		TempCol2 = NonEventCumul{1};
		do i=1 to &maxtime;
			EventCumul{i} = TempCol1-EventCumul{i};
			NonEventCumul{i} = TempCol2-NonEventCumul{i};
		end;
		do i=1 to &maxtime;
			Time = i;
			CumulSmoker = EventCumul{i};
			CumulNonSmoker = NonEventCumul{i};
			output;
		end;
	end;
	
	keep Time CumulSmoker CumulNonSmoker;
	label Time="Time" CumulSmoker="Total Smoker Deaths" CumulNonSmoker="Total Non-Smoker Deaths";
run;

ODS pdf file="&cwd./sas-compare-adjusted-risks-cox/outputs/report-rr-surv-heart.pdf";
** Proportional hazards assumption-checking graph   ;
proc sgplot data=ws.cumulativesTable;
	title "Cumulative Deaths Over Time";
	series x=Time y=CumulSmoker /
		legendlabel="Smoker Deaths" name="smokers";
	series x=Time y=CumulNonSmoker /
		legendlabel="Non-Smoker Deaths" name="nonsmokers";
	keylegend "smokers" "nonsmokers" / 
		down=2
		location=INSIDE position=BOTTOMRIGHT;
	xaxis label="Time (Years)";
	yaxis label="Total Deaths";
run;

** Regression in the output  ;
proc phreg data=ws.heart_clean;
	title "Proportional Hazards Regression (Cox Method) Results";
	class Sex(ref='FEMALE') BP_Status(ref='NORMAL');
	model TotalYears*Event(0) = Smoking_Ind Cholesterol Sex BP_Status / ties=efron rl;
run;
title;
ODS pdf close;