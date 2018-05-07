function [X] = build_battery_features(batch)
% This function builds the possible feature set for the model.
% Kristen Severson, Peter Attia
% Last updated May 4, 2018

%If you add candidate features, update this number for better memory
%management
numFeat = 24;

numBat = size(batch,2);
X = zeros(numBat,numFeat);

for i = 1:numBat
    %Capacity features
    %Initial capacity
    X(i,1) = batch(i).summary.QDischarge(2);
    %Max change in capacity
    X(i,2) = max(batch(i).summary.QDischarge(1:100))...
        - batch(i).summary.QDischarge(2);
    %capacity at cycle 100
    X(i,3) = batch(i).summary.QDischarge(100);
    
    %Linear fit of Q v. N
    R3 = regress(batch(i).summary.QDischarge(2:100),[2:100;ones(1,length(2:100))]');
    X(i,4) = R3(1);
    X(i,5) = R3(2);
    
    %Linear fit of Q v. N, only last 10 cycles
    R1 = regress(batch(i).summary.QDischarge(91:100),[91:100;ones(1,length(91:100))]');
    X(i,6) = R1(1);
    X(i,7) = R1(2);
    
    %Q features
    QDiff = batch(i).cycles(100).Qdlin - batch(i).cycles(10).Qdlin;
    
    X(i,8) = log10(abs(min(QDiff)));
    X(i,9) = log10(abs(mean(QDiff)));
    X(i,10) = log10(abs(var(QDiff)));
    X(i,11) = log10(abs(skewness(QDiff)));
    X(i,12) = log10(abs(kurtosis(QDiff)));
    X(i,13) = log10(abs(QDiff(1)));
    
    %Temperature features
    Temp_time = 0;
    for j = 2:100
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
        %I left this in in case you want to threshold for a certain
        %temperature, right now it doesn't do anything because the
        %temperature never drops below 20
        hot_ind = find(batch(i).cycles(j).T > 20);
        break_ind = find(diff(hot_ind) ~= 1);
        
        calc_ind = 1;
        for iii = 1:length(break_ind)
            calc_ind = [calc_ind, break_ind(iii), break_ind(iii) + 1];
        end
        calc_ind = [calc_ind, length(hot_ind)];
        
        for iii = 1:length(calc_ind)/2
            Temp_time = Temp_time + ...
                sum(1/2*diff(batch(i).cycles(j).t(hot_ind(calc_ind(2*iii - 1):calc_ind(2*iii)))).*...
                (batch(i).cycles(j).T(hot_ind(calc_ind(2*iii - 1):calc_ind(2*iii)-1)) + ...
                batch(i).cycles(j).T(hot_ind(calc_ind(2*iii - 1)+1:calc_ind(2*iii)))));
        end
        
    end
    X(i,14) = Temp_time;
    
    X(i,15) = max(batch(i).summary.Tmax(1:100));
    X(i,16) = min(batch(i).summary.Tmin(2:100));
    
    %Time features
    X(i,17) = mean(batch(i).summary.chargetime(2:6));

    % IR features
    IR_trend = batch(i).summary.IR(2:100);
    if any(IR_trend == 0)
        IR_trend(IR_trend == 0) = NaN;
    end
    
    X(i,18) = min(IR_trend);
    X(i,19) = batch(i).summary.IR(2);
    X(i,20) = batch(i).summary.IR(100) - batch(i).summary.IR(2);
    
    % Peter's proposed features
    
    % Max charging temperature for cycle 10
    X(i,21) = max(batch(i).cycles(10).T((batch(i).cycles(10).I > 0)));
    
    % Max discharging temperature for cycle 10
    X(i,22) = max(batch(i).cycles(10).T((batch(i).cycles(10).I < 0)));
    
    % Sum of Qdiff
    X(i,23) = log10(sum(abs(QDiff)));
    
    % Sum of Qdiff^2
    X(i,24) = log10(sum(QDiff.^2));

end %end loop through batteries


end