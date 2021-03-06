close all
clear all



%Основные настройки
Bx = 8;
By = 8;
A = 2.5;
M = 12;
Ms = 10;     
m = 4;
L = 0.15; %L из статьи

Wvideo = VideoWriter('corrected2.avi','Uncompressed AVI');
Wvideo.FrameRate = 30;
open(Wvideo);

%Доп настройки
Mstep = 3;

vid = VideoReader('TRecap3.mp4');
%numFrames = vid.NumFrames;
vidW = vid.Width;
vidH = vid.Height;
vid.CurrentTime = 0;
video = read(vid);





Bxn = floor(vidW/Bx);
Byn = floor(vidH/By);



figure;
ax = axes;
zoom(5);

figure;
ax2 = axes;
zoom(5);

%dFr = zeros(Ms+M-4,vidH,vidW);
%for frame=Ms:(Ms+M-4)
%    dFr(frame,:,:) = int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));
%end



%imshow(CanImg,'Parent',ax);

profile on;

for tries=1:M
    
    CanImg = zeros(Byn,Bxn);
    dFrames = zeros(vidH,vidW,M-1);
    means = zeros(Byn,Bxn,M-2);
    
    %imshow(video(:,:,:,Ms+round(M/2)));
    
    for frame=Ms:(Ms+M-1)
        dFrames(:,:,frame)=int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));    
    end


    for frame=Ms:(Ms+M-3)
        for j=1:Byn
            for i=1:Bxn
                means(j,i,frame) =  mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame),'all')- mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame+1),'all');   
            end
        end
    end

    %pause(0.01);
    for frame=Ms:(Ms+M-5)

        %dFr = int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));
        %dFr1 = int16(video(:,:,3,frame+1)) - int16(video(:,:,3,frame+2));
        %dFr2 = int16(video(:,:,3,frame+2)) - int16(video(:,:,3,frame+3));
        %dFr3 = int16(video(:,:,3,frame+3)) - int16(video(:,:,3,frame+4));

        for j=1:Byn
            for i=1:Bxn
                %a1 =  mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame),'all')- mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame+1),'all');
                %a2 =  mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame+1),'all')- mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame+2),'all');
                %a3 =  mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame+2),'all')- mean(dFrames((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i),frame+3),'all');

                if means(j,i,frame)>=A && means(j,i,frame+1)>=A && means(j,i,frame+2) <=-A
                    CanImg(j,i) = CanImg(j,i) + 1;
                elseif means(j,i,frame)>=A && means(j,i,frame+1)<=-A && means(j,i,frame+2) <=-A
                    CanImg(j,i) = CanImg(j,i) + 1;
                elseif means(j,i,frame)<=-A && means(j,i,frame+1)<=-A && means(j,i,frame+2) >=A
                    CanImg(j,i) = CanImg(j,i) + 1;
                elseif means(j,i,frame)<=-A && means(j,i,frame+1)>=A && means(j,i,frame+2) >=A
                    CanImg(j,i) = CanImg(j,i) + 1;
                end                             
            end 
        end 

        %imshow(CanImg,'Parent',ax);
        %pause(0.2);
    end

    for j=1:Byn
        for i=1:Bxn
            if CanImg(j,i)>=m
                CanImg(j,i)=1;
            else
                CanImg(j,i)=0;
            end
        end 
    end  

    %imshow(CanImg,'Parent',ax);
    %pause(0.2);

    CanImg2 = zeros(Byn,Bxn);

    for j=2:Byn-1
        for i=2:Bxn-1
            if CanImg(j-1,i)==1 || CanImg(j+1,i)==1 || CanImg(j-1,i+1)==1 || CanImg(j+1,i+1)==1 || CanImg(j-1,i-1)==1 || CanImg(j+1,i-1)==1 || CanImg(j,i+1)==1 || CanImg(j,i-1)==1 
                CanImg2(j,i)=1;        
            end
        end 
    end

    %imshow(CanImg2,'Parent',ax);
    %pause(0.1);

    CanImg = CanImg2;

    for j=2:Byn-1
        for i=2:Bxn-1
            if CanImg(j-1,i)==0 || CanImg(j+1,i)==0 || CanImg(j-1,i+1)==0 || CanImg(j+1,i+1)==0 || CanImg(j-1,i-1)==0 || CanImg(j+1,i-1)==0 || CanImg(j,i+1)==0 || CanImg(j,i-1)==0 
                CanImg2(j,i)=0;        
            end
        end 
    end 

    %imshow(CanImg2,'Parent',ax);
    %pause(0.1);

    CanImg = bwareafilt(logical(CanImg2),1,'largest',4);

    %imshow(CanImg)



    Yu=Bxn;
    Yd=1;
    Xl=Byn;
    Xr=1;

    for j=1:Byn
        for i=1:Bxn
            if CanImg(j,i)==1
                if j<Yu
                    Yu=j;
                end

                if j>Yd
                    Yd=j;
                end

                if i<Xl
                    Xl=i;
                end

                if i>Xr
                    Xr=i;
                end
            end
        end 
    end  

    rectangle('Position',[Xl*Bx Yu*By (Xr-Xl)*Bx (Yd-Yu)*By],'EdgeColor','r');
    %viscircles([Ml Mu] ,0.2)

    min = Bxn;
    %minx = 0

    for i=1:Bxn
        if CanImg(Yu,i)==1
            if abs(i-Xl)<min
                Xu=i;
                min = abs(i-Xl);
            end

            if abs(i-Xr)<min 
                Xu=i;
                min = abs(i-Xr);
            end
        end
    end 

    min = Bxn;

    for i=1:Bxn
        if CanImg(Yd,i)==1
            if abs(i-Xl)<min
                Xd=i;
                min = abs(i-Xl);
            end

            if abs(i-Xr)<min 
                Xd=i;
                min = abs(i-Xr);
            end
        end
    end

    min = Byn;

    for i=1:Byn
        if CanImg(i,Xl)==1
            if abs(i-Yu)<min 
                Yl=i;
                min = abs(i-Yu);
            end

            if abs(i-Yd)<min 
                Yl=i;
                min = abs(i-Yd);
            end
        end
    end 

    min = Byn;

    for i=1:Byn
        if CanImg(i,Xr)==1
            if abs(i-Yu)<min 
                Yr=i;
                min = abs(i-Yu);
            end

            if abs(i-Yd)<min 
                Yr=i;
                min = abs(i-Yd);
            end
        end
    end 


    
    viscircles([2 20] ,0.2,'Color','b');
    
    viscircles([Xu*Bx Yu*By] ,0.2,'Color','b');
    viscircles([Xd*Bx Yd*By] ,0.2,'Color','b');
    viscircles([Xl*Bx Yl*By] ,0.2,'Color','b');
    viscircles([Xr*Bx Yr*By] ,0.2,'Color','b');

    %line([Ml Xu],[Yl Mu]);

    %ДОДЕЛАТЬ ПЕРЕЗАПУСК ПРИ НЕНАХОДЕ
    %ENTERING L
    st = 150; % длина линии при отрисовке
    MaxTilt = 45; %максимальный наколн стороны квадрата 

    
    
    %inters=0; 
    %fi=3;

    fiU=0;

    if abs(Xu-Xr)<=abs(Xu-Xl)%определение направления вращения
        dir = 1;
    else 
        dir = -1;
    end

    for fi=0:MaxTilt

        inters=0; %счетчик для пересечений

        for i=1:Bxn  
            if(Byn>=round(Yu-(i-Xu)*dir*tan(fi/57.3)) && round(Yu-(i-Xu)*dir*tan(fi/57.3))>0)
                if( CanImg(round(Yu-(i-Xu)*dir*tan(fi/57.3)), round(i) ) == 1)      
                    inters = inters+1;
                end
            end
        end

        %когда угол найден делаем отрисовку и сохраняем угол
        if inters>Bxn*L
