# FYP478 - Data Reconciliation & Gross Error Detection
This is the repository for my Final Year Project. This read me file explains how to navigate through the repository.

***1. main_system == Model of binary distillation column***  
% This script simulates a benzene/toulene binary distillation column. It generates data that is used to test linear & non-linear data reconciliation.  
% main_systen uses the following functions:
- simulate_ODEs  >> Function that solves the ODEs of the model
- intermediaries >> Function that solves all the intermediary variables of the model
- measureReal    >> 'Measures' the data generated by the model

***2. linearDR_redundancy == Redundancy analysis***  
% This script performs linear data reconciliation for different amounts of available measurements.  
% It evaluates the following:  
% >> Effectiveness of linear DR  
% >> Effect of decreasing available measurements  
% linearDR_redundancy uses the following functions:
- measureReal    >> 'Measures' the data generated by the model
- generateLB     >> Perforns linear DR for given measurements
- varianceMatrix >> Generates the variance matrix

***3. linearDR_variance == Variance analysis***  
% This script performs linear data reconciliation for different variances.  
% It evaluates the following:  
% >> Effectiveness of linear DR with increasing variance  
% linearDR_redundancy uses the following functions:  
- measureReal    >> 'Measures' the data generated by the model
- varianceMatrix >> Generates the variance matrix

***4. nonLinearDR_redundancy == Redundancy analysis***  
% This script performs non-linear data reconciliation for different amounts of available measurements.  
% It evaluates the following:   
% >> Effectiveness of non-linear DR  
% >> Effect of decreasing available measurements  
% linearDR_redundancy uses the following functions:
- measureReal    >> 'Measures' the data generated by the model
- generateLB     >> Refines the measurement matrix
- varianceMatrix >> Generates the variance matrix

***5. nonLinearDR_variance == Variance analysis***  
% This script performs non-linear data reconciliation for different variances.  
% It evaluates the following:  
% >> Effectiveness of non-linear DR with increasing variance  
% linearDR_redundancy uses the following functions:  
- measureReal    >> 'Measures' the data generated by the model
- varianceMatrix >> Generates the variance matrix

***6. GED == Confidence Interval analysis*** 
% This script performs GED with the global test method for the linear case. 
% It evaluates the effect of the confidence interval on the following: 
% >> Specificity & sensitvity

***7. GED_nonLinear == Confidence Interval analysis*** 
% This script performs GED with the global test method for the non-linear case.
% It evaluates the effect of the confidence interval on the following: 
% >> Specificity & sensitvity
