function apply_model(batch, batch_name, path)
% This function applies the predictions based on the model stored in
%   MyModel.mat
% Peter Attia, Kristen Severson
% Last updated May 4, 2018

%% TO DO:
%   - if cell < 100 cycles

disp('Starting apply_model'),tic

% Set colormap
CM = colormap('jet');

% Load the data you would like to apply the model to
numBat = size(batch,2);

% Load the model you would like to use
load('MyModel.mat')

%% Features
feat = build_battery_features(batch);

%% Error correction would go here

%% Make predictions
feat_scaled = bsxfun(@minus,feat,mu);
feat_scaled = bsxfun(@rdivide,feat_scaled,sigma);
feat_scaled = feat_scaled(:,feat_ind);

se = zeros(numBat,1);
for i = 1:numBat
    se(i) = t_val*sqrt(MSE + MSE*[feat_scaled(i,:),1]/des_mat*[feat_scaled(i,:),1]');
end

ypred = feat_scaled*B1 + y_mu;
ypred_l = 10.^(ypred - se);
ypred_h = 10.^(ypred + se);
ypred = 10.^ypred;

figure(), hold on
plot(ypred,'s')
for i = 1:numBat
    plot(i*ones(100,1), linspace(ypred_l(i), ypred_h(i)),'k')
end
xlabel('Battery Index')
ylabel('Cycle Life')

%export the result to a csv
barcode = zeros(numBat,1);
channels = zeros(numBat,1);
policies = cell(numBat,1);
for i = 1:numBat
    barcode(i) = str2num(batch(i).barcode{1}(3:end));
    channels(i) = str2num(batch(i).channel_id{1});
    policies{i} = batch(i).policy_readable;
end

M = [channels, barcode, round(ypred), round(ypred_l), round(ypred_h)];
T = array2table(M,'VariableNames',{'Channel','Barcode','Prediction','CI_Lo','CI_Hi'});
T.Policy = policies;
T = sortrows(T,6);
filename = [date '_' batch_name '_predictions.csv'];
cd(path.result_tables)
writetable(T, filename);
cd(path.code)

%% Make contour plot
% Note that this code assumes 2-step, 10 minute policies

p1 = zeros(numBat,1);
p2 = zeros(numBat,1);
skip_ind = [];

for i = 1:numBat
    try
        k = strfind(batch(i).policy_readable,'C');
        j = strfind(batch(i).policy_readable,'-');
        p1(i) = str2num(batch(i).policy_readable(1:k(1)-1)) - 0.1 + 0.2*rand;
        if isempty(j+1:length(batch(i).policy_readable) - 1)
            p2(i) = str2num(batch(i).policy_readable(j+1)) -0.1 + 0.2*rand;
        else
            p2(i) = str2num(batch(i).policy_readable(j(1)+1:k(2)-1)) -0.1 + 0.2*rand;
        end
    catch
        skip_ind = [skip_ind, i];
    end
    
    
end

%for contour lines
time = 10; % target time of policies, in minutes
CC1 = 2.9:0.01:6.1;
CC2 = 2.9:0.01:6.1;
[X,Y] = meshgrid(CC1,CC2);
Q1 = (100).*(time - ((60*0.8)./Y))./((60./X)-(60./Y));
Q1(Q1<0) = NaN;
Q1(Q1>80) = NaN;
Q1_values = 5:10:75;

plot_ind = 1:numBat;
plot_ind(skip_ind) = [];
max_Q = max(ypred(plot_ind)) + 1;
min_Q = min(ypred(plot_ind)) - 1;

figure('units','normalized','outerposition',[0 0 1 1]);
hold on, box on, axis square
for i = 1:numBat
    if i == 1
        colormap 'jet'
        contour(X,Y,Q1,Q1_values,'k','LineWidth',2,'ShowText','on')
        axis([2.9 6.1 2.9 6.1])
    end
    if sum(i == skip_ind)
    else
        color_ind = ceil((ypred(i) - min_Q)./(max_Q - min_Q)*64);
        scatter(p1(i),p2(i),'ro','filled','CData',CM(color_ind,:),'SizeData',170)
    end
    
end
xlabel('C1','FontSize',20), ylabel('C2','FontSize',20)
title('Predictions (points jittered)')
h = colorbar;
title(h, {'Predicted','cycle life'},'FontWeight','bold')
tl = linspace(round(min_Q),round(max_Q),71);
h.TickLabels = tl(10:10:70);
set(gca,'fontsize',18)

cd(path.images), cd(batch_name)
print('summary6_predictions', '-dpng')
savefig(gcf,'summary6_predictions.fig')
cd(path.code)

close all

disp('Completed apply_model'),toc

end