%             for i=1:Bxn  
%                 if( CanImg(round(Yu-(i-Xu)*dir*tan(fi/57.3)), round(i) ) == 1)      
%                     viscircles([round(i)*Bx round(Yu-(i-Xu)*dir*tan(fi/57.3))*By] ,0.2);
%                 end
%             end
            line([(Xu-st)*Bx (Xu+st)*By],[(Yu+st*dir*tan(fi/57.3))*Bx (Yu-st*dir*tan(fi/57.3))*By],'Color', 'g');
            fiU=fi*dir;
            break;
        end 

    end

    fiD=0;

    if abs(Xd-Xr)>=abs(Xd-Xl)%определение направления вращения
        dir = 1;
    else 
        dir = -1;
    end

    for fi=0:MaxTilt

        inters=0; %счетчик для пересечений

        for i=1:Bxn  
            if(Byn>=round(Yd-(i-Xd)*dir*tan(fi/57.3)) && round(Yd-(i-Xd)*dir*tan(fi/57.3))>0)
                if( CanImg(round(Yd-(i-Xd)*dir*tan(fi/57.3)), round(i) ) == 1)      
                    inters = inters+1;
                end
            end
        end

        %когда угол найден делаем отрисовку и сохраняем угол
        if inters>Bxn*L
%             for i=1:Bxn  
%                 if( CanImg(round(Yd-(i-Xd)*dir*tan(fi/57.3)), round(i) ) == 1)      
%                     viscircles([round(i)*Bx round(Yd-(i-Xd)*dir*tan(fi/57.3))*By] ,0.2);
%                 end
%             end
            line([(Xd-st)*Bx (Xd+st)*By],[(Yd+st*dir*tan(fi/57.3))*Bx (Yd-st*dir*tan(fi/57.3))*By],'Color', 'g');   
            fiD=fi*dir;
            break;
        end 

    end


    fiR=0;

    if abs(Yr-Yu)>=abs(Yr-Yd)%определение направления вращения
        dir = -1;
    else 
        dir = 1;
    end

    for fi=0:MaxTilt

        inters=0; %счетчик для пересечений

        for i=1:Byn  
            if(Bxn>=round(Xr-(i-Yr)*dir*tan(fi/57.3)) && round(Xr-(i-Yr)*dir*tan(fi/57.3))>0)
                if( CanImg(round(i), round(Xr-(i-Yr)*dir*tan(fi/57.3))) == 1)      
                    inters = inters+1;
                end
            end
        end

        %когда угол найден делаем отрисовку и сохраняем угол
        if inters>Byn*L
