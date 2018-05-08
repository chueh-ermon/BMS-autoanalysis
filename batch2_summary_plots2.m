function batch2_summary_plots2(T_policies)
%% Function: takes in tabular data to generate contour plots of results
% Usage: batch3_summary_plots(batteries [struct],'batch_2' [str], T_cells [table],T_policies [table])
% August 2017 Michael Chen & Peter Attia
% 
% Plot needs fixing because of artifacts

%% Initialization and inputs
T_size = height(T_policies);
time = 10; % target time of policies, in minutes
T_policies.Properties.VariableNames{1} = 'CC1';
T_policies.Properties.VariableNames{2} = 'Q1';
T_policies.Properties.VariableNames{3} = 'CC2';
T_policies.Properties.VariableNames{7} = 'cycles';
T_policies.Properties.VariableNames{8} = 'degrate';

%% Initialize plot 1: color = Q1
contour1 = figure; % x = CC1, y = CC2, contours = Q1
colormap parula;
colormap(flipud(colormap));
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) % resize for screen
set(gcf,'color','w') % make figures white
hold on, box on, axis square
CC1 = 2.9:0.01:6.1;
CC2 = 2.9:0.01:6.1;
[X,Y] = meshgrid(CC1,CC2);
Q1 = (100).*(time - ((60*0.8)./Y))./((60./X)-(60./Y));
Q1(Q1<0) = NaN;
Q1(Q1>80) = NaN;
Q1_values = 5:10:75;
axis([2.9 6.1 2.9 6.1])

% plot contour values for plot 1
contour(X,Y,Q1,Q1_values,'LineWidth',2,'ShowText','on')

title(['Time to 80% = ' num2str(time) ' minutes'],'FontSize',20)
set(gca,'FontSize',18)
xlabel('C1','FontSize',20),ylabel('C2','FontSize',20)
h = colorbar; title(h, 'Q1 (%)','FontWeight','bold')
caxis([0 80])

for i = 1:T_size
    if T_policies.Q1(i) == 80
        if T_policies.CC1(i) == 4.8
            scatter(T_policies.CC1(i),T_policies.CC2(i),'rsquare', 'filled', ...
                'CData',[0 0 0],'SizeData',250)
        end
    else
        scatter(T_policies.CC1(i),T_policies.CC2(i),'ro', 'filled', ...
            'CData',[0 0 0],'SizeData',250)
    end
end



%% Initialize plot 2 - color = cycle life
contour2 = figure; % x = CC1, y = CC2, contours = Q1
colormap jet;
colormap(flipud(colormap));
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) % resize for screen
set(gcf,'color','w') % make figures white
hold on, box on, axis square
axis([2.9 6.1 2.9 6.1])

% plot contour values for plot 2
contour(X,Y,Q1,Q1_values,'k','LineWidth',2,'ShowText','on')

title(['Time to 80% = ' num2str(time) ' minutes'],'FontSize',20)
set(gca,'FontSize',18)
xlabel('C1','FontSize',20),ylabel('C2','FontSize',20)
h = colorbar; title(h, 'Cycle Life','FontWeight','bold')

for i = 1:T_size
    if T_policies.Q1(i) == 80
        if T_policies.CC1(i) == 4.8
            scatter(T_policies.CC1(i),T_policies.CC2(i),'rsquare', 'filled', ...
                'CData',T_policies.cycles(i),'SizeData',250)
        end
    else
        scatter(T_policies.CC1(i),T_policies.CC2(i),'ro', 'filled', ...
            'CData',T_policies.cycles(i),'SizeData',250)
    end
end

%% Initialize plot 3 - color = deg rate
contour3 = figure; % x = CC1, y = CC2, contours = Q1
colormap jet;
colormap(flipud(colormap));
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) % resize for screen
set(gcf,'color','w') % make figures white
hold on, box on, axis square
axis([2.9 6.1 2.9 6.1])

% plot contour values for plot 2
contour(X,Y,Q1,Q1_values,'k','LineWidth',2,'ShowText','on')

title(['Time to 80% = ' num2str(time) ' minutes'],'FontSize',20)
set(gca,'FontSize',18)
xlabel('C1','FontSize',20),ylabel('C2','FontSize',20)
h = colorbar; title(h, 'Degradation rate (Ah/cycle)','FontWeight','bold')
caxis([0 max(T_policies.degrate)])

for i = 1:T_size
    if T_policies.Q1(i) == 80
        if T_policies.CC1(i) == 4.8
            scatter(T_policies.CC1(i),T_policies.CC2(i),'rsquare', 'filled', ...
                'CData',T_policies.degrate(i),'SizeData',250)
        end
    else
        scatter(T_policies.CC1(i),T_policies.CC2(i),'ro', 'filled', ...
            'CData',T_policies.degrate(i),'SizeData',250)
    end
end

%% Save files
saveas(contour1, 'summary3_contour1.png')
savefig(contour1,'summary3_contour1.fig')

saveas(contour2, 'summary4_contour2.png')
savefig(contour2,'summary4_contour2.fig')

saveas(contour3, 'summary5_contour3.png')
savefig(contour3,'summary5_contour3.fig')

% %% Close all figure windows
% close all

end
