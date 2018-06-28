function apply_model2(batch, batch_name, path)
% This function applies the predictions based on the model stored in
%   MyModel.mat
% Peter Attia, Kristen Severson
% Last updated June 28, 2018

%% TO DO:
%   Update model/build_battery_features

disp('Starting apply_model'),tic

%% Initialize

% Load the data you would like to apply the model to
numBat = size(batch,2);

% Load the model you would like to use
if strcmp(batch_name,'oed1')
    load('oed_model_batch1.mat')
else
    load('oed_model.mat')
end

%% Remove cells that did not reach 100 cycles
idx_running_cells = zeros(numBat,1);
if strcmp(batch_name,'oed1')
    cycle_cutoff = 98;
else
    cycle_cutoff = 100;
end
for k = 1:numBat
    if length(batch(k).cycles) < cycle_cutoff
        idx_running_cells(k) = 1;
    end
end
batch2 = batch(~idx_running_cells); % batch2 only contains running cells

%% Initialize
ypred = NaN(numBat,1);
ypred_l = NaN(numBat,1);
ypred_h = NaN(numBat,1);

if ~isempty(batch2)
    %% Build features
    if strcmp(batch_name,'oed1')
        feat = build_battery_features98(batch2);
    else
        feat = build_battery_features(batch2);
    end
    
    %% Make predictions
    feat_scaled = bsxfun(@minus,feat,mu);
    feat_scaled = bsxfun(@rdivide,feat_scaled,sigma);
    feat_scaled = feat_scaled(:,feat_ind);
    
    se = zeros(numBat,1);
    for i = 1:numBat
        se(i) = t_val*sqrt(MSE + MSE*[feat_scaled(i,:),1]/des_mat*[feat_scaled(i,:),1]');
    end
    
    ypred2 = feat_scaled*B1 + y_mu;
    ypred_l2 = 10.^(ypred2 - se);
    ypred_h2 = 10.^(ypred2 + se);
    ypred2 = 10.^ypred2;
    
    % Detect outliers
    for k = 1:length(feat_scaled)
        %if sum(abs(feat_scaled(k,:)) > 4)
        if (ypred_h2(k) - ypred_l2(k)) > 2000
            ypred2(k) = -1;
        end
    end
    
    % Combine pred arrays for cells that have completed with those that
    % haven't
    ypred(idx_running_cells==0) = ypred2;
    ypred_l(idx_running_cells==0) = ypred_l2;
    ypred_h(idx_running_cells==0) = ypred_h2;
    
    figure(), hold on
    CM = colormap('jet'); % Set colormap
    plot(ypred,'s')
    for i = 1:numBat
        plot(i*ones(100,1), linspace(ypred_l(i), ypred_h(i)),'k')
    end
    xlabel('Battery Index')
    ylabel('Cycle Life')
end

%% Export the result to a csv
% Preinitialization
barcode = zeros(numBat,1);
channels = zeros(numBat,1);
lifetimes = zeros(numBat,1);
policies = cell(numBat,1);

for i = 1:numBat
    barcode(i) = str2num(batch(i).barcode{1}(3:end));
    channels(i) = str2num(batch(i).channel_id{1});
    lifetimes(i) = batch(i).cycle_life;
    policies{i} = batch(i).policy_readable;
end

if contains(batch_name,'oed')
    % preinitialization
    C1 = zeros(numBat,1);
    C2 = zeros(numBat,1);
    C3 = zeros(numBat,1);
    C4 = zeros(numBat,1);
    
    for i = 1:numBat
        idx = strfind(batch(i).policy_readable,'-');
        C1(i) = str2double(batch(i).policy_readable(1:idx(1)-1));
        C2(i) = str2double(batch(i).policy_readable(idx(1)+1:idx(2)-1));
        C3(i) = str2double(batch(i).policy_readable(idx(2)+1:idx(3)-1));
        C4(i) = str2double(batch(i).policy_readable(idx(3)+1:end));
    end
    
    M = [C1, C2, C3, C4, round(ypred), round(ypred_l), round(ypred_h), ...
        lifetimes, channels, barcode];
    T = array2table(M,'VariableNames', {'C1','C2','C3','C4'...
        'Prediction','CI_Lo','CI_Hi','Lifetime','Channel','Barcode'});
else
    % Not OED
    M = [channels, barcode, lifetimes, round(ypred), round(ypred_l), round(ypred_h)];
    T = array2table(M,'VariableNames', ...
        {'Channel','Barcode','Lifetime','Prediction','CI_Lo','CI_Hi'});
    T.Policy = policies;
    T = sortrows(T,7);
end
filename = [date '_' batch_name '_predictions.csv'];
cd(path.result_tables)
writetable(T, filename);
cd(path.code)

disp('Completed apply_model'),toc

end