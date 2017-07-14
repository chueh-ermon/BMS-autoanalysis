function batch2_summary_plots(batch, batch_name, T_cells, T_policies)
%% Function: takes in tabular data to generate contour plots of results
% Usage: batch2_summary_plots(batteries [struct],'batch_2' [str], T_cells [table],T_policies [table])
% July 2017 Michael Chen
% 
% Plot needs fixing because of artifacts

%% Initialization and inputs
T_policies = table2array(T_policies); % convert to array
% T_cells = table2array(T_cells); % convert to array (not really needed)
T_size = size(T_policies);
time = 10; % target time of policies, in minutes
colormap jet;
scalefactor = 5e5; % factor to scale degradation rates by
maxvalue = max(T_policies(:,8))*scalefactor; % scale degradation rate


%% Initialize plot 1
contour1 = figure; % x = CC1, y = Q1, contours = CC2
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) % resize for screen
set(gcf,'color','w') % make figures white
hold on, box on
Q1=0.5:0.1:79.5;
CC1=1:0.02:6;
[X,Y] = meshgrid(CC1,Q1);
CC2 = ((time - (Y./100).*(60./X))./(60.*(0.8-(Y./100)))).^(-1);
CC2_values = T_policies(:,3); % creates vector of CC2 values

% plot contour values for plot 1
contour(X,Y,CC2,CC2_values,'LineWidth',2,'ShowText','on')
% scatter plot policies with performance data
for i = 1:T_size(1)
    if T_policies(i,2) == 80
            figure(contour1)
            scatter(T_policies(i,1),T_policies(i,2),'rsquare','CData',T_policies(i,8)*scalefactor,'SizeData',250,'LineWidth',5)
    else
            figure(contour1)
            scatter(T_policies(i,1),T_policies(i,2),'ro','CData',T_policies(i,8)*scalefactor,'SizeData',250,'LineWidth',5)
    end
    caxis([0 maxvalue])
end
xlabel('CC1'),ylabel('Q1 (%)')

% Cover bad region
line([1.02 4.75],[16.5 79], 'LineWidth',20,'color','w');

%% Save file
saveas(contour1, 'summary3_contour1.png')

%% Initialize plot 2
contour2 = figure; % x = CC1, y = CC2 contours = Q1
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) % resize for screen
set(gcf,'color','w') % make figures white
hold on, box on, axis square
CC1 = 1:0.1:8;
CC2 = 1:0.1:8;
[X,Y] = meshgrid(CC1,CC2);
Q1 = (100).*(time - ((60*0.8)./Y))./((60./X)-(60./Y));
Q1_values = 5:10:75;

% plot contour values for plot 2
contour(X,Y,Q1,Q1_values,'LineWidth',2,'ShowText','on')
for i = 1:T_size(1)
    if T_policies(i,2) == 80
            figure(contour2)
            scatter(T_policies(i,1),T_policies(i,3),'rsquare','CData',T_policies(i,8)*scalefactor,'SizeData',250,'LineWidth',5)
    else
            figure(contour2)
            scatter(T_policies(i,1),T_policies(i,3),'ro','CData',T_policies(i,8)*scalefactor,'SizeData',250,'LineWidth',5)
    end
    caxis([0 maxvalue])
end
xlabel('CC1'),ylabel('CC2')

%% Cover bad region
line([1 4.7],[1 4.7], 'LineWidth',20,'color','w')
line([4.9 8],[4.9 8], 'LineWidth',20,'color','w');

%% Save file
saveas(contour2, 'summary4_contour2.png')

end
