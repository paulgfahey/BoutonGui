tic
degStep = 2.5;
degRange = 45;
degSet = 90-degRange:degStep:90+degRange;
axonTraceFull = figData.axonTraceSnapSkipped{2}{1};
n = 2;
stdevCut = .75;
interpN = 100;
medFiltN = 7;
lengthTrace = size(axonTraceFull,1);

%downsample axon trace by factor of n, then find x/y/int mid points and transfer z
axonTrace = axonTraceFull(1:n:end,:);
traceCenters = axonTrace(1:end-1,1:2) + diff(axonTrace(:,1:2))/2;
traceCenters(:,3) = axonTrace(1:end-1,3);
traceCenters(:,4) = axonTrace(1:end-1,4) + diff(axonTrace(:,4))/2;

%filter for boutons, nans, zeros, inf
ints = traceCenters(:,4);
traceFilter = ~any([isnan(ints), isinf(ints), ints == 0, ints > 1.8],2);
traceCenters = traceCenters(traceFilter,:);

%transfer and filter idx from original trace
centerIdx = 1:n:lengthTrace;
centerIdx = centerIdx(traceFilter);

%find angles of downsampled segments
traceAng = atand(diff(axonTrace(1:end,2))./diff(axonTrace(1:end,1)));
traceAng = traceAng(traceFilter,:);


fittedAng = nan(length(degSet),1);
fittedPoints = nan(length(degSet),4);
fittedCutPoints = nan(length(degSet),5);

%test all potential centerpoints
for i = 1:length(traceAng(:,1))
    clear rotatedSeg
    clear intSeg
    clear coeff
    clear rotatedIntSetx
    clear rotatedIntSety
    
    %test range of angle set for each centerpoint
    for j = 1:length(degSet)
        %create affine rotation, searches 45 degrees on either side of anticipated perpendicular
        theta = degSet(j) + traceAng(i);
        tform = affine2d([cosd(theta) sind(theta) 0; -sind(theta) cosd(theta) 0; 0 0 1]);
        
        %rotate points around origin, then shift to traceCenters
        [points(1), points(2)] = transformPointsForward(tform,-interpN/2 + 1,0);
        [points(3), points(4)] = transformPointsForward(tform,interpN/2,0);
        points = points + [traceCenters(i,1:2), traceCenters(i,1:2)];
        
        %extract profile, perform gaussian fit, store x/y/int and fit parameters
        [intx,inty,int] = improfile(figData.stackDataShuffled{2}(:,:,traceCenters(i,3)),round([points(1),points(3)]),round([points(2),points(4)]),interpN);
        intfit = fit((1:interpN)',int,'gauss1', 'Lower',[0,0,0],'Upper',[100, interpN,100]);
        rotatedSeg(j,:) = points;
        rotatedIntSetx(j,:) = intx;
        rotatedIntSety(j,:) = inty;
        intSeg(j,:) = int;
        coeff(j,:) = coeffvalues(intfit);
    end
    
    %fit reciprocal of normalized stdev from individual fits, find angle corresponding to minimum stdev
    [sdFit,gof] = fit([1:length(degSet)]',1-(coeff(:,3)./max(coeff(:,3))),'gauss1', 'Lower',[0,0,0],'Upper',[100,length(degSet),100]);
    stCoeff = coeffvalues(sdFit);
    perpAng = round(stCoeff(2));
    
    %for good fits to stdev distribution, find cutoff of stdevCut x
    %stdev and extract fitted line along best angle
    if all([perpAng>1, perpAng<length(degSet)])
        cutoff = stdevCut*coeff(round(perpAng),3);
        if all([gof.sse<.1,gof.rsquare>.8, perpAng>1, perpAng<length(degSet), cutoff<interpN/2])
            %store fitted angle
            fittedAng = round(degSet(round(perpAng)) + traceAng(i));
            
            %store end points along segment along best angle
            fittedPoints(i,1:4) = rotatedSeg(perpAng,:);
            
            %store fitted points for cutoff segment
            fittedCutPoints(i,1) = rotatedIntSetx(round(perpAng),round(coeff(perpAng,2)-cutoff));
            fittedCutPoints(i,3) = rotatedIntSetx(round(perpAng),round(coeff(perpAng,2)+cutoff));
            fittedCutPoints(i,2) = rotatedIntSety(round(perpAng),round(coeff(perpAng,2)-cutoff));
            fittedCutPoints(i,4) = rotatedIntSety(round(perpAng),round(coeff(perpAng,2)+cutoff));
            fittedCutPoints(i,5) = traceCenters(i,3);
        end
    end
end

%find points along interp segment
fittedLengths = sqrt((fittedCutPoints(:,1)-fittedCutPoints(:,3)).^2 + (fittedCutPoints(:,2) - fittedCutPoints(:,4)).^2);

%discard nans for unsuitable fits, create corresponding idx key
fittedLengthsNanless = fittedLengths(~isnan(fittedLengths));
fittedLengthsIdx = centerIdx(~isnan(fittedLengths));

%perform median filter
fittedFilteredProfile = medfilt1(fittedLengthsNanless,medFiltN);

toc


x = unique(traceCenters(:,3));
for i = 1:length(x);
    figure;
    hold on;
    imlayer = figData.stackDataShuffled{2}(:,:,x(i));
    imshow(imadjust(imlayer,[0,.05], [0,1]))
    xlim([min(traceCenters(:,1))-100, max(traceCenters(:,1))+100]);
    ylim([min(traceCenters(:,2))-100, max(traceCenters(:,2))+100]);    
    layerSegs = fittedCutPoints(fittedCutPoints(:,5) == x(i),:);
    for j = 1:size(layerSegs,1)
        seg = layerSegs(j,:);
        hold on;
        line([seg(1),seg(3)],[seg(2),seg(4)])
    end
    snappedTrace = figData.axonTraceSnap{2}{1};
    plot(snappedTrace(:,1),snappedTrace(:,2),'b');
    skippedTrace = figData.axonTraceSnapSkipped{2}{1};
    skippedTraceNans = skippedTrace;
    skippedTraceNans(~isnan(skippedTrace(:,4)),:) = nan;
    plot(skippedTraceNans(:,1), skippedTraceNans(:,2),'r');
end



     