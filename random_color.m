function [ color, marker ] = random_color( color, marker )
%This function takes in either a yes for a random color, or a number 
% to give a random export. Nick Perkins

% All markers and colors
mark_array={'o','+','*','x','s','d','^','v','>','<','p','h'};
col_array={'y','m','c','r','g','b','w','k'};

% Random color
if color == 'y'
    i =randi(100);
    j =randi(100);
    k =randi(100);
    color=[i*.01, j*.01, k*.01];
elseif ischar(color) == 1
    display('Choose yes or give number corresponding to desired color')
elseif color <= 8
    color=col_array{color};
else
    i =randi(255);
    color=rand_color{i};
end 

% Random marker
if marker == 'y'
    i =randi(12);
    marker=mark_array{i};
elseif ischar(marker) ==1
    display('Choose yes or give number corresponding to desired marker')
elseif marker <= 12
    marker=mark_array{marker};
else
    i =randi(12);
    marker=mark_array{i};
end 

end

