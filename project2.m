%
% File  :   Project 2 - Time Series
%
% Author:   Eric Yang
% Date  :   November 7, 2021
% 
% Course:   CSE 454
% 
% Description:
% 
clc;
clear;
close all;
main();

function main()
    data = load("synthetic_control.data");
        %NOTE: Data set split into training and testing. The last 10% of each
        %class made into testing set
    dataTrain = [data(1:90,:);data(101:190,:);data(201:290,:);data(301:390,:);data(401:490,:);data(501:590,:)];
    dataTest = [data(91:100,:);data(191:200,:);data(291:300,:);data(391:400,:);data(491:500,:);data(591:600,:)];
    c=10;
    paa = paaGen(c,data);
    orgD
        
    %     s=size(data)
    %     s(2)
    %     floor

end


%{
Generates columns for PAA
%}
function paa = paaGen(c, data)
    s =size(data);
    time = s(2);
    sect = time/c;
    sect = ceil(sect);
    paa = zeros(s(1),c);

    for row = 1:s(1)
        for N = 1:c
            sample=[];
            sampleCount = 1;
                %NOTE: Upper and lower bounds of the paa section
            upper = N*sect;
            lower = (N-1)*sect;
            if lower < s(2)
                for col = 1:s(2)
                    if(col>lower && col<=upper)
                        sample(sampleCount) = data(row,col);
                        sampleCount = sampleCount+1;
                    end
                end
            end
            paa(row,N) = mean(sample);
        end
    end
end


%{
Euclidean distance calulator
%}
function dist = distCalc(p,q)
    sum = 0;
    for i = 1:length(p)
        dim = p(i)-q(i);
        sum = sum + dim^2;
    end
    dist = sqrt(sum);
end

