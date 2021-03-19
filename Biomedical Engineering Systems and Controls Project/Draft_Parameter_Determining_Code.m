close all
clear
clc

%% Software compatibility
% Please make sure you have the following installed. You can check this by 
% typing "ver" into the command window
%     1) Control System Toolbox
%     2) System Identification Toolbox installed. 

% Also make sure you have Simulink installed. You can check by typing
% "simulink" into the command window.

% This project was compiled on Matlab 2020b. If you have compatibility
% issues, we have also included a 2019a version.
%% Part 1: Transfer Function Identification

%%%%%%%%%%%%%%%%%%  DO NOT CHANGE!!!! %%%%%%%%%%%%%%%%%%%%%%%
% Set up tranfer function estimation to enforce stability
mdl= @(num_poles,num_zeros) [idtf(NaN(1,1+num_zeros),[1,NaN(1,num_poles)])];
opt = tfestOptions('Display','off','InitMethod','all','InitialCondition','zero','EnforceStability',true) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load in dataset
    % Fs = sampling time (seconds)
    % t = time vector (seconds)
    % r = input (mA)
    % y_i = injured rat WDR response
    % y_n = naive rat WDR response
    
% TO DO: Change the number to reflect your team number.
%addpath(fullfile('/Users/mileslee/Downloads/Team_2')) %added by me. Might
%need to run this if there is an error with the file path. 
load('DATASET_2.mat')

% Convert data into the correct format for transfer function estimation
data_n =  iddata(y_n,r,Fs) ; % naive rat
data_i =  iddata(y_i, r, Fs);
%%
% TO DO: Use the following code to fit your naive rat model, we suggest by
% Creating a for loop and testing a range of poles and zeros:
min_value_n = 5;
max_value_n = 10; 

z_list_n = [];
p_list_n = [];
sqDiffSum_list_n = [];
count = 1;
for z=min_value_n:1:max_value_n
    for p=z:1:max_value_n
        z_list_n(count) = z;
        p_list_n(count) = p;
        init_sys_n = mdl(p,z); 
        SYS_N = tfest(data_n,init_sys_n,opt);
        y_n_est = lsim(SYS_N,r,t);
        sqDiffSum_list_n(count) = sum((y_n - y_n_est).^2);
        count = count + 1;
    end
end
%%
T = table(z_list_n.', p_list_n.', sqDiffSum_list_n.')

best = min(sqDiffSum_list_n)
index = find(sqDiffSum_list_n == best);
z_list_n(index)
p_list_n(index)

pz_error_mat = vertcat(z_list_n, p_list_n, sqDiffSum_list_n);
figure(6); hold on
for i = 1:3:3*size(pz_error_mat,2)
    if pz_error_mat(i) ==  5
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'r','filled')
    elseif pz_error_mat(i) ==  6
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'g','filled')
    elseif pz_error_mat(i) ==  7
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'b','filled')
    elseif pz_error_mat(i) ==  8
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'y','filled')
    elseif pz_error_mat(i) ==  9
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'m','filled')
    elseif pz_error_mat(i) ==  10
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'c','filled')
    end
end
set(gca, 'Yscale', 'log')
xlabel('Number of Zeros')
ylabel('Error (squared difference sum)')
legend('Green: 8 Poles','Red: 9 Poles','Blue: 10 Poles')
%The reason why the legend colors don't match is because you have to set
%them when you plot the points. In order to fix this we need to divide the
%data we have into separate matrixes by pole number. That being
%said, this is kinda a small issue and we can worry about it later. In
%addition, we can add trend lines if we make this change. 
title('Error Analysis - Naive')
ylim([0 100])
hold off

%%
%injured 
min_value_i = 3;
max_value_i = 10; 

z_list_i = [];
p_list_i = [];
sqDiffSum_list_i = [];
count = 1;
for z=min_value_i:1:max_value_i
    for p=z:1:max_value_i
        %if z <= p
        z_list_i(count) = z;
        p_list_i(count) = p;
        init_sys_i = mdl(p,z); 
        SYS_I = tfest(data_i,init_sys_i,opt);
        y_i_est = lsim(SYS_I,r,t);
        sqDiffSum_list_i(count) = sum((y_i - y_i_est).^2);
        count = count + 1;
        %end
    end
end
%%
T = table(z_list_i.', p_list_i.', sqDiffSum_list_i.')

best = min(sqDiffSum_list_i)
index = find(sqDiffSum_list_i == best);
z_list_i(index)
p_list_i(index)

pz_error_mat = vertcat(z_list_i, p_list_i, sqDiffSum_list_i);
figure(7); hold on
for i = 1:3:3*size(pz_error_mat,2)
    if pz_error_mat(i) ==  5
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'r','filled')
    elseif pz_error_mat(i) ==  6
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'g','filled')
    elseif pz_error_mat(i) ==  7
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'b','filled')
    elseif pz_error_mat(i) ==  8
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'y','filled')
    elseif pz_error_mat(i) ==  9
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'m','filled')
    elseif pz_error_mat(i) ==  10
        scatter(pz_error_mat(i+1), pz_error_mat(i+2),40,'c','filled')
    end
end
set(gca, 'Yscale', 'log')
xlabel('Number of Zeros')
ylabel('Error (squared difference sum)')
legend('Green: 8 Poles','Red: 9 Poles','Blue: 10 Poles')
%The reason why the legend colors don't match is because you have to set
%them when you plot the points. In order to fix this we need to divide the
%data we have into separate matrixes by pole number. That being
%said, this is kinda a small issue and we can worry about it later. In
%addition, we can add trend lines if we make this change. 
title('Error Analysis - Injured')
ylim([0 100])
hold off

