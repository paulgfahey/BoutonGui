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
    
    %save unfiltered axon brightness profile
    intTrace = inti';
    figData.axonBrightnessProfile{cs}{ca} = [xi,yi,zi,intTrace];
    
    baseline = medfilt1(intTrace,30);
    
    interpBackbone = interpPeaks(hfig,intTrace,baseline);
    figData.axonBrightnessProfilePeaksInterp{cs}{ca} = [xi,yi,zi,interpBackbone];
    
    %use median filter to establish and subtract local baseline
    
    intTrace = intTrace - baseline';
    
    %adjust trace to avoid negative values, save absolute minimum
    if min(intTrace)<0
        figData.axonBrightnessNormBaseline{cs}{ca} = abs(min(intTrace));
        intTrace = intTrace + abs(min(intTrace));
    else
        figData.axonBrightnessNormBaseline{cs}{ca} = 0;
    end
    
    %save weights, weighted brightness, and median weighted brightness
    figData.axonBrightnessProfileWeights{cs}{ca} = [xi,yi,zi,baseline'];
    figData.axonBrightnessProfileWeighted{cs}{ca} = [xi,yi,zi,intTrace];
    figData.axonWeightedBrightnessMedian{cs}{ca} = nanmedian(intTrace);
    
    %find points with intensity >1.75 greater than local median intensity
    peaks = intTrace/nanmedian(intTrace);
    peaks(peaks<1.75) = nan;
    autoPeaks = [xi,yi,zi,peaks];
    autoPeaks(isnan(peaks),:) = nan;
    figData.axonWeightedBrightnessPeaks{cs}{ca} = autoPeaks;
    
    guidata(hfig,figData);
end

function interpBackbone = interpPeaks(hfig, rawBrightnessProfile, medFilteredProfile)
    figData = guidata(hfig);
    
    %remove gaps from skipTrace
    [imlabel,totalLabels] = bwlabel(isnan(rawBrightnessProfile));
    for j = 1:totalLabels
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        sizePeak = length(find(imlabel == j));
        indprev = rawBrightnessProfile(indfirst-1);
        indpost = rawBrightnessProfile(indlast+1);
        interpGap = interp1([1,sizePeak+2],[indprev,indpost],1:sizePeak+2);
        rawBrightnessProfile(indfirst:indlast) = interpGap(2:end-1);
    end
    
    %remove peaks and plug gaps with interpolated values
    noPeaks = rawBrightnessProfile;
    noPeaks(noPeaks>medFilteredProfile') = nan;
    [imlabel,totalLabels] = bwlabel(isnan(noPeaks));
    for j = 1:totalLabels
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        sizePeak = length(find(imlabel == j));
        indprev = noPeaks(indfirst-1);
        indpost = noPeaks(indlast+1);
        interpPeak = interp1([1,sizePeak+2],[indprev,indpost],1:sizePeak+2);
        noPeaks(indfirst:indlast) = interpPeak(2:end-1);
    end
    interpBackbone = noPeaks;
    guidata(hfig,figData);
end
