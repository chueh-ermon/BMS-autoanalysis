%% batch_visualization
% This script creates plots to visualize the features from a model. 
% Not run in auto_analysis data processing script

%clear; close all; clc

%%% PUT THE PATH TO THE DATA HERE %%%
if ~exist('batch','var')
    load('D:\Data_Matlab\Batch_data\2018-04-12_batchdata_updated_struct_errorcorrect.mat')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numBat = size(batch,2);

%% Features
% Load the model you would like to use
load('MyModel.mat')
feat = build_battery_features(batch);
feat_scaled = bsxfun(@minus,feat,mu);
feat_scaled = bsxfun(@rdivide,feat_scaled,sigma);
feat_scaled = feat_scaled(:,feat_ind);

for k = 1:length(feat_scaled(1,:))
    figure, plot(feat_scaled(:,k))
    title(['Feature ' num2str(k)])
end

%% Q v. N plots
figure, hold on
for i = 1:numBat
    plot(batch(i).summary.QDischarge,'.-')
end
xlabel('Cycle Number')
ylabel('Discharge (Ah)')

figure()
hold on
for i = 1:numBat
    plot(batch(i).summary.QCharge,'.-')
end
xlabel('Cycle Number')
ylabel('Charge (Ah)')

%% Temperature plots
figure()
for i = 1:numBat
    subplot(6,8,i)
    hold on
    for j = 1:5:length(batch(i).summary.QDischarge)
        if any(batch(i).cycles(j).t < 0)
            fix_ind = find(batch(i).cycles(j).t < 0,1);
            batch(i).cycles(j).t(fix_ind:end) = batch(i).cycles(j).t(fix_ind:end) + ...
                batch(i).cycles(j).t(fix_ind-1) - batch(i).cycles(j).t(fix_ind);
            
        end
        if any(batch(i).cycles(j).t > 100)
            fix_ind = find(batch(i).cycles(j).t >100,1);
            batch(i).cycles(j).t(fix_ind:end) = batch(i).cycles(j).t(fix_ind:end) + ...
                batch(i).cycles(j).t(fix_ind-1) - batch(i).cycles(j).t(fix_ind);
            
        end
        plot(batch(i).cycles(j).t,batch(i).cycles(j).T)
    end
    xlabel('Time')
    ylabel('Temperature')
    title(batch(i).policy_readable)
end

%% IR plots
figure()
hold on
for i = 1:numBat
    plot(batch(i).summary.IR,'.-')
end
xlabel('Cycle Number')
ylabel('IR')
