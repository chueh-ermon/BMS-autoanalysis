function make_summary_gifs(batch, batch_name)
% make_summary_gifs makes the summary gifs for each batch. Since each
% batch will have different 'best' ways of presenting data, we use
% conditional statements to identify which to use

disp('Starting make_summary_gifs'), tic

%% ONLY FOR BATCH 1
% for i = 1:numel(batch)
%     batch(i).summary.QDischarge = batch(i).summary.QDischarge(2:end);
% end
%%

%% CHANGE THESE SETTINGS - development mode
filename = ['Qnplot_' batch_name '.gif']; % Specify the output file name
endcycle = 1000; % Last cycle plotted

%% Move to GIF directory
%cd 'C:\Users\Arbin\Box Sync\Data\Batch GIFS\'

%% Find all unique policies
n_cells = numel(batch);
policies = cell(n_cells,1);
readable_policies = cell(n_cells,1);
for i = 1:n_cells
    policies{i} = batch(i).policy;
    readable_policies{i}=batch(i).policy_readable;
end
unique_policies = unique(policies);
unique_readable_policies = unique(readable_policies);
n_policies = numel(unique_policies);

%% Preinitialize random colors and markers
cols = cell(1,n_policies);
marks = cell(1,n_policies);
for i = 1:n_policies
    [col, mark]=random_color('y','y');
    cols{i} = col;
    marks{i} = mark;
end

%% Create 'Q' array - cell array of cell arrays
% Q = 1xn cell, where n = number of policies
% Q{1,1} = 1xm cell, where m = number of cells tested for this policy
Q = cell(1,n_policies);
for i = 1:n_policies % loop through all policies
    numcells = 0;
    for j = 1:n_cells % cell index
        if strcmp(unique_policies{i}, batch(j).policy)
            numcells = numcells + 1;
        end
    end
    Q{i} = cell(1,numcells);
    
    j = 1; % cell index
    k = 1; % cell = policy index
    while k < numcells + 1
        if strcmp(unique_policies{i}, batch(j).policy)
            Q{i}(k) = {batch(j).summary.QDischarge};
            k = k + 1;
        end
        j = j + 1;
    end
end

%% Make full screen figure
figure('units','normalized','outerposition',[0 0 1 1]), box on
xlabel('Cycle number')
ylabel('Remaining discharge capacity (Ah)')
axis([0 1000 0.80 1.2])
set(gcf, 'Color' ,'w')
hline(0.88)

%% Begin looping. j = cycle index
for j=1:endcycle
    % i = policy index
    for i=1:n_policies        
        %% Plot each policy 
        hold on
        
        cycles = j.*ones(1,length(Q{i}));
        Qn = zeros(1,length(Q{i})); % preinitialize capacity at cycle n (Qn)
        % k = index of cells within a policy
        for k = 1:length(Q{i})
            % If cell has died, we won't have data at this cycle number.
            % Just plot the last cycle
            if length(Q{i}{k}) < j
                Qn(k) = Q{i}{k}(end);
            else
                Qn(k) = Q{i}{k}(j);
            end
        end
        
        % Plot points for this policy
        scatter(cycles,Qn,100,cols{i},marks{i},'LineWidth',1.5);
    end
    % Misc plotting stuff
    title(['Cycle ' num2str(j)])
    %leg = columnlegend(2,unique_readable_policies,'Location','NortheastOutside','boxoff');
    leg = legend(unique_readable_policies','Location','EastOutside');
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
%cd 'C:/Users/Arbin/Documents/GitHub/BMS-autoanalysis'

disp('Completed make_summary_gifs'),toc

end