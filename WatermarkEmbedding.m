close all
clear all

S = 3;%watermarking strength
X = 6;
Y = 6;
data = [1,1,1,1,0,0,0,0,1,1,1,1,0,1,0,0];


ConvCoding; %creates codedData

%factor = 1;
%powerDiff = 0.03;

%bindata = '100110010000100100010000100010101110001100110101'
%bindata(1)
%vid = VideoReader('nature.mp4');

%{
vid.CurrentTime = 0;
ii = 1;
while vid.hasFrame()
    temp(ii,:,:,:) = vid.readFrame();
    ii = ii + 1;
end
%%
figure;
imshow( squeeze(temp(35,:,:,:)) );
%}

%video opening
%folder = fileparts(which('traffic.avi'));
%movieFullFileName = fullfile(folder, 'traffic.avi');
vid = VideoReader('nature.mp4');
numFrames = vid.NumFrames;

%video writing setup
figure;
ax = axes;
vid.CurrentTime = 0;
Wvideo = VideoWriter('rhinoceros.avi','Uncompressed AVI');
Wvideo.FrameRate = 30;
open(Wvideo);


vidW = vid.Width;
vidH = vid.Height;

blW = floor(vidW/X);
blH = floor(vidH/Y);


%pattern creation
pat = zeros(vidH,vidW);
spat = zeros(Y,X);

step=1;
for j=0:(Y-1)
   for i=0:(X-1)
      if (i==0 && j== 0)||(i==X-1 && j== 0)||(i==0 && j== Y-1)||(i==X-1 && j== Y-1)
        pat((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))) = 1;
        spat(j+1,i+1)=1;
      else
        pat((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1))) = codedData(step)*2-1;
        spat(j+1,i+1) = codedData(step)*2-1;
        step=step+1;
      end 
   end 
end

nspat = (spat)*(-1);

%frame = 1;

for frame=1:(numFrames-1)
    cFrame = im2uint8(read(vid,frame));
    %nFrame = im2double(read(vid,frame+1));%это может замедлять работу
    dFrame = int32(cFrame) - int32(im2uint8(read(vid,frame+1)));
    %size(temp)
    
    
    for j=0:(Y-1)
       for i=0:(X-1)
          d = mean(dFrame((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),:),'all');   
          
          %calculating T
          if spat(j+1,i+1) == 1
             if d<S
                T = round(S-d/2);
             else
                T=0;
             end
          else
             if d>-S
                T = round(S+d/2);
             else
                T=0;
             end
          end
          
          
          %frame modification
          if(rem(round(frame/2),2)==0)
             cFrame((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),3) = cFrame((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),3) + T*spat(j+1,i+1);
          else
             cFrame((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),3) = cFrame((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),3) + T*nspat(j+1,i+1);
          end
          
       end 
    end
    
    

    
    imshow(cFrame,'Parent',ax);
    writeVideo(Wvideo,cFrame);
    %pause(1/vid.FrameRate);
end

%{
while vid.hasFrame()
    temp = im2double(vid.readFrame());
    %size(temp)
    
    for j=0:(Y-1)
       for i=0:(X-1)
          if bindata(1+i+Y*j)=='1'
            temp((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),:)=factor*log(1+(powerDiff*(mod(frame,2)))+temp((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),:));
          else
            temp((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),:)=factor*log(1+(powerDiff*(mod(frame+1,2)))+temp((1+blH*j):(blH*(j+1)),(1+blW*i):(blW*(i+1)),:));
          end
       end 
    end
    
    imshow(temp,'Parent',ax);
    writeVideo(Wvideo,temp);
    pause(1/vid.FrameRate);
    frame = frame+1;
end
%}


close(Wvideo);
close all
