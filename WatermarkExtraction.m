close all
clear all

codedDataLength = 32;
X = 6;
Y = 6;

M=50;
Ms=1;

vid = VideoReader('rhinoceros.avi');
numFrames = vid.NumFrames;
vid.CurrentTime = 0;
video = read(vid);

%figure;
%ax = axes;
%ax2 = axes;
%ax3 = axes;

%open(Wvideo);

vidW = vid.Width;
vidH = vid.Height;

blW = floor(vidW/X);
blH = floor(vidH/Y);

means = zeros(Ms+M-1,1);


%video = video(:,:,3,:);

for frame=Ms:(Ms+M-1)
    %cFrame = int16(im2uint8(read(vid,frame))); 
    %cFrame = cFrame(:,:,3);
    %nFrame = int16(im2uint8(read(vid,frame+1)));
    %nFrame = nFrame(:,:,3);
    dFr = int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));
    means(frame) = mean(abs(dFr),'all');  
    %imshow(uint8(dFr)*8,'Parent',ax);
    %imshow(cFrame,'Parent',ax2);
    %imshow(nFrame,'Parent',ax3);
    %pause(0.1/vid.FrameRate);
end

[means,I] = sort(means,'descend');

dataMat = zeros(round((Ms+M-1)/2),codedDataLength);

for frame=Ms:(round((Ms+M-1)/2))
    
    %cFrame = int16(im2uint8(read(vid,frame))); 
    %cFrame = cFrame(:,:,3);
    %nFrame = int16(im2uint8(read(vid,frame+1)));
    %nFrame = nFrame(:,:,3);
    %dFrame = cFrame - nFrame;

    dFr = int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));
    
    i=0;
    j=0;
    mn=0;
    mn = mn + mean(dFr((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))),'all');
    i=0;
    j=Y-1;
    mn = mn + mean(dFr((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))),'all');
    i=X-1;
    j=0;
    mn = mn + mean(dFr((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))),'all');
    i=X-1;
    j=Y-1;
    mn = mn + mean(dFr((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))),'all');
    
    
    bit = 1;
    if mn > 0
        for j=0:(Y-1)
            for i=0:(X-1)
                if (i==0 && j== 0)||(i==X-1 && j== 0)||(i==0 && j== Y-1)||(i==X-1 && j== Y-1)
                    
                else
                    if mean(dFr((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))),'all')>0
                        dataMat(frame,bit)= 1;
                    else
                        dataMat(frame,bit)= 0;
                    end
                    bit=bit+1;
                end           
            end 
        end 
    else
        for j=0:(Y-1)
            for i=0:(X-1)
                if (i==0 && j== 0)||(i==X-1 && j== 0)||(i==0 && j== Y-1)||(i==X-1 && j== Y-1)
                else
                    if mean(dFr((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))),'all')<0
                        dataMat(frame,bit)= 1;
                    else
                        dataMat(frame,bit)= 0;
                    end
                    bit=bit+1;
                end
                
            end 
        end 
    end
end

codedDataExtr = zeros(1,codedDataLength);

for bit=1:codedDataLength
    for frame=Ms:(round((Ms+M-1)/2))
        codedDataExtr(1,bit) = codedDataExtr(1,bit) + dataMat(frame,bit);
    end
    
    if codedDataExtr(1,bit)>round((Ms+M-1)/4)
        codedDataExtr(1,bit)=1;
    else
        codedDataExtr(1,bit)=0;
    end
end
    
ConvDecoding;
%codedData
codedDataExtr
decodedData
%data = [1,1,1,1,0,0,0,0,1,1,1,1,0,1,0,0]
%biterr(data,decodedData)