function hfig = genAxonCross(hfig)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    %all final data for axon crosses saved in matrices same length as axon trace
    axonTraceFull = figData.axonTraceSnapSkipped{cs}{ca};
    fullLength = size(axonTraceFull,1);
    
    %downsample trace to create centers, calculate angles, save indices
    [traceCenters, traceAng, centerIdx] = genCenters(axonTraceFull);
    
    %create pointTransform for range of cross angles to explore, relative to estimated perpendicular
    degStep = 2.5;
    degRange = 20;
    degSet = 90-degRange:degStep:90+degRange;
    interpN = 25;
    
    %initially pass some fraction of randomly selected centers
    startCenters = min([50,length(traceCenters(:,1))]);
    indexOrder = randperm(length(traceCenters(:,1)));
    
    fittedAng = nan(size(centerIdx,1),1);
    fittedPoints = nan(size(centerIdx,1),5);
    fittedCutPoints = nan(size(centerIdx,1),5);
    
    minPoints = round(max([50,length(centerIdx)/5]));
    minPoints = min(minPoints,250);
    
    stringLen = 0;
    fprintf('\n');
%     disp('Testing Center: ')
    for n = 1:startCenters
        i = indexOrder(n);
        pointTransform = pointTransformSet(degSet, traceAng(i), interpN);
        [fittedAng(i,:), fittedPoints(i,:), fittedCutPoints(i,:)] = testCrosses(traceAng(i), traceCenters(i,:), pointTransform, cs, hfig,interpN, degSet);

        if mod(n,10) == 0
            fprintf(repmat('\b', 1, stringLen+1));
            stringLen = fprintf('%d tested out of %d, %d approved out of %d', n, length(traceCenters(:,1)), sum(~isnan(fittedPoints(:,1))), minPoints);
            fprintf('\n');
        end
    end
    
    while all([((n+1) < length(traceCenters(:,1))), (sum(~isnan(fittedPoints(:,1)))<minPoints)])
        n = n+1;
        i = indexOrder(n);
        pointTransform = pointTransformSet(degSet, traceAng(i), interpN);
        
        [fittedAng(i,:), fittedPoints(i,:), fittedCutPoints(i,:)] = testCrosses(traceAng(i), traceCenters(i,:), pointTransform, cs, hfig,interpN, degSet);

        if mod(n,10) == 0
            fprintf(repmat('\b', 1, stringLen+1));
            stringLen = fprintf('%d tested out of %d, %d approved out of %d', n, length(traceCenters(:,1)), sum(~isnan(fittedPoints(:,1))), minPoints);
            fprintf('\n');
        end
    end
    
    fittedLengths = sqrt((fittedCutPoints(:,1)-fittedCutPoints(:,3)).^2 + (fittedCutPoints(:,2) - fittedCutPoints(:,4)).^2);

    figData.axonCrossFitAng{cs}{ca} = nan(fullLength,1);
    figData.axonCrossFitPoints{cs}{ca} = nan(fullLength,5);
    figData.axonCrossFitCutPoints{cs}{ca} = nan(fullLength,5);
    figData.axonCrossFitLengths{cs}{ca} = nan(fullLength,1);
    
    figData.axonCrossFitAng{cs}{ca}(centerIdx) = fittedAng;
    figData.axonCrossFitPoints{cs}{ca}(centerIdx,:) = fittedPoints;
    figData.axonCrossFitCutPoints{cs}{ca}(centerIdx,:) = fittedCutPoints;
    figData.axonCrossFitLengths{cs}{ca}(centerIdx,:) = fittedLengths;
    
    guidata(hfig,figData);
end


function [traceCenters, traceAng, centerIdx] = genCenters(axonTraceFull)
    n = 3;                 %downsample factor
    intThresh = 1.8;        %norm to filtered axon running median intensity, removes boutons
    
    %downsample axon trace by factor of n, then find x/y/int mid points and transfer z
    axonTrace = axonTraceFull(1:n:end,:);
    traceCenters = axonTrace(1:end-1,1:2) + diff(axonTrace(:,1:2))/2;    %x/y
    traceCenters(:,3) = axonTrace(1:end-1,3);                            %z
    traceCenters(:,4) = axonTrace(1:end-1,4) + diff(axonTrace(:,4))/2;   %int
    
    %filter for boutons, nans, zeros, inf
    ints = traceCenters(:,4);
    traceFilter = ~any([isnan(ints), isinf(ints), ints == 0, ints > intThresh],2);
    traceCenters = traceCenters(traceFilter,:);
    
    %transfer and filter idx from original trace
    centerIdx = (1:n:size(axonTraceFull,1))';
    centerIdx = centerIdx(traceFilter);
    
    %find angles of downsampled segments
    traceAng = atand(diff(axonTrace(1:end,2))./diff(axonTrace(1:end,1)));
    traceAng = traceAng(traceFilter,:);
    
