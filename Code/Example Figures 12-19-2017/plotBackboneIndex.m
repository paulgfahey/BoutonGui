function plotBackboneIndex(idx,cs, figData)
center = figData.axonTraceSnapSkipped{cs}{2}(idx,1:3);
yrange = (center(1)-150):(center(1)+150);
xrange = (center(2)-75):(center(2)+75);
z = center(3);

indices = figData.axonTraceSnapSkipped{cs}{2}(:,1:3);
indices = [indices,(1:size(indices,1))'];
indices = indices(indices(:,1)>min(yrange) & indices(:,1)<max(yrange),:);
indices = indices(indices(:,2)>min(xrange) & indices(:,2)<max(xrange),:);
zrange = min(indices(:,3)):max(indices(:,3));
indices = indices(:,4);


axonImage = figData.stackDataShuffled{cs}(:,:,zrange);
axonImage = mean(axonImage,3);
axonRoi = axonImage(xrange, yrange);

axonTrace = figData.axonBrightnessProfile{cs}{2}(:,4);
axonTraceSkip = figData.axonTraceSnapSkipped{cs}{2}(:,4);
axonTraceSkip = isnan(axonTraceSkip);
axonTraceSkipped = axonTrace;
axonTraceSkipped(~axonTraceSkip) = nan;
axonTraceUnskipped = axonTrace;
axonTraceUnskipped(axonTraceSkip) = nan;
distance = figData.axonTraceSnapSkipped{cs}{2}(:,1:2);
distance = [0;sqrt(sum(diff(distance).^2,2))];
distance = cumsum(distance)/10;
axonBaseline = figData.axonBrightnessProfileBaseline{cs}{2}(:,4);
axonBaselineSkipped = axonBaseline;
axonBaselineSkipped(~axonTraceSkip) = nan;
axonBaselineUnskipped = axonBaseline;
axonBaselineUnskipped(axonTraceSkip) = nan;

subplot(3,3,(figData.stackKey(cs)-1)*3+1);
imshow(imadjust(uint8(axonRoi),[],[]));

subplot(3,3,(figData.stackKey(cs)-1)*3+2);
hold on
plot(distance(indices)-distance(indices(1)),axonTraceSkipped(indices),':','Color',[0.2 0.1 0.1])
plot(distance(indices)-distance(indices(1)),axonTraceUnskipped(indices),'k')
plot(distance(indices)-distance(indices(1)),axonBaselineSkipped(indices),':','Color','b');
plot(distance(indices)-distance(indices(1)),axonBaselineUnskipped(indices),'b');
axis([min(distance(indices)-distance(indices(1))), max(distance(indices)-distance(indices(1))), 0, 255]);

subplot(3,3,(figData.stackKey(cs)-1)*3+3);
plot(distance(indices)-distance(indices(1)),figData.axonTraceSnapSkipped{cs}{2}(indices,4),'k');
axis([min(distance(indices)-distance(indices(1))), max(distance(indices)-distance(indices(1))), 0, 10]);

end