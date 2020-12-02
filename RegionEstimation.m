close all
clear all

Bx = 6;
By = 6;
A = 1.5;

vid = VideoReader('Recap3.mp4');
%numFrames = vid.NumFrames;
vidW = vid.Width;
vidH = vid.Height;
vid.CurrentTime = 0;
video = read(vid);

M = 12;
Ms = 25;                                                                                                                                                                                                                                                                                                                                                                                      
m=M/3;

Bxn = floor(vidW/Bx);
Byn = floor(vidH/By);

CanImg = zeros(Byn,Bxn);

figure;
ax = axes;
zoom(5);

%dFr = zeros(Ms+M-4,vidH,vidW);

%for frame=Ms:(Ms+M-4)
%    dFr(frame,:,:) = int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));
%end



for frame=Ms:(Ms+M-4)
    
    dFr = int16(video(:,:,3,frame)) - int16(video(:,:,3,frame+1));
    dFr1 = int16(video(:,:,3,frame+1)) - int16(video(:,:,3,frame+2));
    dFr2 = int16(video(:,:,3,frame+2)) - int16(video(:,:,3,frame+3));
    dFr3 = int16(video(:,:,3,frame+3)) - int16(video(:,:,3,frame+4));

    for j=1:Byn
        for i=1:Bxn
            a1 =  mean(dFr((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i)),'all')- mean(dFr1((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i)),'all');
            a2 =  mean(dFr1((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i)),'all')- mean(dFr2((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i)),'all');
            a3 =  mean(dFr2((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i)),'all')- mean(dFr3((1+By*(j-1)):(By*j),(1+Bx*(i-1)):(Bx*i)),'all');
            
            if a1>=A && a2>=A && a3 <=-A
                CanImg(j,i) = CanImg(j,i) + 1;
            elseif a1>=A && a2<=-A && a3 <=-A
                CanImg(j,i) = CanImg(j,i) + 1;
            elseif a1<=-A && a2<=-A && a3 >=A
                CanImg(j,i) = CanImg(j,i) + 1;
            elseif a1<=-A && a2>=A && a3 >=A
                CanImg(j,i) = CanImg(j,i) + 1;
            end                             
        end 
    end 
    
    imshow(CanImg,'Parent',ax);
    pause(0.1);
    
    frame
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

imshow(CanImg,'Parent',ax);
pause(0.1);

CanImg2 = zeros(Byn,Bxn);

for j=2:Byn-1
    for i=2:Bxn-1
        if CanImg(j-1,i)==1 || CanImg(j+1,i)==1 || CanImg(j-1,i+1)==1 || CanImg(j+1,i+1)==1 || CanImg(j-1,i-1)==1 || CanImg(j+1,i-1)==1 || CanImg(j,i+1)==1 || CanImg(j,i-1)==1 
            CanImg2(j,i)=1;        
        end
    end 
end

imshow(CanImg2,'Parent',ax);
pause(0.1);

CanImg = CanImg2;

for j=2:Byn-1
    for i=2:Bxn-1
        if CanImg(j-1,i)==0 || CanImg(j+1,i)==0 || CanImg(j-1,i+1)==0 || CanImg(j+1,i+1)==0 || CanImg(j-1,i-1)==0 || CanImg(j+1,i-1)==0 || CanImg(j,i+1)==0 || CanImg(j,i-1)==0 
            CanImg2(j,i)=0;        
        end
    end 
end 

imshow(CanImg2,'Parent',ax);
pause(0.1);

CanImg = bwareafilt(logical(CanImg2),1,'largest',4);

imshow(CanImg)

Mu=Bxn;
Md=1;
Ml=Byn;
Mr=1;

for j=1:Byn
    for i=1:Bxn
        if CanImg(j,i)==1
            if j<Mu
                Mu=j;
            end
            
            if j>Md
                Md=j;
            end
                
            if i<Ml
                Ml=i;
            end
            
            if i>Mr
                Mr=i;
            end
        end
    end 
end  

rectangle('Position',[Ml Mu Mr-Ml Md-Mu],'EdgeColor','r')
%viscircles([Ml Mu] ,0.2)

min = Bxn;
%minx = 0

for i=1:Bxn
    if CanImg(Mu,i)==1
        if abs(i-Ml)<min
            Xu=i;
            min = abs(i-Ml);
        end
        
        if abs(i-Mr)<min 
            Xu=i;
            min = abs(i-Mr);
        end
    end
end 

min = Bxn;

for i=1:Bxn
    if CanImg(Md,i)==1
        if abs(i-Ml)<min
            Xd=i;
            min = abs(i-Ml);
        end
        
        if abs(i-Mr)<min 
            Xd=i;
            min = abs(i-Mr);
        end
    end
end

min = Byn;

for i=1:Byn
    if CanImg(i,Ml)==1
        if abs(i-Mu)<min 
            Yl=i;
            min = abs(i-Mu);
        end
        
        if abs(i-Md)<min 
            Yl=i;
            min = abs(i-Md);
        end
    end
