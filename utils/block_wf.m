function outblock = block_wf(inblock)
%Wall filtering on the output block using the data from the input block
%All high frequency information that cannot be approximate by the d-degree
%polynomial will be retained.

%% Wall Filtering
Nd = size(inblock,3);
ss = 3; %steady-state
ord = ceil((Nd-3+1)/8); % order of filter
WF = zeros(Nd); %wallfilter
WF(ss:end,ss:end) = wallfilter(Nd-ss+1,ord);%A filter with very big elements on the diagonal
