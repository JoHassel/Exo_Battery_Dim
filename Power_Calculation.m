clc; clear; close all;
% Parameters
n_bat = 1;                                                                  % One or two batteries
n_x_axis = 100;                                                             % Amount of data points per cycle
eff_motor = 0.80;                                                           % Efficiencies
eff_gearbox = 0.7;
eff_servo = 0.85;   
eff_cable = 0.95;
weight_exo = 80;                                                            % Weight in kg
weight_human = 90;                                                  
time_exo = 1;                                                               % Running time in h
v_bat = 48;                                                                 % Battery Voltage in V
walking = 0.94;                                                             % Percentage of time per mode
stairs_up = 0.02;
stairs_down = 0.02;
sitting_down = 0.01;
standing_up = 0.01;
p_e_other = 47.4;                                                           % Average Power of other consumers (Schnittstellendokument)
p_e_other_peak= 82.3;                                                       % Peak Power of other consumers (Schnittstellendokument)
u_gear = 80;                                                                % Reduction Gear Ratio (Hip and Knee)
i_bat_max = 32;                                                             % Set maximum battery current which is used to calculate supercaps (in Ampere)
t_stairs_up_cycle = 1.11;                                                   % time in seconds from paper

%% Data Walking
% Import data angle velocity trajectory [°/s]
av_walk_a = readmatrix("Walking\Ankle_Angle_Velocity.txt");                 % a = Ankle
av_walk_k = readmatrix("Walking\Knee_Angle_Velocity.txt");                  % k = Knee
av_walk_h = readmatrix("Walking\Hip_Angle_Velocity.txt");                   % h = Hip

% Calculate data angle velocity trajectory [revs per second]
av_walk_a_rps = zeros (n_x_axis,2);
for i = 1:n_x_axis                                             
    av_walk_a_rps(i,1) = av_walk_a(i,1);                                    % First row = Percentage Value of Cycle between 1 and 100
    av_walk_a_rps(i,2) = av_walk_a(i,2)/360;                             % Second row = Angle Velocity in revs per second
end                                                                         % Factor: deg/s --> revs per second

av_walk_k_rps = zeros (n_x_axis,2);
for i = 1:n_x_axis
    av_walk_k_rps(i,1) = av_walk_k(i,1);
    av_walk_k_rps(i,2) = av_walk_k(i,2)/360;
end

av_walk_h_rps = zeros (n_x_axis,2);
for i = 1:n_x_axis
    av_walk_h_rps(i,1) = av_walk_h(i,1);
    av_walk_h_rps(i,2) = av_walk_h(i,2)/360;                       
end

% Import data torque trajectory [N/kg]
t_walk_a = readmatrix("Walking\Ankle_Torque.txt");                          % First row: Percentage Value of Cycle between 1 and 100                                        
t_walk_k = readmatrix("Walking\Knee_Torque.txt");                           % Second Row: Torque in N/kg                    
t_walk_h = readmatrix("Walking\Hip_Torque.txt");                                         

%% Efficiency Motor Walking
% Import Data (Efficiency over rpm)
eff_motor_plot = readmatrix("Wirkungsgrad_Motor_ueber_Drehzahl.txt");
rpm_h_motor = av_walk_h_rps(1:n_x_axis,2)*60*u_gear;
rpm_k_motor = av_walk_k_rps(1:n_x_axis,2)*60*u_gear;
rpm_a_motor = av_walk_a_rps(1:n_x_axis,2)*60*u_gear;

% Hip:
eff_motor_h = zeros(n_x_axis,1);
for i = 1:n_x_axis
    dummy = 1;
    while eff_motor_plot(dummy,1)<abs(rpm_h_motor(i))
        dummy = dummy + 1;
        if dummy == 60
            break
        end
    end
    eff_motor_h(i) = eff_motor_plot(dummy,2);
end 

% Knee:
eff_motor_k = zeros(n_x_axis,1);
for i = 1:n_x_axis
    dummy = 1;
    while eff_motor_plot(dummy,1)<abs(rpm_k_motor(i))
        dummy = dummy + 1;
        if dummy == 60
            break
        end
    end
    eff_motor_k(i) = eff_motor_plot(dummy,2);
