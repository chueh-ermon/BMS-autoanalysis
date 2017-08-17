function [ Qlin, Vlin ] = VQlinspace2( cycle )
%VQlinspace2 returns a linearly-spaced V vs Q curve
%   Inputs: cycle (i.e. batch(i).cycles(j))
%   Outputs: Qlin, Vlin = linearly spaced Qdis vs Vdis
%VQlinspace2 uses time/current to generate discharge capacity due to 
%discrepancy for Qdischarge. This produces a "smoother" and more 
%physically meaningful discharge curve

% 1. Get the indices of all currents ~ -4 C, i.e. discharge indices.
% For all policies, we discharge at 4C (= -4.4A)
indices = find(abs(cycle.I+4) < 0.05);
% Remove trailing data points
[~, index2] = min(cycle.V(indices(1:end-2)));
indices = indices(1:index2);

% 2. Extract Q_dis (from t_dis) and V_dis: 
Q_dis_raw = (cycle.t(indices)-cycle.t(indices(1)))./60.*4.4;
V_dis_raw = cycle.V(indices);

% 3. Fit to function. Ensure data is nearly untransformed
VQfit = fit(V_dis_raw,Q_dis_raw, 'smoothingspline');

% 4. Linearly interpolate
n_points = 1000; % number of points to linearly interpolate between
V1 = 2.0;
V2 = 3.5;

spacing = (V2 - V1) / n_points;
Vlin = V1:spacing:V2; % voltage range for interpolation
Qlin = VQfit(Vlin);

end