%% Plots with just the best poles and zeros:
num_zeros_n = 10;% Define the numer of poles and zeros for the TF
num_poles_n = 10;
% Estimate naive TF
init_sys_n = mdl(num_poles_n,num_zeros_n) ; 
SYS_N = tfest(data_n,init_sys_n,opt) ;
% Estimate naive WDR response
y_n_est = lsim(SYS_N,r,t) ;
% TO DO: Repeat for injured rat model
num_zeros_i = 5;
num_poles_i = 9;
% Estimate naive TF
init_sys_i = mdl(num_poles_i, num_zeros_i); 
SYS_I = tfest(data_i, init_sys_i, opt);
% Estimate naive WDR response
y_i_est = lsim(SYS_I, r, t);
%%
% TO DO: Create plots showing just data
figure(1); hold on 
plot(t, y_n, 'LineWidth', 1.3);
plot(t, y_n_est, 'LineWidth', 1.3);
% Graph Attributes
title('raw data naive')
xlim([15 20]); %ylim([0 1000])
xlabel('Time t (seconds)')
ylabel('y_n')
legend('raw','estimate');
hold off

figure(2); hold on 
plot(t, y_i, 'LineWidth', 1.3);
plot(t, y_i_est, 'LineWidth', 1.3);
% Graph Attributes
title('raw data injured')
xlim([15 20]); %ylim([0 1000])
xlabel('Time t (seconds)')
ylabel('y_i')
legend('raw','estimate');
hold off

% TO DO: Create plots showing model fits to data
% included above.

% TO DO: Create some kind of figure showing how you selected the fits
% shown above.
%% Part 2.0: Control Design
% TO DO: Input your final Naive Model and Injured Model from Part 1.
H_N = SYS_N;
H_I = SYS_I;
reference.time = t;
reference.signals.values = r;

% Opens the Simulink Model
open('PID_Controller.slx')

% TO DO: double check the simulation parameters (fixed-step integrator)
% 1) Go to the modeling tab, 
% 2) Click on Model Settings
% 3) Under solver selection time select fixed-step, Solver = ode4
% 4) Under solver details set the step size equal to 1e-3
% 5) Ok
%% Part 2.1: Tune Parameters find Kcr
% TO DO: Modify parameters of Controller
% You can change the Kp,Ki,Kd parameters here, or you can modify them
% directly in Simulink by changing the values in the PID block

% We first set Ki = 0 and Td = 0, use the proportional control only. 
% And increase KP from 0 to a critical value Kcr at which the output first 
% exhibits sustained oscillations. And then consider the 
% Kp, Ki, and Kd according to the table

% Need to see the pattern in a short time (lim == true), 
% and also in a long term (lim == false)

zn_tuner_find_Kcr(0.01, 0.05, 6, H_N, H_I, true, t, r);
zn_tuner_find_Kcr(0.04, 0.05, 7, H_N, H_I, true, t, r);
zn_tuner_find_Kcr(0.04, 0.0425, 8, H_N, H_I, true, t, r);

zn_tuner_find_Kcr(0.040625, 0.041875, 9, H_N, H_I, true, t, r);
zn_tuner_find_Kcr(0.040625, 0.041875, 10, H_N, H_I, false, t, r);

%% Part 2.2: Get Final Kcr and Pcr
Ki = 0; 
Kd = 0;

figure(11); hold on 
% Graph Attributes
title('model data')
xlabel('Time t (seconds)')
ylabel('model responses')
Kp = 0.041875;
Data = sim('PID_Controller.slx'); % runs the simulink model from here
time = Data.simout.time;
closed_loop_injured_model_response = Data.simout.signals.values(:,3);
plot(time, closed_loop_injured_model_response);
hold off;

Kcr = Kp;
Pcr = constant_oscillation_period(time, closed_loop_injured_model_response);

%% Part 2.3: Graph Final Result

% Choose between the two, classic or Pessen Integral Rule, see that Pessen
% Integral Rule performs better

Kp = 0.7 * Kcr;
Ki = 1.75 * Kcr / Pcr;
Kd = 0.105 * Kcr * Pcr;

fprintf("Kp = %f, Ki = %f, Kd = %f \n", Kp, Ki, Kd); 

Data = sim('PID_Controller.slx'); % runs the simulink model from here

% Extract responses from Data
time = Data.simout.time;
naive_model_response = Data.simout.signals.values(:,1);
injured_model_response = Data.simout.signals.values(:,2);
closed_loop_injured_model_response = Data.simout.signals.values(:,3);

% TO DO: Create plots showing how well your controller performs
figure(5); hold on 
plot(time, naive_model_response);
plot(time, injured_model_response);
plot(time, closed_loop_injured_model_response);
% Graph Attributes
title('model data')
xlim([0 6])
xlabel('Time t (seconds)')
ylabel('model responses')
legend("naive model", "injured model", "closed loop response")
hold off

%% Closed-loop system to submit to your TA

% TO DO: Define Final Gains - don't change the name, just the value
Kp_final = 0.029312; 
Ki_final = 0.549217; 
Kd_final = 0.000587; 

% TO DO: Change the number in your team name
save('Team_6_Results.mat','Kp_final','Ki_final','Kd_final','H_N','H_I')



%% Closed-loop system to submit to your TA

% TO DO: Define Final Gains - don't change the name, just the value
Kp_final = 0; 
Ki_final = 0; 
Kd_final = 0;

% TO DO: Change the number in your team name
save('Team_6_Results.mat','Kp_final','Ki_final','Kd_final','H_N','H_I')