end

function pointTransform = pointTransformSet(degSet, traceAng, interpN)
    
    pointTransform = nan(length(degSet),4);
    for j = 1:length(degSet)
        theta = degSet(j)+traceAng;
        tform = affine2d([cosd(theta) sind(theta) 0; -sind(theta) cosd(theta) 0; 0 0 1]);
        
        %rotate points around origin, then shift to traceCenters
        [points(1), points(2)] = transformPointsForward(tform,-interpN/2 + 1,0);
        [points(3), points(4)] = transformPointsForward(tform,interpN/2,0);
        
        pointTransform(j,:) = points;
    end
end

function [fitAng, fitPoints, fitCutPoints] = testCrosses(testAngle, testCenter, pointTransform, cs, hfig, interpN, degSet)
    figData = guidata(hfig);
    
    %filter settings
    stdevCut = .75;

    pointSet = pointTransform + [testCenter(1:2), testCenter(1:2)];
    pointSetSize = size(pointSet,1);

    %test range of angle set for each centerpoint
    for j = 1:pointSetSize
        points = pointSet(j,:);
        
        %extract profile, perform gaussian fit, store x/y/int and fit parameters
        [intx,inty,int] = improfile(figData.stackDataShuffled{cs}(:,:,testCenter(3)),round([points(1),points(3)]),round([points(2),points(4)]),interpN);
        intFilt = ~isnan(int);
        int = int(intFilt);
        interpNSet = 1:interpN;
        interpNSet = interpNSet(intFilt);
        intfit = fit(interpNSet',int,'gauss1', 'Lower',[0,0,0],'Upper',[100, interpN,100]);
        rotatedSeg(j,:) = points;
        rotatedIntSetx(j,:) = intx;
        rotatedIntSety(j,:) = inty;
        coeff(j,:) = coeffvalues(intfit);
    end

    %fit reciprocal of normalized stdev from individual fits, find angle corresponding to minimum stdev
    [sdFit,gof] = fit((1:pointSetSize)',1-(coeff(:,3)./max(coeff(:,3))),'gauss1', 'Lower',[0,0,0],'Upper',[100,pointSetSize,100]);
    stCoeff = coeffvalues(sdFit);
    perpAng = round(stCoeff(2));

    %for good fits to stdev distribution, find cutoff of stdevCut x
    %stdev and extract fitted line along best angle
    fitAng = nan;
    fitPoints = nan(1,5);
    fitCutPoints = nan(1,5);
    
    if all([perpAng>1, perpAng<pointSetSize])
        cutoff = stdevCut*coeff(round(perpAng),3);
        if all([gof.sse<.1,gof.rsquare>.8, perpAng>1, perpAng<pointSetSize, coeff(perpAng,2)>(cutoff+1), (coeff(perpAng,2)+cutoff+1<interpN)])

%         if all([gof.sse<.1,gof.rsquare>.8, perpAng>1, perpAng<pointSetSize, cutoff<interpN/2, coeff(perpAng,2)>cutoff+1, (coeff(perpAng,2)+cutoff)<interpN])
            %store fitted angle
            fitAng = round(degSet(round(perpAng)) + testAngle);

            %store end points along segment along best angle
            fitPoints = [rotatedSeg(perpAng,:), testCenter(3)];

            %store fitted points for cutoff segment
            fitCutPoints(1) = rotatedIntSetx(round(perpAng),round(coeff(perpAng,2)-cutoff));
            fitCutPoints(3) = rotatedIntSetx(round(perpAng),round(coeff(perpAng,2)+cutoff));
            fitCutPoints(2) = rotatedIntSety(round(perpAng),round(coeff(perpAng,2)-cutoff));
            fitCutPoints(4) = rotatedIntSety(round(perpAng),round(coeff(perpAng,2)+cutoff));
            fitCutPoints(5) = testCenter(3);
        end
    end
end