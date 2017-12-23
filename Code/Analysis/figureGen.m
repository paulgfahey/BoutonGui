% load('boutonfinalsave_m3924s2_171218_135706.mat')

figure;
subplot(1,3,2);
hold on
cs = 1;

z = 29;
axonTrace = figData.axonTrace{cs}{2};
[imlabel,totalLabels] = bwlabel(axonTrace(:,3) == z);
sizeBlob = zeros(1,totalLabels);
for j = 1:totalLabels
    sizeBlob(j) = length(find(imlabel == j));
end
[~, largestBlobNo] =  max(sizeBlob);
axonTrace = axonTrace(imlabel == largestBlobNo,:);

xrange = (min(axonTrace(:,1))-50):(max(axonTrace(:,1))+50);
yrange = (min(axonTrace(:,2))-50):(max(axonTrace(:,2))+50);

axonImage = figData.stackDataShuffled{cs}(:,:,z);
axonImageRoi = axonImage(yrange,xrange);
imshow(imadjust(axonImageRoi, []));


axonTrace(:,1) = axonTrace(:,1) - min(xrange)+1;
axonTrace(:,2) = axonTrace(:,2) - min(yrange)+1;
plot(axonTrace(:,1),axonTrace(:,2));


subplot(1,3,3)
hold on
axonTrace = figData.axonTraceSnapSkipped{cs}{2};
[imlabel,totalLabels] = bwlabel(axonTrace(:,3) == z);
sizeBlob = zeros(1,totalLabels);
for j = 1:totalLabels
    sizeBlob(j) = length(find(imlabel == j));
end
[~, largestBlobNo] =  max(sizeBlob);
axonTrace = axonTrace(imlabel == largestBlobNo,:);
axonImage = figData.stackDataShuffled{cs}(:,:,z);
axonImageRoi = axonImage(yrange,xrange);
% axon_in = figData.high_in{1};
% axon_out = figData.high_out{1};
imshow(imadjust(axonImageRoi, []));
axonTrace(:,1) = axonTrace(:,1) - min(xrange)+1;
axonTrace(:,2) = axonTrace(:,2) - min(yrange)+1;
plot(axonTrace(:,1),axonTrace(:,2));

subplot(1,3,1);
hold on
plot(axonTrace(:,1),axonTrace(:,2));
axonImage = figData.stackDataShuffled{cs}(:,:,z);
axonImageRoi = axonImage(yrange,xrange);

imshow(imadjust(axonImageRoi, []));

%%
figure
plotBackboneIndex(1437,1,figData)
plotBackboneIndex(1350,2,figData)
plotBackboneIndex(1375,3,figData)


%%
figure
cs = 3;
idx = 1500;


center = figData.axonTraceSnapSkipped{cs}{2}(idx,1:3);
yrange = (center(1)-250):(center(1)+300);
xrange = (center(2)-75):(center(2)+75);
z = center(3);