end 
eff_motor_h_avg = mean(eff_motor_h)/100;
eff_motor_k_avg = mean(eff_motor_k)/100;

%% Mechanical Power
% Calculate Mechanical power Walking  [W/kg]                                P = 2*pi*M*n 
p_mech_walk_a= zeros(n_x_axis,1);
for i = 1:n_x_axis
    p_mech_walk_a(i,1) = 2*pi*t_walk_a(i,2)*av_walk_a_rps(i,2);             
end
p_mech_walk_k= zeros(n_x_axis,1);
for i = 1:n_x_axis
    p_mech_walk_k(i,1) = 2*pi*t_walk_k(i,2)*av_walk_k_rps(i,2);
end
p_mech_walk_h= zeros(n_x_axis,1);
for i = 1:n_x_axis
    p_mech_walk_h(i,1) = 2*pi*t_walk_h(i,2)*av_walk_h_rps(i,2);
end

% Mechanical Power for other modes directly from papers
% Import Mechanical Power Stairs up [W/kg]                                    First row: Percentage Value of Cycle between 1 and 100
p_mech_stairs_up_a = readmatrix("Stairs_up\P_mech_Ankle_marked.txt");       % Second Row: Mechanical Power in N/kg
p_mech_stairs_up_k = readmatrix("Stairs_up\P_mech_Knee_marked.txt");
p_mech_stairs_up_h = readmatrix("Stairs_up\P_mech_Hip_marked.txt");

% Import Mechanical Power Stairs down [W/kg]
p_mech_stairs_down_a = readmatrix("Stairs_down\P_mech_Ankle_marked.txt");
p_mech_stairs_down_k = readmatrix("Stairs_down\P_mech_Knee_marked.txt");
p_mech_stairs_down_h = readmatrix("Stairs_down\P_mech_Hip_marked.txt");

% Import Mechanical Power Sitting down [W/kg]
p_mech_sitting_down_a = readmatrix("Sitting_down\Ankle_Power.txt");
p_mech_sitting_down_k = readmatrix("Sitting_down\Knee_Power.txt");
p_mech_sitting_down_h = readmatrix("Sitting_down\Hip_Power.txt");

% Import Mechanical Power Standing up normalized to W/kg (89.15kg = weight person from paper)
p_mech_standing_up_a = readmatrix("Standing_up\Ankle_Power.txt")/89.15;
p_mech_standing_up_k = readmatrix("Standing_up\Knee_Power.txt")/89.15;
p_mech_standing_up_h = readmatrix("Standing_up\Hip_Power.txt")/89.15;

%% Absolute Values + add second leg 
% Walking
p_mech_walk_abs= zeros(n_x_axis,1);
dummy = 50;                                                                 % Variable 'dummy'  runs from 50 to 100 and then from 1 to 49
for i=1:n_x_axis
    dummy = dummy +1;
    if dummy > n_x_axis
        dummy = 1;
    end
    if n_bat == 1   
        % Summing up Ankle, Knee and Hip for index 'i'(left leg) and 'dummy' (right leg) 
        p_mech_walk_abs(i) = abs(p_mech_walk_a(i)) + abs(p_mech_walk_k(i)) + abs(p_mech_walk_h(i)) + abs(p_mech_walk_a(dummy)) + abs(p_mech_walk_k(dummy)) + abs(p_mech_walk_h(dummy));
    end
    if n_bat == 2
        p_mech_walk_abs(i) = abs(p_mech_walk_a(i)) + abs(p_mech_walk_k(i)) + abs(p_mech_walk_h(i));
    end
end

