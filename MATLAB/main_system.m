%% Initialise
clear
clc

%% Define time period
t = linspace(0,1000,1000);

%% Define Parameters 

% Need weir height and correct volatility

p.N = 4;        % ~, Number of trays 
p.alpha = 2.4;  % ~, Relative volatility
p.yy = 1;       % ~, Activity coefficient 
p.kw = 15;      % ~, Weir constant
p.lw = 0.05;    % m, Weir height
p.pm = 11;      % moles/m^3, Density >> (876 kg/m3 * 1000 g/kg / 78.11 g/mol) / 1000 mol/kmol
p.A  = 0.5;     % m^2, Area 
p.kr = 0.5;     % ~, Reboiler constant -- Heat vaporisation

%% Define exogenous variables
% Feed variables
u.LF = @(t) 10 - 0*(t > 500);       % kmol/min, Feed liquid molar flowrate
u.XF = @(t) 0.5 - 0*(t > 300);      % ~, Feed liquid molar fraction 

% Desired ratios 
u.R = @(t) 2.5 + 0*(t > 200) - 0*(t > 600);     % ~, Reflux ratio
u.B = @(t) 2 + 0*(t > 200) - 0*(t > 600);       % ~, Boilup ratio


u.Freb = @(t) 2 + 0*t;              % mol/min, Boiler heating fluid molar flowrate

%% Define intial conidtions - Molar Holdup
% Initial conditions of the molar holdup ODEs
DV0 = [ones(p.N,1); zeros(6,1)];

%% Simulate ODEs - Molar Holdup
% This solves the molar holdup ODEs
sol = ode45(@(t, x) simulate_ODEs(t, x, u, p), [0 1000], DV0);
DV = sol.y;
tSol = sol.x;
v = intermediaries(tSol, DV, u, p);

% Change into desired vector format & naming convention
MM = DV(1:p.N,:);
X  = DV(p.N+1:end,:);
tSol = tSol';

%% Plot results
% Option 1 == Display results for each variable
% Option 2 == Display effect of reboiler & reflux ratio on XB & XD

option = 1;

if option == 1% Plot Molar Holdup
    subplot(5,1,1)
    plot(tSol, MM);
    labelsM = cell(1,p.N);
    for n = 1:p.N
            labelsM{n} = "MM" + num2str(n);
    end
    xlabel('Time (s)'); ylabel('Liquid holdup in kmole')
    title("Molar Holdup")
    legend(labelsM, 'location', 'best')

    % Plot Molar Liquid Fractions
    subplot(5,1,2)
    plot(tSol, X)
    labelsX = cell(1,p.N);
    for n = 1:p.N
        labelsX{n} = "X" + num2str(n);
    end
    xlabel('Time (s)'); ylabel('Liquid mol fraction')
    labelsX{end+1} = "XB";
    labelsX{end+1} = "XD";
    title("Molar Liquid Fractions")
    legend(labelsX, 'location', 'best')

    % Plot Liquid Flowrates
    subplot(5,1,3)
    plot(tSol, v.L', tSol, v.LB', 'r', tSol, v.LD', tSol, v.LR', 'b')
    xlabel('Time (s)'); ylabel('Liquid molar flowrate')
    labelsL = cell(1,p.N);
    for n = 1:p.N
        labelsL{n} = "L"+num2str(n);
    end
    labelsL{end+1} = "LB";
    labelsL{end+1} = "LD";
    labelsL{end+1} = "LR";
    title("Liquid Flowrates in kmole/min")
    legend(labelsL, 'location', 'best')

    % Plot Molar Vapour Fractions
    subplot(5,1,4)
    plot(tSol, v.Y',tSol, v.Y0')
    labelsY = cell(1,p.N);
    for n = 1:p.N
        labelsY{n} = "Y" + num2str(n);
    end
    xlabel('Time (s)'); ylabel('Vapour mol fraction')
    labelsY{end+1} = "Y0";
    title("Molar Vapour Fractions")
    legend(labelsY, 'location', 'best')

    % Plot Vapour Flowrates
    subplot(5,1,5)
    plot(tSol, v.V',tSol, v.V0')
    labelsV = cell(1,p.N);
    for n = 1:p.N
        labelsV{n} = "V" + num2str(n);
    end
    xlabel('Time (s)'); ylabel('Vapour flowrates in kmole/min')
    labelsV{end+1} = "V0";
    title("Vapour flowrates")
    legend(labelsV, 'location', 'best')
    
    sgtitle("Plot displaying results for each variable generated by model")
end

if option == 2
    subplot(2,2,1)
    plot(tSol, u.B(tSol), 'r')
    title("Boilup ratio")
    xlim([100 1000])
    subplot(2,2,2)
    plot(tSol, X(5,:)', 'r')
    title("XB")
    xlim([100 1000])
    ylim([0.2 0.4])
    subplot(2,2,3)
    plot(tSol, u.R(tSol), 'b')
    title("Reflux ratio")
    xlim([100 1000])
    subplot(2,2,4)
    plot(tSol, X(6,:)', 'b')
    title("XD")
    xlim([100 1000])
    ylim([0.8 1])
    
    sgtitle("Effect of Boilup & Reflux ratio")
end
%% Measure true data 
true_data = measureReal(MM, X, v, u, p, tSol, 0);

%% Save data
save('true_data', 'MM', 'X', 'tSol', 'true_data', 'v', 'u', 'p')


