function [ Qlin, Vlin, Tlin ] = VQlinspace3( cycle )
%VQlinspace2 returns a linearly-spaced V vs Q curve
%   Inputs: cycle (i.e. batch(i).cycles(j))
%   Outputs: Qlin, Vlin = linearly spaced Qdis vs Vdis
%VQlinspace2 uses time/current to generate discharge capacity due to 
%discrepancy for Qdischarge. This produces a "smoother" and more 
%physically meaningful discharge curve
% Last modified October 31, 2017

%% 1. Create Vlin
n_points = 1000; % number of points to linearly interpolate between
V1 = 2.0;
V2 = 3.5;

% Old code below - use Vlin to keep consistent with IDCA (only one vector)
% spacing = (V2 - V1) / (n_points - 1);
% Vlin = V1:spacing:V2; % voltage range for interpolation
Vlin=linspace(V2,V1,n_points);

%% 2. Get the indices of all currents ~ -4 C, i.e. discharge indices.
% OLD: For all policies, we discharge at 4C (= -4.4A)
Irounded = round(cycle.I);
Idischarge = mode(Irounded(cycle.I<0));
indices = find(abs(cycle.I+(-Idischarge)) < 0.05);
% Remove trailing data points
[~, index2] = min(cycle.V(indices(1:end-2)));
indices = indices(1:index2);

%% 3. Extract Q_dis:
V_dis_raw = cycle.V(indices);
try % Q_dis_raw occasionally gives errors
    Q_dis_raw = -(cycle.t(indices)-cycle.t(indices(1)))./60.*cycle.I(indices).*1.1;
    
    %% 4. Fit to function. Ensure data is nearly untransformed
    VQfit = fit(V_dis_raw,Q_dis_raw, 'smoothingspline');
    
    %% 5. Linearly interpolate
    Qlin = VQfit(Vlin);
catch
    warning('VQlinspace2 failed - Qlin')
    Qlin = zeros(length(Vlin),1);
end

%% 6. Extract T_dis
T_dis_raw = cycle.T(indices);
try 
    %% 7. Fit to function. Ensure data is nearly untransformed
    VTfit = fit(V_dis_raw,T_dis_raw, 'smoothingspline');
    
    %% 8. Linearly interpolate
    Tlin = VTfit(Vlin);
catch
    warning('VQlinspace2 failed - Tlin')
    Tlin = zeros(length(Vlin),1);
end
end