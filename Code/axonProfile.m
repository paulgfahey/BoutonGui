function [hfig] = axonProfile(hfig)
    %calculates axon intensity profile from snapped trace, autodetects
    %peaks above 1.75x local median intensity
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    n = 1; %rough distance between interpolated points
    
    % extract snapped trace components and parameters
    trace = figData.axonTraceSnap{cs}{ca};
    clickedX = trace(:,1);
    clickedY = trace(:,2);
    clickedZ = trace(:,3);
    traceLength = round(sum(sqrt(sum(diff(trace(:,1:2)).^2,2))));
    traceSize = size(trace,1);
    
    %interpolate trace every ~n pixels
    [xinterp,yinterp,~] = improfile(zeros(figData.dims{cs}),trace(:,1),trace(:,2),traceLength/n);
    
    %z interp assigns clickedZ to interpolated points between clicked points
    zinterp = nan(size(xinterp,1),1);
    for i = 1:traceSize-1
        xi = sort([clickedX(i),clickedX(i+1)]);
        yi = sort([clickedY(i),clickedY(i+1)]);
        zi = clickedZ(i);
        zinterp(xinterp>=xi(1) & xinterp<=xi(2) & yinterp>=yi(1) & yinterp <= yi(2)) = zi;
    end
    
    %round to nearest pixel
    xi = round(xinterp);
    yi = round(yinterp);
    zi = zinterp;
    inti = nan(1,length(xi));
    
    %move through planes, extracting intensity for in-plane pixels
    for j = min(zi):max(zi)
       [ind] = find(zi == j);
       plane = figData.stackDataShuffled{cs}(:,:,j);
       int = plane(sub2ind(figData.dims{cs},yi(ind),xi(ind)));
       inti(ind) = int;
    end
    
    %raw profile, no gaps
    intTrace = inti';
    figData.axonBrightnessProfile{cs}{ca} = [xi,yi,zi,intTrace];
    
    %median filter raw profile
    baseline1 = medfilt1(intTrace,101);
    
    %remove peaks using <1.2* local baseline threshold, repeat median filter on axon only
    noPeaks = intTrace;
    noPeaks(noPeaks > 1.2*baseline1') = nan;
    
    %interpolate across missing peaks, repeat median filter on axon only
    noPeaksInterp = interpGaps(hfig,noPeaks);
    baseline2 = medfilt1(noPeaksInterp,41);
    
    %save baseline as local median filtered axon intensity
    figData.axonBrightnessProfileBaseline{cs}{ca} = [xi,yi,zi,baseline2'];
    
    %save weighted,unskipped profile
    figData.axonBrightnessProfileWeighted{cs}{ca} = [xi,yi,zi,intTrace./baseline2'];
    
    %use baseline to autoskip regions below adjustable threshold
    guidata(hfig,figData);
    hfig = autoSkipAxonInt(hfig);
    
    %use length of remaining regions to exclude axon segments too short
    hfig = autoSkipAxonLength(hfig);
    
    %use manual clicked points to skip regions within ROI
    hfig = roiSnapAndSkip(hfig);
    figData = guidata(hfig);
    
    %calculate raw trace length
    figData.axonTraceSnapLength{cs}{ca} = sum(sqrt(sum(diff([xi;yi]).^2,2)));
    
    %calculate length of trace skipped
    profile = figData.axonTraceSnapSkipped{cs}{ca};
    traceLengthSkipped = 0;
    xm = profile(:,1);
    ym = profile(:,2);
    [imlabel,totalLabels] = bwlabel(isnan(profile(:,4)));
    for j = 1:totalLabels
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        skipped = [xm(indfirst:indlast),ym(indfirst:indlast)];
        traceLengthSkipped = traceLengthSkipped + sum(sqrt(sum(diff(skipped).^2,2)));
    end
    figData.axonSkipTraceLength{cs}{ca} = traceLengthSkipped;
    
    %calculate remaining axon trace length
    figData.axonIncludedTraceLength{cs}{ca} = figData.axonTraceSnapLength{cs}{ca} - traceLengthSkipped;
    
    %detect suggested points with intensity >1.75 greater than local median intensity
    peaks = figData.axonTraceSnapSkipped{cs}{ca}(:,4);
    peaks(peaks<1.75) = nan;
    autoPeaks = [xi,yi,zi,peaks];
    figData.axonWeightedBrightnessPeaks{cs}{ca} = autoPeaks;
    
    guidata(hfig,figData);
    
    fullReplot(hfig);
end