% Stairs up
p_mech_stairs_up_abs= zeros(n_x_axis,1);
p_mech_stairs_up_1leg= zeros(n_x_axis,1);
dummy = 50;                                                                 % Variable 'dummy'  runs from 50 to 100 and then from 1 to 49
for i=1:n_x_axis
    dummy = dummy +1;
    if dummy > n_x_axis
        dummy = 1;
    end
    if n_bat == 1
        % Summing up Ankle, Knee and Hip for index 'i'(left leg) and 'dummy' (right leg)
        p_mech_stairs_up_abs(i) = abs(p_mech_stairs_up_h(i,2)) + abs(p_mech_stairs_up_a(i,2)) + abs(p_mech_stairs_up_k(i,2)) + abs(p_mech_stairs_up_h(dummy,2)) + abs(p_mech_stairs_up_a(dummy,2)) + abs(p_mech_stairs_up_k(dummy,2));
        p_mech_stairs_up_1leg(i) = abs(p_mech_stairs_up_h(i,2)) + abs(p_mech_stairs_up_a(i,2)) + abs(p_mech_stairs_up_k(i,2));
    end 
    if n_bat == 2
        p_mech_stairs_up_abs(i) = abs(p_mech_stairs_up_h(i,2)) + abs(p_mech_stairs_up_a(i,2)) + abs(p_mech_stairs_up_k(i,2));
        p_mech_stairs_up_1leg(i) = abs(p_mech_stairs_up_h(i,2)) + abs(p_mech_stairs_up_a(i,2)) + abs(p_mech_stairs_up_k(i,2));
    end
end

% Stairs down
p_mech_stairs_down_abs= zeros(n_x_axis,1);
dummy = 50;                                                                 % Variable 'dummy'  runs from 50 to 100 and then from 1 to 49
for i=1:n_x_axis
    dummy = dummy +1;
    if dummy > n_x_axis
        % Variable 'dummy'  runs from 50 to 100 and then from 1 to 49
        dummy = 1;
    end
    if n_bat == 1
        p_mech_stairs_down_abs(i) = abs(p_mech_stairs_down_h(i,2)) + abs(p_mech_stairs_down_a(i,2)) + abs(p_mech_stairs_down_k(i,2)) + abs(p_mech_stairs_down_h(dummy,2)) + abs(p_mech_stairs_down_a(dummy,2)) + abs(p_mech_stairs_down_k(dummy,2));
    end
    if n_bat == 2
        p_mech_stairs_down_abs(i) = abs(p_mech_stairs_down_h(i,2)) + abs(p_mech_stairs_down_a(i,2)) + abs(p_mech_stairs_down_k(i,2));
    end
end

% Sitting down
p_mech_sitting_down_abs = zeros(n_x_axis,1);
for i=1:n_x_axis
    if n_bat == 1
        % Legs are synchronous --> one leg multiplied by 2
        p_mech_sitting_down_abs(i) = 2*(abs(p_mech_sitting_down_h(i,2)) + abs(p_mech_sitting_down_a(i,2)) + abs(p_mech_sitting_down_k(i,2)));
    end
    if n_bat == 2                                                           
        p_mech_sitting_down_abs(i) = (abs(p_mech_sitting_down_h(i,2)) + abs(p_mech_sitting_down_a(i,2)) + abs(p_mech_sitting_down_k(i,2)));
    end
end

% Standing up
p_mech_standing_up_abs = zeros(n_x_axis,1);
for i=1:n_x_axis
    if n_bat == 1
        % Legs are synchronous --> one leg multiplied by 2
        p_mech_standing_up_abs(i) = 2*(abs(p_mech_standing_up_h(i,2)) + abs(p_mech_standing_up_a(i,2)) + abs(p_mech_standing_up_k(i,2)));
    end 
    if n_bat == 2
        p_mech_standing_up_abs(i) = (abs(p_mech_standing_up_h(i,2)) + abs(p_mech_standing_up_a(i,2)) + abs(p_mech_standing_up_k(i,2)));
    end
end

%% Calculate Electrical Power
% Mechanical Power [W/kg] --> Electrical Power [W]
eff_total = eff_motor*eff_gearbox*eff_servo*eff_cable; 
weight_total = weight_human + weight_exo;

