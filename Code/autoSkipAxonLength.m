function hfig = autoSkipAxonLength(hfig)
    %skips axons regions below axon length threshold
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);

    %load skipped profile from autoSkipAxonInt
    profile = figData.axonTraceSnapSkipped{cs}{ca};
    xi = profile(:,1);
    yi = profile(:,2);

    %load axon length threshold
    thresh = figData.autoSkipAxonLengthThresh{cs}{ca};
    
    %detect remaining unskipped regions, skip those with length below
    %threshold
    [imlabel,totalLabels] = bwlabel(~isnan(profile(:,4)));
    for j = 1:totalLabels
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        segment = [xi(indfirst:indlast),yi(indfirst:indlast)];
        length = sum(sqrt(sum(diff(segment).^2,2)));
        if length < thresh
            profile(indfirst:indlast,4) = nan;
        end
    end
    
    %save skipped axon profile
    figData.axonTraceSnapSkipped{cs}{ca} = profile;
   
    guidata(hfig,figData)
end