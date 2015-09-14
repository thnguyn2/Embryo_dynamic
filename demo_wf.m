%This code does the wall filtering from the time-domain
clc;
clear all;
close all;
%datafolder = '/media/thnguyn2/Elements/QDIC_Embryos/fancymovies/forPPT/dynamics/'
datafolder = '/run/media/daniel/Elements/QDIC_Embryos/fancymovies/forPPT/dynamics/';
utilpath = strcat(pwd,'/utils/');
addpath(utilpath);
fov_arr =[3,12,19];
nfovs = length(fov_arr);
min_out=18;
max_out=40;
for fovidx = 1:nfovs
    curfile_name = strcat(datafolder,num2str(fov_arr(fovidx)),'_int.avi');
    curoutfile_name = strcat(datafolder,num2str(fov_arr(fovidx)),'_int_out.avi');
    if (~exist(curfile_name,'file'))
        error(strcat('File: ',curfile_name,' does not exist. Please double check!!!'))
    else
        v=VideoReader(curfile_name);
        frames = cast(squeeze(read(v)),'single');%Read all the frames
        frames = squeeze(frames(1:1:end,1:1:end,1,:));
        Nr = size(frames,1);
        Nc = size(frames,2);
        Nt = size(frames,3);
        ss = 1; %Steady stead
        ord = 50;
        WF = zeros(Nt);
        WF(ss:end,ss:end)=wallfilter(Nt-ss+1,ord);
        disp('Median filtering to get rid of the spatial noise');
        %Spatially filter out the noise with median filtering
        for frameidx = 1:Nt
            frames(:,:,frameidx)=medfilt2(frames(:,:,frameidx));
        end
        disp('Wall filtering the result')
        indata = reshape(frames,Nr*Nc,Nt);
        outdata = indata*WF;%Wall filtering
        outframes = (abs(reshape(outdata,Nr,Nc,Nt)));
        outframes = 20*log10(outframes);
        filt_len=8;
        outVideoObj = VideoWriter(curoutfile_name);
        open(outVideoObj);
        disp('Writing the Video...')
        for frameidx = 1:Nt
            outframes(:,:,frameidx) = conv2(outframes(:,:,frameidx),ones(filt_len)/filt_len^2,'same');
            outframes(:,:,frameidx) = (outframes(:,:,frameidx)-min_out)/(max_out-min_out);%Map the output to [min_out, max_out] range
            
            %Create a 3 color image
            tempim = zeros(Nr,Nc,3);
            tempim(:,:,1) = frames(:,:,frameidx);
            tempim(:,:,2) = frames(:,:,frameidx);
            tempim(:,:,3) = frames(:,:,frameidx);
            outframes3c = grs2rgb(cast(outframes(:,:,frameidx)*255,'uint8'))*255;
            writedata = repmat((squeeze(outframes(:,:,frameidx))>=0),[1 1 3]).*outframes3c +...
                repmat((squeeze(outframes(:,:,frameidx))<0),[1 1 3]).*tempim;
            writeVideo(outVideoObj,cast(writedata,'uint8'));
        end
        disp(['Done writing ' curoutfile_name '...']);
        close(outVideoObj);
    end
  
end
