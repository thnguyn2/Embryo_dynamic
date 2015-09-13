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
% the first column will contain the time value, the next 4 columns will be [r1 r2 c1 c2]
% Excel file for each core. The structure of this file is as follow
% % -The results.xlxs file will be updated/created. This excel file contains all the
% measurement results as well as plotting. Row [100*featureIdx + fovIdx + 10]
% contains all the measurements for the for the fovSpecifed by fovIdx an
% feature identified by featureIdx. Row: 1-10 of this file contains the
% name of the feature.
% -The utils folder contains all the functions that are used to compute the
% metrics of all the fovs. They receive the name of the fov as will as 4
% coordinates specifying what ROIs will the calculation be done on.
clc;
clear all;
close all;
fov_arr = [5, 9, 12, 19, 20, 23, 24, 25, 32, 33, 34, 55];
fov_roi_reupdate = [];
datapath = '/media/thnguyn2/Elements/QDIC_Embryos/fancymovies/'
fovpath = strcat(pwd,'/fovs/');
utilpath = strcat(pwd,'/utils/');
addpath(utilpath);
nfovs = length(fov_arr(:));
fov_folder_prefix = 'jpegdic_';
time_arr = [15 25 43 61 73 91 111 146 148 158 180 229 271]; %Different point in which the time is specified

%%---ROI specifying----
ntime = length(time_arr(:));
for fovidx = 1:nfovs
    curfolder_name = strcat(datapath,fov_folder_prefix,num2str(fov_arr(fovidx)));
    fov_roi_name = strcat(fovpath,'fov_',num2str(fov_arr(fovidx)),'.txt');
    %Check for the existence of the excel file or it needs to be reupdated
    if ((~exist(fov_roi_name,'file'))||(ismember(fov_arr(fovidx),fov_roi_reupdate)))
        if (~exist(curfolder_name,'dir'))
            error(strcat('Folder: ',curfolder_name,' does not exist. Please double check!!!'))
        else
            data_arr = zeros(0,5);
            fovdone = 0;
            for timeidx = 1:ntime
                videofilename = strcat(curfolder_name,'/',num2str(fov_arr(fovidx)),'_',num2str(time_arr(timeidx)),'_sin_timelapse.avi');
                if (~exist(videofilename,'file'))
                    error(strcat('Video: ',videofilename,' does not exist'));
                else
                    selectiondone = 0;
                    v = VideoReader(videofilename);
                    %Load the first frame
                    firstframe = read(v,1);
                    lastframe = read(v,Inf);
                    nrows = size(firstframe,1);
                    ncols = size(firstframe,2);
                    while ((~selectiondone)&(~fovdone))
                        figure(1);
                        subplot(2,1,1);imagesc(firstframe);colormap gray;drawnow;
                        subplot(2,1,2);imagesc(lastframe);colormap gray;drawnow;
                        figure(2);
                        imagesc(0.5*firstframe+0.5*lastframe);drawnow;
                        colormap gray;
                        title_str = strcat('FOV #',num2str(fovidx),', Time #', num2str(time_arr(timeidx)),'. Please click 2 locations inside the embryo');
                        title(title_str);
                        [x1,y1]=ginput(1);
                        if ((x1<=0)||(x1>ncols)||(y1<=0)||(y1>nrows))
                           fovdone = 1;
                           break;
                        end
                        figure(2);
                        hold on;
                        plot(x1,y1,'.r','LineWidth',3);drawnow;
                        [x2,y2]=ginput(1);
                        plot(x2,y2,'.r','LineWidth',3);drawnow;hold off;
                      
                        choice  = questdlg('Save ROI specified?','Yes','No');
                        if (strcmp(choice,'Yes'))
                            selectiondone = 1;  
                            data_arr(end+1,1)=time_arr(timeidx);
                            data_arr(end,2)=round(min(y1,y2));
                            data_arr(end,3)=round(max(y1,y2));
                            data_arr(end,4)=round(min(x1,x2));
                            data_arr(end,5)=round(max(x1,x2));
                        end
                     end                   
                end
            end
            %Save into the excel file
            csvwrite(fov_roi_name,data_arr);
            disp('Data saved: ');
            disp(['Done writting for FOV: ', num2str(fov_arr(fovidx))]);            
        end
    end
end

%Compute the dynamics of different FOVs
feat_type_arr = {'spatial_std'};
colorarr = 'rgbycm';
nframes_per_checkpoint = 15; %Number of frame between2 2 checkpoint
totaltimestepnum = 271;
for featidx = 1:length(feat_type_arr(:))
    feat_arr = zeros(nfovs,1+totaltimestepnum); %The first column is for the FOV index
    feat_file_name = strcat(pwd,'/results/',feat_type_arr{featidx},'.xlsx');
    figure(1);hold off;
    for fovidx = 1:nfovs
        feat_arr(fovidx,1)=fov_arr(fovidx);
        curfolder_name = strcat(datapath,fov_folder_prefix,num2str(fov_arr(fovidx)));
        fov_roi_name = strcat(fovpath,'fov_',num2str(fov_arr(fovidx)),'.txt');
        roi_coord = csvread(fov_roi_name);
        ntime = size(roi_coord,1);
        firsttimesteptowrite = 2;
        for timeidx = 1:(ntime)
            videofilename = strcat(curfolder_name,'/',num2str(fov_arr(fovidx)),'_',num2str(time_arr(timeidx)),'_qdic_timelapse.avi');
            if (~exist(videofilename,'file'))
                error(strcat('Video: ',videofilename,' does not exist'));
            else
              v = VideoReader(videofilename);
              params.r1 = roi_coord(timeidx,2);
              params.r2 = roi_coord(timeidx,3);
              params.c1 = roi_coord(timeidx,4);
              params.c2 = roi_coord(timeidx,5);
              frames = squeeze(read(v)); %Read the entire video
              datablock = frames(params.r1:params.r2,params.c1:params.c2,:);
              res = feat_comp(datablock,feat_type_arr(featidx));
              lasttimesteptowrite = firsttimesteptowrite + length(res)-1;
              feat_arr(fovidx,firsttimesteptowrite:lasttimesteptowrite) = res';
              firsttimesteptowrite = lasttimesteptowrite+1;    
            end
            disp(['Working on FOV: #' num2str(fovidx) ' at time: ' num2str(timeidx)]);
        end
        %Plot the features
        plot(feat_arr(fovidx,2:end),strcat('-',colorarr(mod(fovidx,length(colorarr))+1)));
        hold on;
        csvwrite(feat_file_name,feat_arr);
        
    end   
end
