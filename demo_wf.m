%This code does the wall filtering from the time-domain
clc;
clear all;
close all;
datafolder = '/media/thnguyn2/Elements/QDIC_Embryos/fancymovies/forPPT/dynamics/'
utilpath = strcat(pwd,'/utils/');
addpath(utilpath);
fov_arr =[3,12,19];
nfovs = length(fov_arr);
for fovidx = 1:nfovs
    curfile_name = strcat(datafolder,num2str(fov_arr(fovidx)),'_int.avi');
    if (~exist(curfile_name,'file'))
        error(strcat('File: ',curfile_name,' does not exist. Please double check!!!'))
    else
        v=VideoReader(curfile_name);
        frames = cast(squeeze(read(v)),'single');%Read all the frames
        frames = frames(:,:,1,:);
        framesout = block_wf(frames);
        
       
    end
  
end