end 

min = Byn;

for i=1:Byn
    if CanImg(i,Mr)==1
        if abs(i-Mu)<min 
            Yr=i;
            min = abs(i-Mu);
        end
        
        if abs(i-Md)<min 
            Yr=i;
            min = abs(i-Md);
        end
    end
end 

viscircles([Xu Mu] ,0.2)
viscircles([Xd Md] ,0.2)
viscircles([Ml Yl] ,0.2)
viscircles([Mr Yr] ,0.2)

%line([Ml Xu],[Yl Mu]);

%ДОДЕЛАТЬ ПЕРЕЗАПУСК ПРИ НЕНАХОДЕ
%ENTERING L
L = 0.15; %L из статьи
st = 150; % длина линии при отрисовке
MaxTilt = 90; %максимальный наколн стороны квадрата 

%inters=0; 
%fi=3;

fiU=0;

if abs(Xu-Mr)<=abs(Xu-Ml)%определение направления вращения
    dir = 1;
else 
    dir = -1;
end
    
for fi=0:MaxTilt
    
    inters=0; %счетчик для пересечений
    
    for i=1:Bxn  
        if( CanImg(round(Mu-(i-Xu)*dir*tan(fi/57.3)), round(i) ) == 1)      
            inters = inters+1;
        end
    end
    
    %когда угол найден делаем отрисовку и сохраняем угол
    if inters>Bxn*L
        for i=1:Bxn  
            if( CanImg(round(Mu-(i-Xu)*dir*tan(fi/57.3)), round(i) ) == 1)      
                viscircles([round(i) round(Mu-(i-Xu)*dir*tan(fi/57.3))] ,0.2)
            end
        end
        line([Xu-st Xu+st],[Mu+st*dir*tan(fi/57.3) Mu-st*dir*tan(fi/57.3)]);   
        fiU=fi*dir;
        break;
    end 
    
end

fiD=0;

if abs(Xd-Mr)>=abs(Xd-Ml)%определение направления вращения
    dir = 1;
else 
    dir = -1;
end
    
for fi=0:MaxTilt
    
    inters=0; %счетчик для пересечений
    
    for i=1:Bxn  
        if( CanImg(round(Md-(i-Xd)*dir*tan(fi/57.3)), round(i) ) == 1)      
            inters = inters+1;
        end
    end
    
    %когда угол найден делаем отрисовку и сохраняем угол
    if inters>Bxn*L
        for i=1:Bxn  
            if( CanImg(round(Md-(i-Xd)*dir*tan(fi/57.3)), round(i) ) == 1)      
                viscircles([round(i) round(Md-(i-Xd)*dir*tan(fi/57.3))] ,0.2)
            end
        end
        line([Xd-st Xd+st],[Md+st*dir*tan(fi/57.3) Md-st*dir*tan(fi/57.3)]);   
        fiD=fi*dir;
        break;
    end 
    
end


fiR=0;

if abs(Yr-Mu)>=abs(Yr-Md)%определение направления вращения
    dir = 1;
else 
    dir = -1;
end
    
for fi=0:MaxTilt
    
    inters=0; %счетчик для пересечений
    
    for i=1:Byn  
        if( CanImg(round(i), round(Mr-(i-Yr)*dir*tan(fi/57.3))) == 1)      
            inters = inters+1;
        end
    end
    
    %когда угол найден делаем отрисовку и сохраняем угол
    if inters>Byn*L
        for i=1:Byn  
            if( CanImg(round(i), round(Mr-(i-Yr)*dir*tan(fi/57.3)) ) == 1)      
                viscircles([round(Mr-(i-Yr)*dir*tan(fi/57.3)) round(i)] ,0.2)
            end
        end
        line([round(Mr+st*dir*tan(fi/57.3)) round(Mr-st*dir*tan(fi/57.3))],[Yr+st Yr-st]);   
        fiR=fi*dir;
        break;
    end 
    
end

fiL=0;

if abs(Yl-Mu)<=abs(Yl-Md)%определение направления вращения
    dir = 1;
else 
    dir = -1;
end
    
for fi=0:MaxTilt
    
    inters=0; %счетчик для пересечений
    
    for i=1:Byn  
        if( CanImg(round(i), round(Ml-(i-Yl)*dir*tan(fi/57.3))) == 1)      
            inters = inters+1;
        end
    end
    
    %когда угол найден делаем отрисовку и сохраняем угол
    if inters>Byn*L
        for i=1:Byn  
            if( CanImg(round(i), round(Ml-(i-Yl)*dir*tan(fi/57.3)) ) == 1)      
                viscircles([round(Ml-(i-Yl)*dir*tan(fi/57.3)) round(i)] ,0.2)
            end
        end
        line([round(Ml+st*dir*tan(fi/57.3)) round(Ml-st*dir*tan(fi/57.3))],[Yl+st Yl-st]);   
        fiL=fi*dir;
        break;
    end 
end




%axis([0 Bxn 0 Byn])

