function make_summary_gifs(batch, batch_name, T_cells, T_policies)
% make_summary_gifs makes the summary gifs for each batch. Since each
% batch will have different 'best' ways of presenting data, we use
% conditional statements to identify which to use

disp('Starting make_summary_gifs'), tic

%% CHANGE THESE SETTINGS - development mode
filename = ['Qnplot_' batch_name '.gif']; % Specify the output file name
endcycle = 1000; % Last cycle plotted

%% Move to GIF directory
cd 'C:\Users\Arbin\Box Sync\Data\Batch GIFS\'

%% Preinitialize random colors and markers
n_cells = height(T_cells);
n_policies = height(T_policies);

cols = cell(1,n_policies);
marks = cell(1,n_policies);
for i = 1:n_policies
    [col, mark]=random_color('y','y');
    cols{i} = col;
    marks{i} = mark;
end

%% Find all unique policies
policies = cell(n_cells,1);
readable_policies = cell(n_cells,1);
for i = 1:n_cells
    policies{i} = batch(i).policy;
    readable_policies{i}=batch(i).policy_readable;
end
unique_policies = unique(policies);
unique_readable_policies = unique(readable_policies);

%% Create 'Q' array - cell array of cell arrays
% Q = 1xn cell, where n = number of policies
% Q{1,1} = 1xm cell, where m = number of cells tested for this policy
Q = cell(1,n_policies); 
for i = 1:n_policies % loop through all policies
    for j = 1:n_cells
        if strcmp(unique_policies{i}, batch(j).policy)
            Q{i} = {Q{i} batch(j).summary.QDischarge};
        end
    end
end

%% Make full screen figure
figure('units','normalized','outerposition',[0 0 1 1]), box on
xlabel('Cycle number')
ylabel('Remaining discharge capacity (Ah)')
axis([0 1000 0.85 1.15])
set(gcf, 'Color' ,'w')
hline(0.88)
leg = columnlegend(2,unique_readable_policies,'Location','NortheastOutside','boxoff');

%% Begin looping. j = cycle index
for j=1:endcycle
    % i = policy index
    for i=1:n_policies        
        %% Plot each policy 
        hold on
        
        cycles = j.*ones(1,length(Q{i}));
        Qn = zeros(1,length(Q{i})); % preinitialize capacity at cycle n (Qn)
        Qend = zeros(1,length(Q{i})); % preinitialize capacity at cycle n (Qn)
        % k = index of cells within a policy
        for k = 1:length(Q{i})
            % If cell has died, we won't have data at this cycle number.
            % Just plot the last cycle
            if length(Q{i}{k}) < j
                Qn(k) = Q{i}{k}(end);
            else
                Qn(k) = Q{i}{k}(j);
            end
            
            Qend(k) = Q{i}{k}(end);
        end
        
        % Plot points for this policy
        scatter(cycles,Qn2,100,cols{i},marks{i},'LineWidth',1.5);
    end
    % Misc plotting stuff
    title(['Cycle ' num2str(j)])
    hold off
    
    % Create GIF
    drawnow
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if j == 1
        imwrite(imind,cm,filename,'gif','Loopcount',1);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.03);
    end
end


figAbsolute = figure('units','normalized','outerposition',[0 0 1 1]); hold on, box on
for i = 1:length(unique_policies)
    % Keep consistent color
    [col, mark] = random_color('y','y');
    %All the markers we want to use
    markers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
    % Find all cells with policy i, generate combined x,y
    x=double.empty;
    y=double.empty;
    for j = 1:numel(batch)
        if strcmp(unique_policies{i}, batch(j).policy)
            x = cat(2,x,batch(j).summary.cycle);
            y = cat(2,y,batch(j).summary.QDischarge);
        end
    end
    figure(figAbsolute);
    plot(x,y,markers{mod(j,numel(markers))+1},'color',col);
end

% %% Make different summary plots for each batch
% % Batch 1 (2017-05-12)
% if batch_name == 'batch1'
%     batch1_summary_plots(batch, batch_name, T_cells, T_policies)
% % Batch 2 (2017-06-30)
% elseif batch_name == 'batch2'
%     batch2_summary_plots(batch, batch_name, T_cells, T_policies)
% else
%     warning('Batch name not recognized. No summary figures generated')
% end

close all
cd 'C:/Users/Arbin/Documents/GitHub/BMS-autoanalysis'

disp('Completed make_summary_gifs'),toc

end