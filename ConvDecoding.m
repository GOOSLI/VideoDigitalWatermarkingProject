tbdepth = 6; % Traceback depth for Viterbi decoder
trellis = poly2trellis(7,[137 133],137);
decodedData = vitdec(codedDataExtr,trellis,tbdepth,'trunc','hard');



%{
bindata = [0,1,0,1,1,1,1,0,0,0,1];
convCode = zeros(1,length(bindata)*2);
for i=1:(length(bindata))
    convCode(i*2-1) = bindata(i);
end
convCode(2)= bindata(1);
for i=2:(length(bindata))
    if(bindata(i)== 0)
        if(bindata(i-1)== 0)
            convCode(i*2) = 0;
        else
            convCode(i*2) = 1;
        end
    else
        if(bindata(i-1)== 0)
            convCode(i*2) = 1;
        else
            convCode(i*2) = 0;
        end
    end
end

convCode
%}


