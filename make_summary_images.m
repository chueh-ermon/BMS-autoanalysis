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
    x=double.empty;
    y=double.empty;
    for j = 1:numel(batch)
        if strcmp(unique_policies{i}, batch(j).policy)
            disp(size(x)),disp(size(y))
            x = cat(2,x,batch(j).summary.cycle');
            y = cat(2,y,batch(j).summary.QDischarge');
        end
    end
    sortedy = sort(y,'descend');
    normalizationValue = sortedy(3);
    figure(figAbsolute);
    plot(x,y,markers{mod(i,numel(markers))+1},'color',col);
    figure(figNormalized);
    plot(x,y./normalizationValue,markers{mod(i,numel(markers))+1},'color',col);
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
ylabel('Remaining discharge capacity (normalized)')
if strcmp(batch_name, 'batch1') || strcmp(batch_name, 'batch2') || strcmp(batch_name, 'batch4')
    ylim([0.8 1])
elseif contains(batch_name,'oed')
    ylim([0.99 1])
end
%2-column legend via custom function. Not perfect but workable
columnlegend(2,unique_readable_policies,'Location','NortheastOutside','boxoff');
print('summary2_Q_vs_n_norm','-dpng')
savefig(gcf,'summary2_Q_vs_n_norm')

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
elseif contains(batch_name,'oed')
    table_path = [path.result_tables '\' date '_' batch_name '_predictions.csv'];
    python('oed_plots.py',table_path,path.images,batch_name);
else
    warning('Batch name not recognized. No summary figures generated')
end


close all
cd(path.code)
disp('Completed make_summary_images'),toc

end