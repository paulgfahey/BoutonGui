function plotBoutonAnalysis(outData)


allWidths = outData.boutonWidth;
allInts = outData.boutonInt;

%raw width histogram
figure;
title('raw width histogram');
boutonWidths = [];
for j = 1:size(allWidths,2);
    boutonWidths = [boutonWidths; extractData(allWidths,1,j)];
end
boutonWidths = boutonWidths(~isnan(boutonWidths));
h = histogram(boutonWidths);
    
%width difference histogram
figure
title('width difference histogram')
boutonWidthDiff = [];
for j = 1:size(allWidths,2)
    boutonWidthDiff = [boutonWidthDiff; extract

%raw brightness histogram

%brightness quotient histogram

%Change in width over time

%change in brightness over time

%change in width and brightness over time

%width and brightness clusters


end


function data = extractData(struct,column, axon)
    data = struct{axon}(:,column,:)
end