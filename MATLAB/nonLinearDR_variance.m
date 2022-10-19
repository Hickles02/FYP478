%% Submission status
% Submitted for review - TM Louw

%% Non-Linear Data Reconciliation - Variance Analysis
% This main function loads the true data generated by the model of
% the binary distillation column. Subsequently, it performs DR (for AVM) for various
% different variance values. Lastly, it evaluates the effect of increasing
% varaince on the peformance of DR.

%% Initialise
clear
clc

%% Load data
load('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'p', 'u')

%% Measurements with Variance
% The function measureReal artificially corrupts the true data
a = 100;                             % Amount of iterations
variance = linspace(0.05,1,a);   % Variance values
upperBound = [Inf(7,1); ones(6,1)];  % Upper bounds - flowrates can technically be infinite whilst fractions can be a maximum of 1
lowerBound = zeros(13,1);            % Lower bounds - flowrates and fractions can't be below zero

% Pre-allocation
Xhat     = zeros(13,1001);
XB = zeros(a,1001); LB = zeros(a,1001);
mapeM    = zeros(a,2); mape_avm = zeros(a,2);

% Variance analysis
for i = 1:a
    [measured_data, time] = measureReal(MM, X, v, u, p, tSol, variance(i));

    % Set Up Matrices
    X0 = zeros(13,1);
    Y = [measured_data.L1; measured_data.LB; measured_data.LD; measured_data.LR;...
         measured_data.V0; measured_data.V4; measured_data.LF; measured_data.X1;...
         measured_data.XB; measured_data.XD; measured_data.Y0; measured_data.Y4;...
         measured_data.XF];
    W = diag([ones(7,1)*variance(i).^2; ones(6,1)*(variance(i).^2)/10]);

    for j = 1:length(time)
        % Weighted objective function given current measurements Y(:,i)

        J = @(x) (Y(:,j) - x)'*W*(Y(:,j) - x);

        % Non-linear constraints f(x) = 0. See the bottom of the script
        % Find the non-linear estimates. Use the measurements as initial guess
        % See the help file for fmincon to understand the different required input arguments.
        Xhat(:,j) = fmincon(J, X0,[],[],[],[],lowerBound, upperBound, @nonLinearConstraints);  % Reconciled values for each variable
        X0        = Y(:,j);                                                                    % New guesses
    end

    XB(i,:) = Xhat(9,:);    % XB reconciled values for each variance value
    LB(i,:) = Xhat(2,:);    % LB reconciled values for each variance value

    % Error Metrics
    % Mean Absolute Percentage Error
    mapeM(i,1)    = mean(100*abs((true_data.XB(:,100:end) - measured_data.XB(:,100:end))./true_data.XB(:,100:end)));
    mape_avm(i,1) = mean(100*abs((true_data.XB(:,100:end) - XB(i,100:end))./true_data.XB(:,100:end)));
    mapeM(i,2)    = mean(100*abs((true_data.LB(:,100:end) - measured_data.LB(:,100:end))./true_data.LB(:,100:end)));
    mape_avm(i,2) = mean(100*abs((true_data.LB(:,100:end) - LB(i,100:end))./true_data.LB(:,100:end)));
end

%% Plot results - Variance analysis
% Figure 5.3.3
subplot(1,1,1)
patch([variance fliplr(variance)], [mapeM(:,1)' fliplr(mape_avm(:,1)')], 'y')
hold on
plot(variance, mapeM(:,1)', 'r', variance, mape_avm(:,1)', 'b')
hold off
xlabel("Variance"); ylabel("mapeValue - XB")
xlim([0.05 1])
legend("Difference","Measurements","Data Reconciliation")
title("Comparison of MAPE values between measurements and DR - XB")

mapediff = mapeM(:,1)-mape_avm(:,1)

gradient1 = (mapediff(25,1)-mapediff(1,1))/(variance(25) - variance(1))
gradient2 = (mapediff(50,1)-mapediff(25,1))/(variance(50) - variance(25))
gradient3 = (mapediff(75,1)-mapediff(50,1))/(variance(75) - variance(50))
gradient4 = (mapediff(100,1)-mapediff(75,1))/(variance(100) - variance(75))
% Table 5.3.2
GradientName = ["1st Quarter";"2nd Quarter";"3rd Quarter";"4th Quarter"];
mapeGradient = [gradient1; gradient2; gradient3; gradient4];
table(GradientName, mapeGradient)

%% Save Data
% This data will be used in the comparison file 
save('nonlinearDR_data', 'mape_avm')

%% Function
function [g, f] = nonLinearConstraints(x)
g = []; % No inequality constraints
% Mass balances
% x(1) = L1; x(2) = LB; x(3) = LD; x(4) = LR; x(5) = V0; x(6) = V4; 
% x(7) = LF; x(8) = X1; x(9) = XB; x(10) = XD; x(11) = Y0; x(12) = Y4;
% x(13) = XF
f = [x(7) - x(3) - x(2);...
     x(1) - x(2) - x(5);...
     x(6) - x(3) - x(4);...
     x(7)*x(13) - x(3)*x(10) - x(2)*x(9);...
     x(1)*x(8)  - x(2)*x(9)  - x(5)*x(11);...
     x(6)*x(12) - x(3)*x(10) - x(4)*x(10)];
end