% Walking:
p_e_act_walk = zeros(n_x_axis,1);
dummy = 50;                                                                 % Variable 'dummy'  runs from 50 to 100 and then from 1 to 49
for i=1:n_x_axis
    dummy = dummy +1;
    if dummy > n_x_axis
        dummy = 1;
    end
    if n_bat == 1   
        % Summing up Ankle, Knee and Hip for index 'i'(left leg) and 'dummy' (right leg) 
        p_e_act_walk(i) = weight_total*(abs(p_mech_walk_a(i))/eff_motor + abs(p_mech_walk_k(i))/eff_motor_k_avg + abs(p_mech_walk_h(i))/eff_motor_h_avg + abs(p_mech_walk_a(dummy))/eff_motor + abs(p_mech_walk_k(dummy))/eff_motor_k_avg + abs(p_mech_walk_h(dummy))/eff_motor_h_avg)/(eff_cable*eff_servo*eff_gearbox);
    end
    if n_bat == 2
        p_e_act_walk(i) = weight_total*(abs(p_mech_walk_a(i))/eff_motor + abs(p_mech_walk_k(i))/eff_motor_k_avg + abs(p_mech_walk_h(i))/eff_motor_h_avg)/(eff_cable*eff_servo*eff_gearbox);
    end
end

% Other Modes:
p_e_act_stairs_up = p_mech_stairs_up_abs*weight_total/eff_total;
p_e_act_stairs_down = p_mech_stairs_down_abs*weight_total/eff_total;
p_e_act_sitting_down = p_mech_sitting_down_abs*weight_total/eff_total;
p_e_act_standing_up = p_mech_standing_up_abs*weight_total/eff_total;
p_e_act_stairs_up_1leg = p_mech_stairs_up_1leg*weight_total/eff_total;

% Calculate Average and Peak Electrical Power [W]
p_e_act_walk_max = max(p_e_act_walk);
p_e_act_stairs_up_max = max(p_e_act_stairs_up);
p_e_act_stairs_down_max = max(p_e_act_stairs_down);
p_e_act_standing_up_max = max(p_e_act_standing_up);
p_e_act_sitting_down_max = max(p_e_act_sitting_down);

p_e_act_walk_avg = mean(p_e_act_walk);
p_e_act_stairs_up_avg= mean(p_e_act_stairs_up);
p_e_act_stairs_down_avg = mean(p_e_act_stairs_down);
p_e_act_standing_up_avg = mean(p_e_act_standing_up);
p_e_act_sitting_down_avg = mean(p_e_act_sitting_down);

p_e_act_avg = walking*p_e_act_walk_avg + stairs_up*p_e_act_stairs_up_avg + stairs_down*p_e_act_stairs_down_avg + standing_up*p_e_act_standing_up_avg + sitting_down*p_e_act_sitting_down_avg;
p_e_act_max = max([p_e_act_walk_max p_e_act_stairs_up_max p_e_act_stairs_down_max p_e_act_standing_up_max p_e_act_sitting_down_max]);

% Other consumers (from Schnittstellendokument) [W]
if n_bat == 1
    p_e_avg_total = p_e_act_avg + p_e_other;
    p_e_max_total = p_e_act_max + p_e_other_peak;
end 
% Assumption: split up other consumers 50:50 to two batteries
if n_bat == 2
    p_e_avg_total = p_e_act_avg + 0.5*p_e_other;
    p_e_max_total = p_e_act_max + 0.5*p_e_other_peak;
end 
p_e_max_total;

%% Battery Parameters
cap_bat_wh = time_exo*p_e_avg_total;
cap_bat_ah = cap_bat_wh/v_bat;
i_max_bat = p_e_max_total/v_bat;

%% Plots
figure('Name','Electrical power for different modes');
% x-Axis minus 1 bc plot should start at 0 not at 1
plot((1:n_x_axis)-1, p_e_act_walk(1:n_x_axis), 'DisplayName','Walking','LineWidth',2)
hold on
plot((1:n_x_axis)-1, p_e_act_stairs_up(1:n_x_axis), 'DisplayName','Stairs Up','LineWidth',2)    
plot((1:n_x_axis)-1, p_e_act_stairs_down(1:n_x_axis), 'DisplayName','Stairs Down','LineWidth',2)
plot((1:n_x_axis)-1, p_e_act_standing_up(1:n_x_axis), 'DisplayName','Sit-to-Stand','LineWidth',2)
plot((1:n_x_axis)-1, p_e_act_sitting_down(1:n_x_axis), 'DisplayName','Stand-to-Sit','LineWidth',2)
hold off
title('Electrical power for different modes')
axis([0 100 0 4000])
xlabel('Cycle in %') 
ylabel('Electrical Power in W')
lgd = legend;
lgd.NumColumns = 1;

