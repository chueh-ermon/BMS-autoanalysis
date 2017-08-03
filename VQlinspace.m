function [ Qlin, Vlin ] = VQlinspace( cycle )
%VQlinspace returns a linearly-spaced V vs Q curve
%   Inputs: cycle (i.e. batch(i).cycles(j))
%   Outputs: Qlin, Vlin = linearly spaced Qdis vs Vdis

% 1. Get the indices of all currents ~ -4 C, i.e. discharge indices.
% For all policies, we discharge at 4C (= -4C)
indices = find(abs(cycle.I+4) < 0.05);

% 2. Extract Q_dis and V_dis: 
Q_dis_raw = cycle.Q(indices);
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