indices = figData.axonTraceSnapSkipped{cs}{2}(:,1:3);
indices = [indices,(1:size(indices,1))'];
indices = indices(indices(:,1)>min(yrange) & indices(:,1)<max(yrange),:);
indices = indices(indices(:,2)>min(xrange) & indices(:,2)<max(xrange),:);
zrange = min(indices(:,3)):max(indices(:,3));
temp = indices;
indices = indices(:,4);

for i = 1:length(zrange)
    zstep = zrange(i);
    [imlabel,totalLabels] = bwlabel(temp(:,3) == zstep);
    for j = 1:totalLabels
        xtrans{i}(j,:) = [temp(min(find(imlabel == j)),1), temp(max(find(imlabel == j)),1)];
    end
end

axonImage = figData.stackDataShuffled{cs}(:,:,zrange);
axonRoi = nan(size(axonImage));
for i = 1:length(xtrans)
    for j = 1:size(xtrans{i},1)
        range = xtrans{i}(j,1):xtrans{i}(j,2);
        axonRoi(:,range) = axonImage(:,range,i);
    end
end
axonRoi = axonRoi(xrange, yrange);

axonCrosses = figData.axonCrossFitCutPoints{cs}{2};
% axonCrosses = figData.axonCrossFitCutPoints{cs}{2}(indices,:);
% axonCrosses = axonCrosses(~isnan(axonCrosses(:,1)),:);

boutonCrosses = figData.boutonCrossSegment{cs}{2};

axonWidths = figData.axonCrossFitLengths{cs}{2};

axonCrossesy = [axonCrosses(:,1),axonCrosses(:,3)];
axonCrossesx = [axonCrosses(:,2),axonCrosses(:,4)];
axonCrosses2 = all([all([axonCrossesx>min(xrange)],2) & all([axonCrossesx<max(xrange)],2) & all([axonCrossesy>min(yrange)],2) & all([axonCrossesy<max(yrange)],2)],2);
axonCrosses3 = axonCrosses(axonCrosses2,:);
axonCrosses4 = [mean([axonCrosses(:,1),axonCrosses(:,3)],2),mean([axonCrosses(:,2),axonCrosses(:,4)],2)];
crossindices = nan(size(axonCrosses4,1),1);
axonTrace = figData.axonTraceSnapSkipped{cs}{2};
for i = 1:size(axonCrosses4,1)
   if ~isnan(axonCrosses4(i,1))
        centdiff = sqrt((axonTrace(:,1) - axonCrosses4(i,1)).^2 + (axonTrace(:,2)-axonCrosses4(i,2)).^2);
        [~,ind] = min(centdiff);
        crossindices(i) = min(ind);
   end
end
axonWidths = axonWidths(axonCrosses2);
crossindices2 = crossindices(axonCrosses2);

boutonWidths = figData.boutonWidth{cs}{2};
boutonFilter = figData.boutonCenter{cs}{2};
boutonFilter2 = all([boutonFilter(:,1)>min(yrange), boutonFilter(:,1)<max(yrange), boutonFilter(:,2)>min(xrange), boutonFilter(:,2)<max(xrange)],2);
boutonWidths2 = boutonWidths(boutonFilter2);




subplot(3,1,1);
imshow(imadjust(uint8(axonRoi),[],[]));

subplot(3,1,2);
imshow(imadjust(uint8(axonRoi),[],[]));
% imshow(imadjust(uint8(axonImage),[],[]));

hold on;
for i = 1:size(axonCrosses3,1)
    points = axonCrosses3(i,:);
    plot([points(1),points(3)]-min(yrange)+1, [points(2),points(4)]-min(xrange)+1,'r');
%     plot([points(1),points(3)], [points(2),points(4)],'-or')
end

for i = 1:figData.maxBouton(2)
    points = boutonCrosses{i};
    plot(points(:,1)-min(yrange)+1, points(:,2)-min(xrange)+1,'g');
%     plot(points(:,1), points(:,2), '-og')
end

subplot(3,1,3);

distance = figData.axonTraceSnapSkipped{cs}{2}(:,1:2);
distance = [0;sqrt(sum(diff(distance).^2,2))];
distance = cumsum(distance)/10;


hold on;
[crossindices3,sortOrder] = sort(crossindices2);
plot(distance(crossindices3)-distance(min(crossindices3)), axonWidths(sortOrder),'.r');
boutonIdx = boutonFilter(boutonFilter2,4);
for i = 1:length(boutonWidths2)
    plot(distance(boutonIdx(i))-distance(min(crossindices3)),boutonWidths2{i},'xg')
end
plot(distance(crossindices3)-distance(min(crossindices3)),medfilt1(axonWidths(sortOrder),5),'k')
plot(distance(crossindices3)-distance(min(crossindices3)),medfilt1(axonWidths(sortOrder),5)+3,':','Color',[0.5,0.5,0.5]);
axis([-32,95,0,25])
