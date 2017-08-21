function plotBoutonAnalysis(outData)
allWidths = outData.boutonWidth;
allInts = outData.boutonInt;
presentBout = outData.boutonPresence;


%Distribution Figure 1

h = figure;
%raw width distribution
subplot(1,4,1);
title('raw width histogram'); hold on;
allBoutonWidths = [];
for j = 1:size(allWidths,2)
    allBoutonWidths = [allBoutonWidths; extractData(outData,allWidths,1,j)];
end
allBoutonWidths = allBoutonWidths(~isnan(allBoutonWidths));
scatterLinePlot(allBoutonWidths);

% width difference distribution
subplot(1,4,2);
title('width difference histogram'); hold on;
allBoutonWidthDiff = [];
for j = 1:size(allWidths,2)
    allBoutonWidthDiff = [allBoutonWidthDiff; extractData(outData,allWidths,3,j)];
end
allBoutonWidthDiff = allBoutonWidthDiff(~isnan(allBoutonWidthDiff));
scatterLinePlot(allBoutonWidthDiff);

% %raw brightness distribution
subplot(1,4,3);
title('raw brightness histogram'); hold on;
boutonInt = [];
for j = 1:size(allInts,2)
    boutonInt = [boutonInt;extractData(outData,allInts,1,j)];
end
boutonInt = boutonInt(~isnan(boutonInt));
scatterLinePlot(boutonInt);
% 
% % %brightness quotient distribution
% subplot(1,4,4);
% title('brightness quotient histogram'); hold on;
% boutonIntQuot = [];
% for j = 1:size(allInts,2)
%     boutonIntQuot = [boutonIntQuot;extractData(outData,allInts,3,j)];
% end
% boutonIntQuot = boutonIntQuot(~isnan(boutonIntQuot));
% scatterLinePlot(boutonIntQuot);

% brightness difference distribution
subplot(1,4,4);
title('brightness difference histogram');
hold on;
boutonIntDiff = [];
for j = 1:size(allInts,2)
    boutonIntDiff = [boutonIntDiff; extractData(outData,allInts,2,j)];
end
boutonIntDiff = boutonIntDiff(~isnan(boutonIntDiff));
boutonIntDiff = boutonInt - boutonIntDiff;
scatterLinePlot(boutonIntDiff);





%Change over time, figure 2
figure;
%Change in width over time
subplot(1,2,1);
title('width over time')
boutonWidth = [];
for j = 1:size(allWidths,2)
    boutonWidth = [boutonWidth;permute(extractData(outData,allWidths,3,j),[1,3,2])];
end
boutonWidth(isnan(boutonWidth(:,2)),:) = [];
timeLinePlot(boutonWidth);

% %change in brightness over time
% subplot(1,2,2);
% title('brightness over time')
% boutonInt = [];
% for j = 1:size(allInts,2)
%     boutonInt = [boutonInt; permute(extractData(outData,allInts,3,j),[1,3,2])];
% end
% boutonInt(isnan(boutonInt(:,2)),:) = [];
% timeLinePlot(boutonInt);


%change in brightness over time
subplot(1,2,2);
title('brightness over time')
boutonInt = [];
axonInt = [];
for j = 1:size(allInts,2)
    boutonInt = [boutonInt; permute(extractData(outData,allInts,1,j),[1,3,2])];
    axonInt = [axonInt; permute(extractData(outData,allInts,2,j),[1,3,2])];
end
boutonIntDiff = boutonInt - axonInt;
boutonIntDiff(isnan(boutonIntDiff(:,2)),:) = [];
timeLinePlot(boutonIntDiff);





%2D Scatter Plot
figure;
%width and brightness clusters
title('width/brightness scatter')
boutonWidth = [];
boutonWidthRaw = [];
for j = 1:size(allWidths,2)
    boutonWidth = [boutonWidth; extractData(outData,allWidths,3,j)];
    boutonWidthRaw = [boutonWidthRaw; extractData(outData,allWidths,1,j)];
