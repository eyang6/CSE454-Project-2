%
% File  :   Project 2 - Time Series
%
% Author:   Eric Yang
% Date  :   November 7, 2021
% 
% Course:   CSE 454
% 
% Description:
%       Time Series analysis on a synthetic data set using Piecewise
%       Aggregate Approximation, Symbolic Aggregate Approximation representations
%       and classification with Euclidean Distance and Manhattan Distance
%
% References:
%       CSE454 Fall 2021 Matlab Drive
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
    testLabel(1:10) = "Normal";
    testLabel(11:20) = "Cyclic";
    testLabel(21:30) = "Increasing Trend";
    testLabel(31:40) = "Decreasing Trend";
    testLabel(41:50) = "Upward Shift";
    testLabel(51:60) = "Downward Shift";
    trainLabel(1:90) = "Normal";
    trainLabel(91:180) = "Cyclic";
    trainLabel(181:270) = "Increasing Trend";
    trainLabel(271:360) = "Decreasing Trend";
    trainLabel(361:450) = "Upward Shift";
    trainLabel(451:540) = "Downward Shift";
    c=10;
    paaTrain = paaGen(c,dataTrain);
    paaTest = paaGen(c,dataTest);

    paaplot(paaTrain,dataTrain,c,451);
    
    sax = saxGen(paaTrain,dataTrain)
    
    [baseEuclideanAcc, beConf] = classifyAcc(dataTrain,dataTest,1,trainLabel,testLabel);
    [paaEuclideanAcc, peConf] = classifyAcc(paaTrain,paaTest,1,trainLabel,testLabel);
    [baseManhattanAcc, bmConf] = classifyAcc(dataTrain,dataTest,0,trainLabel,testLabel);
    [paaManhattanAcc, pmConf] = classifyAcc(paaTrain,paaTest,0,trainLabel,testLabel);

    baseEuclideanAcc
%     confusionchart(beConf);
    paaEuclideanAcc
%     confusionchart(peConf);
    baseManhattanAcc
%     confusionchart(bmConf);
    paaManhattanAcc
%     confusionchart(pmConf);

end

%{
    Plots PAA values against original data set
    Inputs:
            paa: Matrix of PAA values
            data: Matrix of original data
            c: Number of columns/separations using in PAA representation
            i: Matrix index used to generate plot
    Outputs:
            None
%}
function  paaplot(paa,data,c,i)
    s=size(data);
    dt=s(2);
    ln=dt/c;
    ln=ceil(ln);
    paax=[];
    paay=[];
    z=1;
    n=1;
    paax(z)=0;
    paay(z)=paa(i,n);
    s=size(data);
    z=z+1;
    for n=2:c
        paax(z)=paax(z-1)+ln;
        paay(z)=paa(i,n-1);
        z=z+1;
        paax(z)=paax(z-1);
        paay(z)=paa(i,n);
        z=z+1;
    end
    plot(paax,paay);
    hold on
    t=linspace(0,s(2),s(2));
    scatter(t,data(i,:),"filled")
    ylim([0,65]);
end


%{
    Assigns temporal data to PAA Representation
    Inputs:
            c: Number of columns to divide the data
            data: Matrix of data to be assigned PAA values
    Ouputs:
            paa: Matrix of PAA values
%}
function paa = paaGen(c, data)
    s = size(data);
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
    Maps PAA data into a string based on the mean and standard deviation of
    the initial unchanged data.
    Inputs:
            paa: PAA Data Set
            data: Original Data Set
    Outputs:
            sax: Matrix of strings of mapped PAA data to letters
%}
function sax = saxGen(paa, data)
        %NOTE: Using Alphabet Size of 5
    for i = 1:size(paa,1)
        x = fitdist(transpose(data(i,:)),"Normal");
        cutPoints = [-inf x.mu-0.84*x.sigma x.mu-0.25*x.sigma x.mu+0.25*x.sigma x.mu+0.84*x.sigma];  
        for j = 1:size(paa,2)
            string(i,j) = sum(cutPoints<=paa(i,j),2);
        end
    end
    alphabet = ['a','b','c','d','e'];
    sax = alphabet(string);
end


%{
    Euclidean distance calculator - handles multiple dimensions
    Inputs:
            p: Position 1
            q: Position 2
    Outputs:
            dist: Euclidean Distance between p and q
%}
function dist = eucDist(p,q)
    sum = 0;
    for i = 1:length(p)
        dim = p(i)-q(i);
        sum = sum + (dim^2);
    end
    dist = sqrt(sum);
end

%{
    Manhattan distance calculator - handles multiple dimensions
    Inputs:
            p: Position 1
            q: Position 2
    Ouputs:
            dist: Manhattan Distance between p and q
%}
function dist = manhattanDist(p,q)
    sum = 0;
    for i = 1:length(p)
        dim = abs(p(i)-q(i));
        sum = sum + dim;
    end
    dist = sum;
end

%{
    Assigns a label to training set data according to the shortest distance
    test set data as determined by Euclidean/Manhattan Distance. Calculates
    the accuracy of assigned labels to true labels. Confusion Matrix may be
    generated if necessary.
    Inputs:
            train: Training set data
            test: Testing set data
            euc: Flag if using Euclidean(1) or Manhattan Distance(~1)
            trainLabel: True labels of training set data
            testLabel: Labels of test set data
    Outputs:
            acc: Accuracy of classification using Euclidean/Manhattan
                 Distance
            conf: Confusion Matrix generated from comparison
%}
function [acc, conf] = classifyAcc(train,test,euc,trainLabel,testLabel)
    for i = 1:length(train)
        for j = 1:length(test)
            if euc==1
                dist(i,j) = eucDist(train(i,:),test(j,:));
            else
                dist(i,j) = manhattanDist(train(i,:),test(j,:));
            end
        end
    end
    for i = 1:length(dist)
        [x,cIndex(i)] = min(dist(i,:));
    end
    sum = 0;
    for i = 1:length(cIndex)
        class(i) = testLabel(cIndex(i));
        if testLabel(cIndex(i))==trainLabel(i)
            sum = sum+1;
        end
    end
    acc = sum/length(cIndex);
    conf = confusionmat(trainLabel,class);
%     confusionchart(c)
end

