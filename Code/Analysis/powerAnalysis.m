clear all
sampleSizeRange = 50:50:250;
experimentNum = 1000;

elimStats = nan(experimentNum, size(sampleSizeRange,2));
formStats = nan(experimentNum, size(sampleSizeRange,2));

wtRates = [19,9;12,12;69,79];
mecRates = [5,5;9,7;86,88];

wtCut = [.81,.91;.69,.79];
mecCut = [.95,.95;.86,.88];

for i = 1:size(sampleSizeRange,2)
    sampleSize = sampleSizeRange(i);
    disp(sampleSize);
    for j = 1:experimentNum
        if mod(j,250) == 0
            disp(j);
        end
        wtpresence = [];
        mecpresence = [];
        
        for k = 1:2
            presence = rand([sampleSize,2]);
            wtpresence(presence(:,k) <= wtCut(2,k),k) = 0;
            wtpresence(presence(:,k) <= wtCut(1,k) & presence(:,k) > wtCut(2,k),k) = -1;
            wtpresence(presence(:,k) > wtCut(1,k),k) = 1;
            
            presence = rand([sampleSize,2]);
            mecpresence(presence(:,k) <= mecCut(2,k),k) = 0;
            mecpresence(presence(:,k) <= mecCut(1,k) & presence(:,k) > mecCut(2,k),k) = -1;
            mecpresence(presence(:,k) > mecCut(1,k),k) = 1;
            
        end
        
        wtTrain = statSummary(wtpresence(:,1));
        wtRest = statSummary(wtpresence(:,2));
        mecTrain = statSummary(mecpresence(:,1));
        mecRest = statSummary(mecpresence(:,2));
        
        elimTemp = anova2([wtTrain(:,1), wtRest(:,1); mecTrain(:,1), mecTrain(:,1)],sampleSize/10,'off');
        elimState(j,i) = elimTemp(2);
        elimGen(j,i) = elimTemp(1);
        
        formTemp = anova2([wtTrain(:,2), wtRest(:,2); mecTrain(:,2), mecTrain(:,2)], sampleSize/10,'off');
        formState(j,i) = formTemp(2);
        formGen(j,i) = formTemp(1);
        
        
%         
%        
%         wtTrainPresence = reshape(wtpresence(:,1),[10,sampleSize/10]);
%         wtpresence = reshape(wtpresence,[10, sampleSize/10]);
%         mecpresence = reshape(mecpresence,[10,sampleSize/10]);
%         
%         wtTrain = [];
%         wtTrain(:,1) = (sum(wtpresence(:,1) == 1))
%         
%         wtStats = [];
%         wtStats(1,:) = (sum(wtpresence == 1))/sampleSize;
%         wtStats(2,:) = (sum(wtpresence == -1))/sampleSize;
%         wtStats(3,:) = (sum(wtpresence == 0))/sampleSize;
% 
%         mecStats = [];
%         mecStats(1,:) = (sum(mecpresence == 1))/sampleSize;
%         mecStats(2,:) = (sum(mecpresence == -1))/sampleSize;
%         mecStats(3,:) = (sum(mecpresence == 0))/sampleSize;
% 
%         elimTemp = anova2([wtStats(:,1),mecStats(:,1)],1,'off');
%         elimStats(j,i) = elimTemp(2);
% 
%         formTemp = anova2([wtStats(:,2),mecStats(:,2)],1,'off');
%         formStats(j,i) = formTemp(2);
        
    end
end


function summary = statSummary(data)
    sampleSize = 10;
    axonData = reshape(data, [10,size(data,1)/10]);
    summary(:,1) = ((sum(axonData == 1,1))/sampleSize)';
    summary(:,2) = ((sum(axonData == -1,1))/sampleSize)';
    summary(:,3) = ((sum(axonData == 0,1))/sampleSize)';
end
    