end
boutonInt = [];
boutonIntRaw = [];
for j = 1:size(allInts,2)
    boutonInt = [boutonInt; extractData(outData,allInts,3,j)];
    boutonIntRaw = [boutonIntRaw; extractData(outData,allInts,1,j)];
end
exclude = any(isnan(boutonInt),2) | any(isnan(boutonWidth),2) | any(isnan(boutonWidthRaw),2) | any(isnan(boutonIntRaw),2);
boutonWidth(exclude) = [];
boutonInt(exclude) = [];
boutonIntRaw(exclude) = [];
boutonWidthRaw(exclude) = [];

scatter(boutonWidth, boutonInt,150,'.k')

%Time Dependent 2D change, figure 4
%change in width and brightness over time
% boutonWidth = [];
% boutonInt = [];
% for j = 1:size(allWidths,2)
%     boutonWidth = [boutonWidth;permute(extractData(outData,allWidths,3,j),[1,3,2])];
% end
% for j = 1:size(allInts,2)
%     boutonInt = [boutonInt;permute(extractData(outData,allInts,3,j),[1,3,2])];
% end

boutonWidth = [];
boutonInt = [];
axonInt = [];
for j = 1:size(allWidths,2)
    boutonWidth = [boutonWidth;permute(extractData(outData,allWidths,3,j),[1,3,2])];
end
for j = 1:size(allInts,2)
    boutonInt = [boutonInt; permute(extractData(outData,allInts,1,j),[1,3,2])];
    axonInt = [axonInt; permute(extractData(outData,allInts,2,j),[1,3,2])];
end
boutonInt = boutonInt - axonInt;
maxInt = max(max(boutonInt));
maxWidth = max(max(boutonWidth));


boutonWidth1 = boutonWidth(:,1:2);
boutonWidth2 = boutonWidth(:,2:3);
boutonInt1 = boutonInt(:,1:2);
boutonInt2 = boutonInt(:,2:3);

exclude1 = any(isnan(boutonWidth1),2) | any(isnan(boutonInt1),2);
exclude2 = any(isnan(boutonWidth2),2) | any(isnan(boutonInt2),2);

boutonWidth1(exclude1,:) = [];
boutonWidth2(exclude2,:) = [];
boutonInt1(exclude1,:) = [];
boutonInt2(exclude2,:) = [];

figure;
subplot(1,2,1)
title('t1 to t2')
hold on
for i = 1:size(boutonWidth1,1)
line(boutonWidth1(i,:),boutonInt1(i,:),'Color','k')
scatter(boutonWidth1(i,1),boutonInt1(i,1),20,'sk')
scatter(boutonWidth1(i,2),boutonInt1(i,2),120,'.k')
end
axis([0,maxWidth,0,maxInt]);

subplot(1,2,2)
title('t2 to t3')
hold on
for i = 1:size(boutonWidth2,1)
line(boutonWidth2(i,:),boutonInt2(i,:),'Color','k')
scatter(boutonWidth2(i,1),boutonInt2(i,1),20,'sk')
scatter(boutonWidth2(i,2),boutonInt2(i,2),120,'.k')
end
axis([0,maxWidth,0,maxInt]);

end



function data = extractData(outData,struct,column, axon)
    data = struct{axon}(:,column,:);
    data(outData.boutonPresence{axon} ~= 1) = nan;
end

function scatterLinePlot(data)
    x = (ones(size(data,1),2).*[.95,1.05])';
    y = [data,data]';
    plot(x,y,'k');
    axis([0,2,0,max(data)]);
    set(gca,'xtick',[]);
    scatter(1.25,mean(data),'db');
    scatter(1.25,median(data),'dr');
end

function timeLinePlot(data)
    x = (ones(size(data,1),3).*[1,2,3])';
    y = (data)';
    plot(x,y,'k')
    hold on;
    x2 = [x(1,:),x(2,:),x(3,:)]';
    y2 = [y(1,:),y(2,:),y(3,:)]';
    scatter(x2,y2,20,'ok');
    maxData = max(max(data));
    axis([0,4,0,round(maxData + maxData/10)]);
    set(gca,'xtick',[]);
end