figure('Name','Electrical power stairs up (one leg)');
% x-Axis minus 1 bc plot should start at 0 not at 1
plot((1:n_x_axis)-1, p_e_act_stairs_up_1leg(1:n_x_axis), 'black','LineWidth',2)
axis([0 100 0 2500])
title('Electrical power stairs up (one leg)');
xlabel('Cycle in %') 
ylabel('Electrical Power in W')

% figure('Name','Revs per Minute for Walking Cycle');
% plot((1:n_x_axis)-1, av_walk_h_rps(1:n_x_axis,2)*u_gear*60, 'DisplayName','Hip','LineWidth',2)
% hold on
% plot((1:n_x_axis)-1, av_walk_k_rps(1:n_x_axis,2)*u_gear*60, 'DisplayName','Knee','LineWidth',2)
% hold off
% xlabel('Cycle in %') 
% ylabel('Revolution Speed in Revs/Minute')
% lgd = legend;
% lgd.NumColumns = 1;

% figure('Name','Motor Efficiency over Walking Cycle');
% plot((1:n_x_axis)-1, eff_motor_h, 'DisplayName','Hip','LineWidth',2)
% hold on
% plot((1:n_x_axis)-1, eff_motor_k, 'DisplayName','Knee','LineWidth',2)
% hold off
% axis([0 100 65 90])
% xlabel('Cycle in %') 
% ylabel('Efficiency in %')
% lgd = legend;
% lgd.NumColumns = 1;

%% Calculate Revs per Minutes Average
% Hip:
dummy = 0;
for i = 1:n_x_axis
    dummy = dummy + abs(av_walk_h_rps(i,2))*60;                          % Factor 60 for rps --> rpm
end
rpm_h_avg = dummy/n_x_axis;

% Knee: 
dummy = 0;
for i = 1:n_x_axis
    dummy = dummy + abs(av_walk_k_rps(i,2))*60;
end
rpm_k_avg = dummy/n_x_axis;

% Ankle:
dummy = 0;
for i = 1:n_x_axis
    dummy = dummy + abs(av_walk_a_rps(i,2))*60;
end
rpm_a_avg = dummy/n_x_axis;

%% Calculate Average Currents per Actuator
% Hip:
dummy = 0;
for i=1:n_x_axis
    dummy = dummy + abs(p_mech_walk_h(i))*walking + abs(p_mech_stairs_up_h(i,2))*stairs_up + abs(p_mech_stairs_down_h(i,2))*stairs_down + abs(p_mech_sitting_down_h(i,2))*sitting_down + abs(p_mech_standing_up_h(i,2))*standing_up;
end
p_mech_h_act_avg = dummy/n_x_axis;
i_h_act_avg = weight_total*p_mech_h_act_avg/(v_bat*eff_total);
 
% Knee:
dummy = 0;
for i=1:n_x_axis
    dummy = dummy + abs(p_mech_walk_k(i))*walking + abs(p_mech_stairs_up_k(i,2))*stairs_up + abs(p_mech_stairs_down_k(i,2))*stairs_down + abs(p_mech_sitting_down_k(i,2))*sitting_down + abs(p_mech_standing_up_k(i,2))*standing_up;
end
p_mech_k_act_avg = dummy/n_x_axis;
i_k_act_avg = weight_total*p_mech_k_act_avg/(v_bat*eff_total);

