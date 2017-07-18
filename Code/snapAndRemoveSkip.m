function hfig = snapAndRemoveSkip(hfig)
    %pulls skip traces to snapped backbone, separately saves skipped axon
    %backbone
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    %parses axon skip trace into pairs
    csa = figData.axonSkipTrace{cs}{ca};
    lastSegment = find(mod(1:size(csa,1),2)==0,1,'last');
    segments = csa(1:lastSegment,:);

    %snapped backbone trace
    snapped = figData.axonTraceSnap{cs}{ca};
    snapSkipped = snapped;
    
    %recalculated each time function is called
    skipSnap = {};
    traceLengthSkipped = 0;

    if ~isempty(segments)
        for i = 2:2:size(segments,1)
            %create box for each pair of skip points
            xi = sort(csa(i-1:i,1));
            yi = sort(csa(i-1:i,2));
            
            %find all snapped backbone points in box
            skipSnap{end+1} = snapped(snapped(:,1)>xi(1) & snapped(:,1)<xi(2) & snapped(:,2)>yi(1) & snapped(:,2)<yi(2),:); %#ok<AGROW>
            
            %set all snapped backbone points in box to nan
            snapSkipped(ismember(snapped,skipSnap{end},'rows'))  = nan;
            
            %calculate length of axon skipped
            traceLengthSkipped = traceLengthSkipped + sum(sqrt(sum(diff(skipSnap{end}(:,1:2)).^2,2)));
        end
    end
    
    %does not replace variables for original snapped or clicked traces
    figData.axonSkipTraceSnap{cs}{ca} = skipSnap;
    figData.axonTraceSnapSkipped{cs}{ca} = snapSkipped;
    figData.axonSkipTraceSnapLength{cs}{ca} = traceLengthSkipped;
    guidata(hfig,figData);
end