function make_summary_images(batch, batchname)
% make_summary images makes the summary images for each batch. Since each
% batch will have different 'best' ways of presenting data, 


%% Q vs n


%% Make plots for 
if batchdate == 'batch1'
    %% Capacity vs time
    
    %% Average degradation vs time
    
    xlabel('Time to 80% SOC (minutes)')
    ylabel('Degradation rate')
elseif batchdate == 'batch2'
    %% Contour plots
    
else
    warning('Batch name not recognized')
end

end