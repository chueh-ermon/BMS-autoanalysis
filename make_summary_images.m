function make_summary_images(batch, batch_name, T_cells, T_policies)
% make_summary images makes the summary images for each batch. Since each
% batch will have different 'best' ways of presenting data, have
% conditional statements to identify which to use

disp('Starting make_summary_images'), tic

load path.mat

%% Move to image directory
cd (strcat(path.images, '\', batch_name))

%% Q vs n for each policy
policies = cell(height(T_cells),1);
readable_policies = cell(height(T_cells),1);
for i = 1:numel(batch)
    policies{i} = batch(i).policy;
    readable_policies{i}=batch(i).policy_readable;
end
disp(policies)
unique_policies = unique(policies);
unique_readable_policies = unique(readable_policies);

%Two figures, absolute and normalized. We switch between the two as we
%plot and format the images
figAbsolute = figure('units','normalized','outerposition',[0 0 1 1]); hold on, box on
set(gca, 'FontSize', 16)
figNormalized = figure('units','normalized','outerposition',[0 0 1 1]); hold on, box on
set(gca, 'FontSize', 16)

% Loop through
for i = 1:length(unique_policies)
    % Keep consistent color
    [col, ~] = random_color('y','y');
    %All the markers we want to use
    markers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
    % Find all cells with policy i, generate combined x,y
    x=cell(0);
    y=cell(0);
    
    k = 1;
    for j = 1:numel(batch)
        if strcmp(unique_policies{i}, batch(j).policy)
            x{k} = batch(j).summary.cycle;
            y{k} = batch(j).summary.QDischarge;
            
            figure(figAbsolute);
            plot(x{k},y{k},markers{mod(i,numel(markers))+1},'color',col);
            figure(figNormalized);
            plot(x{k},y{k}./y{k}(1),markers{mod(i,numel(markers))+1},'color',col);
            k = k + 1;
        end
    end
end

%Formatting of figures
figure(figAbsolute);
xlabel('Cycle number')
ylabel('Remaining discharge capacity (Ah)')
if strcmp(batch_name, 'batch1') || strcmp(batch_name, 'batch2') || strcmp(batch_name, 'batch4')
    ylim([0.85 1.1])
elseif contains(batch_name,'oed')
    ylim([1.0 1.1])
else
    ylim([0.85 1.25])
end
%2-column legend via custom function. Not perfect but workable
columnlegend(2,unique_readable_policies,'Location','NortheastOutside','boxoff');
print('summary1_Q_vs_n','-dpng')
savefig(gcf,'summary1_Q_vs_n')

figure(figNormalized);
xlabel('Cycle number')
ylabel('Remaining discharge capacity (normalized by initial capacity)')
if strcmp(batch_name, 'batch1') || strcmp(batch_name, 'batch2') || strcmp(batch_name, 'batch4')
    ylim([0.8 .011])
elseif contains(batch_name,'oed')
    ylim([0.99 1.01])
end
%2-column legend via custom function. Not perfect but workable
columnlegend(2,unique_readable_policies,'Location','NortheastOutside','boxoff');
print('summary2_Q_vs_n_norm','-dpng')
savefig(gcf,'summary2_Q_vs_n_norm')

% Delta Q plot
fig_deltaQ = figure('units','normalized','outerposition',[0 0 1 1]); hold on, box on
min_cycles_completed = 1000;
for k = 1:length(batch)
    min_cycles_completed = min(length(batch(k).cycles),min_cycles_completed);
end
for k = 1:length(batch)
    if min_cycles_completed < 10
        try
        plot(batch(k).cycles(min_cycles_completed).Qdlin - batch(k).cycles(2).Qdlin, batch(k).Vdlin);
        xlabel(['Q_{',num2str(min_cycles_completed),'} - Q_{2} (Ah)'])
        catch
        end
    else
        plot(batch(k).cycles(min_cycles_completed).Qdlin - batch(k).cycles(10).Qdlin, batch(k).Vdlin);
        xlabel(['Q_{',num2str(min_cycles_completed),'} - Q_{10} (Ah)'])
    end
end
set(gca, 'FontSize', 16)
ylabel('Voltage (V)')
%2-column legend via custom function. Not perfect but workable
columnlegend(2,unique_readable_policies,'Location','NortheastOutside','boxoff');
print('summary3_DeltaQ','-dpng')
savefig(gcf,'summary3_DeltaQ')

%% Make different summary plots for each batch
batches_likebatch2 = {'batch2','batch4','batch5','batch6','batch7','batch8'};
% Batch 1 (2017-05-12)
if strcmp(batch_name, 'batch1')
    batch1_summary_plots(batch, batch_name, T_cells, T_policies)
% Batch 2 and similar
elseif sum(strcmp(batch_name, batches_likebatch2))
    batch2_summary_plots2(T_policies)
% Batch 3 (2017-08-14)
elseif strcmp(batch_name,'batch3')
    batch3_summary_plots(T_policies)
% OED batches
elseif contains(batch_name,'oed') || strcmp(batch_name,'batch9')
    table_path = [path.result_tables '\' date '_' batch_name '_predictions.csv'];
    python('oed_plots.py',table_path,path.images,batch_name);
else
    warning('Batch name not recognized. Additional summary figures not generated')
end

close all
cd(path.code)
disp('Completed make_summary_images'),toc

end