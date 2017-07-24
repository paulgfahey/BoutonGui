function hfig = roiSnapAndSkip(hfig)
    %snaps manually indicated ROI to backbone and removes from trace
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    %parses axon skip trace into pairs
    csa = figData.axonSkipTrace{cs}{ca};
    lastSegment = find(mod(1:size(csa,1),2)==0,1,'last');
    segments = csa(1:lastSegment,:);

    %load skipped profile from autoSkipAxonInt
    profile = figData.axonTraceSnapSkipped{cs}{ca};
    
    %skips all points in roi pairs
    if ~isempty(segments)
        for i = 2:2:size(segments,1)
            %create box for each pair of skip points
            xi = sort(csa(i-1:i,1));
            yi = sort(csa(i-1:i,2));
            
            %find all snapped backbone points in box
            profile(profile(:,1)>xi(1) & profile(:,1)<xi(2)...
                & profile(:,2)>yi(1) & profile(:,2)<yi(2),4) = nan;
        end
    end
    
    %save autoskipped profile
    figData.axonTraceSnapSkipped{cs}{ca} = profile;
    
    guidata(hfig,figData)
end