%This code does the wall filtering from the time-domain
clc;
clear all;
close all;
%datafolder = '/media/thnguyn2/Elements/QDIC_Embryos/fancymovies/forPPT/dynamics/'
%datafolder = '/run/media/daniel/Elements/QDIC_Embryos/fancymovies/forPPT/dynamics';
datafolder = '/raid5/Mikhail/QDIC_Embryos/fancymovies/dynamics/';
utilpath = strcat(pwd,'/utils/');
addpath(utilpath);
fov_arr =1:33;
nfovs = length(fov_arr);
min_out=-24;
max_out=0;
for fovidx = 1:nfovs
    curfile_name = strcat(datafolder,'MOV_',num2str(fov_arr(fovidx)),'_0_1_0_QDIC.tif');
    curoutfile_name = strcat(datafolder,'MOV_',num2str(fov_arr(fovidx)),'_0_1_0_QDIC_out.avi');
    if (~exist(curfile_name,'file'))
        error(strcat('File: ',curfile_name,' does not exist. Please double check!!!'))
    else
        finfo = imfinfo(curfile_name);
        Nt = length(finfo); %Get the number of frames
        frame1 = imread(curfile_name);
        Nr = size(frame1,1);
        Nc = size(frame1,2);
        frames = zeros(Nr,Nc,Nt);
        for frameidx = 1:Nt
            disp(['Reading frame: ' num2str(frameidx)]);
            frames(:,:,frameidx)=imread(curfile_name,frameidx);
        end
        frames = cast(frames,'single');%Read all the frames
        frames = squeeze(frames(1:1:end,1:1:end,:)); %Downsampling
        ss = 3; %Steady stead
        ord = ceil((Nt-2)/8); % order of filter;
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
        outdata = reshape(outdata,size(frames));
        outframes = 20*log10(abs(outdata));
        filt_len=8;
        outVideoObj = VideoWriter(curoutfile_name);
        open(outVideoObj);
        disp('Writing the Video...')
        for frameidx = 1:Nt
            disp(['Final processing frame: ' num2str(frameidx)]);
            outframes(:,:,frameidx) = ((outframes(:,:,frameidx)-min_out)/(max_out-min_out));%Map the output to [min_out, max_out] range
            mask = cast((outframes(:,:,frameidx)>=0),'single');
            invmask = 1.0-mask;
            outframes1= outframes(:,:,frameidx).*mask;
            outframes(:,:,frameidx) = conv2(outframes1,ones(filt_len)/filt_len^2,'same');
           
            %Create a 3 color image
            tempim = zeros(Nr,Nc,3);
            tempim(:,:,1) = (frames(:,:,frameidx)+1.0)*128;
            tempim(:,:,2) = (frames(:,:,frameidx)+1.0)*128;
            tempim(:,:,3) = (frames(:,:,frameidx)+1.0)*128;
            outframes3c = grs2rgb(cast(outframes(:,:,frameidx)*255,'uint8'))*255.0;
            writedata =     cast(repmat(invmask,[1 1 3]),'double').*tempim+repmat(mask,[1 1 3]).*outframes3c;
            writeVideo(outVideoObj,cast(writedata,'uint8'));
        end
        disp(['Done writing ' curoutfile_name '...']);
        close(outVideoObj);
    end
  
end
