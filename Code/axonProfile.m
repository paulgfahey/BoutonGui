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
    
    %set values within skipped regions to nan
    csa = figData.axonSkipTrace{cs}{ca};
    for j = 2:2:size(csa,1)
       xj = sort(csa(j-1:j,1));
       yj = sort(csa(j-1:j,2));
       inti( xi>xj(1) & xi<xj(2) & yi>yj(1) & yi<yj(2)) = nan;
    end
    
    %raw profile with gaps
    intTrace = inti';
    figData.axonBrightnessProfile{cs}{ca} = [xi,yi,zi,intTrace];
    
    %interpolate across skip gaps
    interpBackbone = interpGaps(hfig,intTrace);
    
    %use median filter to find local baseline
    baseline = medfilt1(interpBackbone,100);
    figData.axonBrightnessProfileBaseline{cs}{ca} = [xi,yi,zi,baseline'];
    figData.axonBrightnessProfileWeighted{cs}{ca} = [xi,yi,zi,intTrace./baseline];
    
    %add segments with < 2* median background to skipAxonTrace
    threshIntTrace= intTrace ./ baseline;
    threshIntTrace = interpGaps(hfig,threshIntTrace);
    threshIntTrace(threshIntTrace < 2*figData.medianBackgroundIntensity) = nan;
    skipGaps(hfig,threshIntTrace,xi,yi,zi);
    figData.axonBrightnessProfileWeightedThresh{cs}{ca} = [xi,yi,zi,threshIntTrace];
    
    
    %find remaining points with intensity >1.75 greater than local median intensity
    peaks = threshIntTrace;
    peaks(peaks>1.75) = nan;
    autoPeaks = [xi,yi,zi,peaks];
    autoPeaks(isnan(peaks),:) = nan;
    figData.axonWeightedBrightnessPeaks{cs}{ca} = autoPeaks;
    
    guidata(hfig,figData);
end

function interpBackbone = interpGaps(hfig, profile)
    %interpolate across nan gaps in intensity trace    
    figData = guidata(hfig);
    
    [imlabel,totalLabels] = bwlabel(isnan(profile));
    for j = 1:totalLabels
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        sizeGap = length(find(imlabel == j));
        indprev = profile(indfirst-1);
        indpost = profile(indlast+1);
        interpGap= interp1([1,sizeGap+2],[indprev,indpost],1:sizeGap+2);
        profile(indfirst:indlast) = interpGap(2:end-1);
    end
    interpBackbone = profile;
    guidata(hfig,figData);
end

function skipGaps(hfig,profile,xi,yi,zi)
    %add nan gaps to skip axon trace
    figData = guidata(hfig);
    csa = figData.axonSkipTrace{cs}{ca};
    
    [imlabel,totalLabels] = bwlabel(isnan(profile));
    for j = 1:totalLabels
        skipIndx = size(csa,1) + 1 - mod(size(csa,1),2);
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        indprev = profile(indfirst-1);
        indpost = profile(indlast+1);
        csa(skipIndx,:) = [xi(indprev-10),yi(indprev-10),zi(indprev)];
        csa(end+1,:) = [xi(indpost+10),yi(indpost+10),zi(indpost)];
    end
    hfig = snapAndRemoveSkip(hfig);
    figData = guidata(hfig);
    guidata(hfig,figData)
end