% Ankle:
dummy = 0;
for i=1:n_x_axis
    dummy = dummy + abs(p_mech_walk_a(i))*walking + abs(p_mech_stairs_up_a(i,2))*stairs_up + abs(p_mech_stairs_down_a(i,2))*stairs_down + abs(p_mech_sitting_down_a(i,2))*sitting_down + abs(p_mech_standing_up_a(i,2))*standing_up;
end
p_mech_a_act_avg = dummy/n_x_axis;
i_a_act_avg = weight_total*p_mech_a_act_avg/(v_bat*eff_total);

% Total Average Currrents:
i_avg_total = 2*(i_a_act_avg + i_k_act_avg + i_h_act_avg);
i_avg_total_test = p_e_act_avg/v_bat;

%% I_max per Actuator (walking)
i_max_h = max(p_mech_walk_h)*weight_total/(eff_total*v_bat);
i_max_k = max(p_mech_walk_k)*weight_total/(eff_total*v_bat);
i_max_a = max(p_mech_walk_a)*weight_total/(eff_total*v_bat);
i_max_walk = p_e_act_walk_max/v_bat;

%% Supercap Calculation (Stairs_up)
i_stairs_up_avg = p_e_act_stairs_up_avg/v_bat;
i_stairs_up_max = p_e_act_stairs_up_max/v_bat;

% Calculate Energy over Current Limit
p_e_act_stairs_up_overshoot = zeros(n_x_axis,2);
for i=1:n_x_axis
    p_e_act_stairs_up_overshoot(i,1) = t_stairs_up_cycle*(i/100);
    if (p_e_act_stairs_up(i) - (i_bat_max*v_bat)) > 0
        p_e_act_stairs_up_overshoot(i,2) = p_e_act_stairs_up(i) - (i_bat_max*v_bat);
    end
end

% Overshoot Integration gives Overshoot Energy:
w_overshoot_wh = trapz(p_e_act_stairs_up_overshoot(1:n_x_axis,1),p_e_act_stairs_up_overshoot(1:n_x_axis,2))/3600;                          % FIX!
w_overshoot_f = 7200 * w_overshoot_wh /  v_bat^2;                           % Transfer from Watt Hours to Farad

% Calculate Energy below Current Limit
p_e_act_stairs_up_undershoot = zeros(n_x_axis,2);
for i=1:n_x_axis
    p_e_act_stairs_up_undershoot(i,1) = t_stairs_up_cycle*(i/100);
    if (p_e_act_stairs_up(i) - (i_bat_max*v_bat)) < 0
        p_e_act_stairs_up_undershoot(i,2) = (i_bat_max*v_bat) - p_e_act_stairs_up(i);
    end
end

% Overshoot Integration gives Overshoot Energy:
w_undershoot_wh = trapz(p_e_act_stairs_up_undershoot(1:n_x_axis,1),p_e_act_stairs_up_undershoot(1:n_x_axis,2))/3600;                          % FIX!
w_undershoot_f = 7200 * w_undershoot_wh /  v_bat^2;                           % Transfer from Watt 

%% Plot Supercaps
i_stairs_up = p_e_act_stairs_up./v_bat;

upperBoundary_1 = max(i_stairs_up((1:n_x_axis),1),i_bat_max);
lowerBoundary_1(1,(1:n_x_axis)) = i_bat_max;
figure('Name','Current Stairs Up');
patch([(1:n_x_axis)-1 fliplr((1:n_x_axis)-1)], [transpose(upperBoundary_1)  fliplr(lowerBoundary_1)], "cyan"); 
upperBoundary_2(1:n_x_axis,1) = i_bat_max;
lowerBoundary_2 = min(i_stairs_up(1:n_x_axis,1),i_bat_max);
patch([(1:n_x_axis)-1 fliplr((1:n_x_axis)-1)], [transpose(upperBoundary_2)  fliplr(transpose(lowerBoundary_2))], "magenta");
hold on;
plot((1:n_x_axis)-1, i_stairs_up , "black", 'LineWidth', 1); 
yline(i_bat_max, '--', 'DisplayName','Battery Current Limit','LineWidth',2)
title('Compensation Current Peaks');
xlabel('Cycle in %');    
ylabel('Current in Ampere');

