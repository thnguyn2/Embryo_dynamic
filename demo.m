%This source code calculate the dynamics of the embryos.
%Written by: Tan H. Nguyen
%University of illinois.edu
%Version: 1.0
%How to use:
% -Modify the fov-array below for what fov to be used.
% -Modify the fov_reupdate-array for what fov that needs to respecified the roi.
% -For each FOV that need FOC specification, the code click on the 2 points
% corresponding to the top left and bottom right of the FOV.
% -An Excel file file will be created for each core in the FOV folder, containing the coordinates of the
% ROI. It is named xx_roi where xx is the name of the fov. Inside xx_roi,
% the first column will contain the time, the next 4 columns will be [r1 r2 c1 c2]
% Excel file for each core. The structure of this file is as follow
% % -The results.xlxs file will be updated/created. This excel file contains all the
% measurement results as well as plotting. Row [100*featureIdx + fovIdx + 10]
% contains all the measurements for the for the fovSpecifed by fovIdx and
% feature identified by featureIdx. Row: 1-10 of this file contains the
% name of the feature.
% -The utils folder contains all the functions that are used to compute the
% metrics of all the fovs. They receive the name of the fov as will as 4
% coordinates specifying what ROIs will the calculation be done on.
clc;
clear all;
close all;
fov_arr = [9, 12];
fov_roi_reupdate = [9, 12];
datapath = '/media/thnguyn2/Elements/QDIC_Embryos/fancymovies/'
fovpath = strcat(pwd,'fovs/');
utilpath = strcat(pwd,'utils/');
nfovs = length(fov_arr(:));
fov_folder_prefix = 'jpegdic_';
time_arr = [15 25 43 61 73 91 111]; %Different point in which the time is specified

%%---ROI specifying----
ntime = length(time_arr(:));
for fovidx = 1:nfovs
    curfolder_name = strcat(datapath,fov_folder_prefix,num2str(fov_arr(fovidx)));
    fov_roi_name = strcat(fovpath,'fov_',num2str(fov_arr(fovidx)),'.xlsx');
    %Check for the existence of the excel file or it needs to be reupdated
    if ((~exist(fov_roi_name,'file'))||(ismember(fov_arr(fovidx),fov_roi_reupdate)))
        if (~exist(curfolder_name,'dir'))
            error(strcat('Folder: ',curfolder_name,' does not exist. Please double check!!!'))
        else
            for timeidx=1:ntime
                
            end
        end
    end
    
    
end