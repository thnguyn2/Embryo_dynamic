function res = feat_comp(datablock,type,params)
%Compute the std of the measurement of a single avi for 1 FOV and 1 time
%stamp
    switch (type{1})
        case {'spatial_std'} % Compute mean temporal standard deviation of all pixels 1/N*mean(std(i)) where i is the pixel indices
            mean_arr = mean(mean(datablock,1),2); %Mean value in the x and y
            nrows = size(datablock,1);
            ncols = size(datablock,2);
            err_block = cast(datablock,'double') - cast(repmat(mean_arr,[nrows ncols 1]),'single');            
            res = squeeze(sqrt(sum(sum(err_block.^2,1),2)/(nrows*ncols)));
        case {''} % Compute mean temporal standard deviation of all pixels 1/N*mean(std(i)) where i is the pixel indices
           
        %New ideas: wall filtering...and compute the high frequency
        %component....should be good for 
        otherwise
            disp(['Unknown feature type: ', num2str(type)' , ' please double check']);
    end