%             for i=1:Byn  
%                 if( CanImg(round(i), round(Xr-(i-Yr)*dir*tan(fi/57.3)) ) == 1)      
%                     viscircles([round(Xr-(i-Yr)*dir*tan(fi/57.3))*Bx round(i)*By] ,0.2);
%                 end
%             end
            line([round(Xr-st*dir*tan(fi/57.3))*Bx round(Xr+st*dir*tan(fi/57.3))*By],[(Yr+st)*Bx (Yr-st)*By],'Color', 'g');   
            fiR=fi*dir;
            break;
        end 

    end


    fiL=0;

    if abs(Yl-Yu)<=abs(Yl-Yd)%определение направления вращения
        dir = -1;
    else 
        dir = 1;
    end

    for fi=0:MaxTilt

        inters=0; %счетчик для пересечений

        for i=1:Byn  
            if(Bxn>=round(Xl-(i-Yl)*dir*tan(fi/57.3)) && round(Xl-(i-Yl)*dir*tan(fi/57.3))>0)
                if( CanImg(round(i), round(Xl-(i-Yl)*dir*tan(fi/57.3))) == 1)      
                    inters = inters+1;
                end
            end
        end

        %когда угол найден делаем отрисовку и сохраняем угол
        if inters>Byn*L
%             for i=1:Byn  
%                 if( CanImg(round(i), round(Xl-(i-Yl)*dir*tan(fi/57.3)) ) == 1)      
%                     viscircles([round(Xl-(i-Yl)*dir*tan(fi/57.3))*Bx round(i)*By] ,0.2);
%                 end
%             end
            line([round(Xl-st*dir*tan(fi/57.3))*Bx round(Xl+st*dir*tan(fi/57.3))*By],[(Yl+st)*Bx (Yl-st)*By],'Color', 'g');
            fiL=fi*dir;
            break;
        end 
    end
    

    fiR = -fiR+90;
    fiL = -fiL+90;

    Xdr = (Yr-Yd-Xd*tan(fiD/57.3)+Xr*tan(fiR/57.3))/(tan(fiR/57.3)-tan(fiD/57.3));
    Ydr = Yd-(Xdr-Xd)*tan(fiD/57.3);
    

    Xdl = (Yl-Yd-Xd*tan(fiD/57.3)+Xl*tan(fiL/57.3))/(tan(fiL/57.3)-tan(fiD/57.3));
    Ydl = Yd-(Xdl-Xd)*tan(fiD/57.3);
    

    Xur = (Yr-Yu-Xu*tan(fiU/57.3)+Xr*tan(fiR/57.3))/(tan(fiR/57.3)-tan(fiU/57.3));
    Yur = Yu-(Xur-Xu)*tan(fiU/57.3);
    

    Xul = (Yl-Yu-Xu*tan(fiU/57.3)+Xl*tan(fiL/57.3))/(tan(fiL/57.3)-tan(fiU/57.3));
    Yul = Yu-(Xul-Xu)*tan(fiU/57.3);

    

    
    if(Xdr>0 && Xdl>0 && Xur>0 && Xul>0 && Ydr>0 && Ydl>0 && Yur>0 && Yul>0 && Xdr<Bxn && Xdl<Bxn && Xur<Bxn && Xul<Bxn && Ydr<Byn && Ydl<Byn && Yur<Byn && Yul<Byn )

        viscircles([Xdr*Bx Ydr*By] ,0.4,'Color','g');
        viscircles([Xdl*Bx Ydl*By] ,0.4,'Color','g');
        viscircles([Xur*Bx Yur*By] ,0.4,'Color','g');
        viscircles([Xul*Bx Yul*By] ,0.4,'Color','g');
        pause(0.01);
        
%       CanImg = uint8(imresize(CanImg, Bx)*255);
        a = video(:,:,:,Ms+round(M/2));
%       a = a(1:Byn*By,1:Bxn*Bx,:);
%       a=0.2*CanImg + 0.8*a(:,:,:);
        
        fixedPoints = [0 0; 0 vidH; vidW vidH; vidW 0];
        movingPoints = [Xul*Bx Yul*By; Xdl*Bx Ydl*By; Xdr*Bx Ydr*By; Xur*Bx Yur*By];
        tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
        R=imref2d(size(a),[1 size(a,2)],[1 size(a,1)]);
        b = imwarp(a, tform,'OutputView',R);
        imshow(a,'Parent',ax2);      
        imshow(b,'Parent',ax);      
        writeVideo(Wvideo,b);
    end
    
    Ms=Ms+Mstep;
    
    
    

    
end
%viscircles([2 2] ,0.2,'Color','g')


close(Wvideo);

profile off;
profile viewer;

%axis([0 Bxn 0 Byn])

