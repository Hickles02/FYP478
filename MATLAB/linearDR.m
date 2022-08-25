%% Linear Data Reconciliation
% This main function loads the true data generated by simulating the model of
% the binary distillation column. It then artificially corrupts the true
% data (using measureReal) and performs linear data reconciliation on the corrupted
% 'measurements', for both AVM & SVM. Lastly, it evaluates the effectiveness of linear DR.

% Key:
% AVM - All Variables Measured 
% SVM - Some Variables Measured
% MAPE - Mean Absolute Percentage Error

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data
variance = 0.05;
[measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance);

%% Setting up Matrices
% Measurement matrix - Matrix with all variables measured
measurements = [measured_data.L1; measured_data.L2; measured_data.L3; measured_data.L4; measured_data.LB;...
                measured_data.LD; measured_data.LR; measured_data.V0; measured_data.V1;...
                measured_data.V2; measured_data.V3; measured_data.V4; measured_data.LF];
                   
% Variance Matrix
W = varianceMatrix(13, variance);

% The A matrix
% The System of Equations
% 1. L1 - LB - V0           = 0
% 2. L2 - L1 + V0 - V1      = 0
% 3. L3 + LF - L2 + V1 - V2 = 0
% 4. L4 - L3 + V2 - V3      = 0
% 5. LR - L4 + V3 - V4      = 0
% 6. V4 - LR - LD           = 0
% 7. LF - LD - LB           = 0

%    L1 L2 L3 L4 LB LD LR V0 V1 V2 V3 V4 LF
A = [+1 +0 +0 +0 -1 +0 +0 -1 +0 +0 +0 +0 +0;...
     -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +0 +0;... 
     +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0 +1;... 
     +0 +0 -1 +1 +0 +0 +0 +0 +0 +1 -1 +0 +0;... 
     +0 +0 +0 -1 +0 +0 +1 +0 +0 +0 +1 -1 +0;... 
     +0 +0 +0 +0 +0 -1 -1 +0 +0 +0 +0 +1 +0];
 
%% Linear DR - AVM 
xhat = measurements - (W\A')*((A*(W\A'))\(A*measurements));
LB_avm = xhat(5,:);

%% Linear DR - SVM
% The generateLB_svm function generates the reconciled estimates of LB,
% based on the number of unmeasured variables
LB_svm = zeros(4,1001);
for i = 1:4
   LB_svm(i,:) = generateLB_svm(i, measured_data, variance);
end

%% Error metrics
% MAPE - Mean Absolute Percentage Error
mapeM    = mean(100*abs((true_data.LB(:,100:end) - measured_data.LB(:,100:end))./true_data.LB(:,100:end))); %mean((true_data.LB - measured_data.LB).^2);
mape_avm = mean(100*abs((true_data.LB(:,100:end) - LB_avm(:,100:end))./true_data.LB(:,100:end))); %mean((true_data.LB - LB_avm).^2);
mape_svm = zeros(4,1);
for i = 1:4
    mape_svm(i,1) = mean(100*abs((true_data.LB(:,100:end) - LB_svm(i,100:end))./true_data.LB(:,100:end))); %mean((true_data.LB - LB_svm(i,:)).^2);
end

% res - Residules
resM = true_data.LB - measured_data.LB;
res_avm = true_data.LB - LB_avm;
res_svm = zeros(4,1001);
for i = 1:4
    res_svm(i,:) = true_data.LB - LB_svm(i,:);
end

% Density functions
[fm, xim] = ksdensity(resM(:,100:end))
[favm, xiavm] = ksdensity(res_avm(:,100:end))
fsvm = zeros(1,100); xisvm = zeros(1,100);
for i = 1:4
    [fsvm(i,:), xisvm(i,:)] = ksdensity(res_svm(i,100:end));
end

%% Display results
% Choose type of display
% Line graph               >> disp = 1
% Histogram                >> disp = 2
% Probability distribution >> disp = 3
disp = 3;

% Plot results - Line Graph
if disp == 1
    subplot(5,1,1)
    plot(time(100:end,:), true_data.LB(:,100:end), 'co', time(100:end,:), measured_data.LB(:,100:end), 'y', time(100:end,:), LB_avm(:,100:end), 'k')
    title("All Variables Measured")
    xlabel('Time (s)'); ylabel('LB');
    legend('Model', "Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_avm)+"%", 'Location', 'bestoutside')

    for i = 1:4
        subplot(5,1,i+1)
        plot(time(100:end,:), true_data.LB(:,100:end), 'co', time(100:end,:), measured_data.LB(:,100:end), 'y', time(100:end,:), LB_svm(i,100:end), 'k')
        title("Some Variables Measured: No. Unmeasured = "+num2str(i))
        xlabel('Time (s)'); ylabel('LB');
        legend('Model', "Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_svm(i,1))+"%", 'Location', 'bestoutside')
    end
    sgtitle("Measurements vs the reconciled values")
    
% Plot results - Histogram
elseif disp == 2
    subplot(5,1,1)
    histogram(resM(:,100:end),50,'FaceAlpha',0.1)
    hold on
    histogram(res_avm(:,100:end),50,'FaceAlpha',1)
    hold off
    title("All Variables Measured")
    xlabel('Time (s)'); ylabel('LB');
    legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_avm)+"%", 'Location', 'Best')
    for i = 1:4
        subplot(5,1,i+1)
        histogram(resM(:,100:end),50,'FaceAlpha',0.1)
        hold on
        histogram(res_svm(i,100:end),50,'FaceAlpha',1)
        hold off
        if i == 1
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> L1")
        elseif i == 2
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> L1 & V4")
        elseif i == 3
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> LF, V4 & L2")
        elseif i == 4
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> LF, V4, L2 & V3")
        end        
        xlabel('Time (s)'); ylabel('LB');
        legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_svm(i))+"%", 'Location', 'Best')
    end
    sgtitle("Histograms of the residuals for the measurements & the reconciled values")
end

% Plot results - Density Function
if disp == 3
    subplot(5,1,1)
    plot(xim, fm, 'y', xiavm, favm, 'b')
    title("All Variables Measured")
    xlabel('Time (s)'); ylabel('LB');
    legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_avm)+"%", 'Location', 'Best')
    for i = 1:4
        subplot(5,1,i+1)
        plot(xim, fm, 'y', xisvm(i,:), fsvm(i,:), 'b')
        if i == 1
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> L1")
        elseif i == 2
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> L1 & V4")
        elseif i == 3
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> LF, V4 & L2")
        elseif i == 4
            title("Some Variables Measured: No. Unmeasured = "+num2str(i)+" >> LF, V4, L2 & V3")
        end        
        xlabel('Time (s)'); ylabel('LB');
        legend("Measurement with MAPE = "+num2str(mapeM)+"%", "Data Reconciliation with MAPE = "+num2str(mape_svm(i))+"%", 'Location', 'Best')
    end
    sgtitle("Probability distributions of the residuals for the measurements & the reconciled values")
end

% Display in MAPE in Table
NumberUnmeasuredVariables = ["M";"0";"1";"2";"3";"4"];
MAPE = [mapeM; mape_avm; mape_svm];
table(NumberUnmeasuredVariables, MAPE)
