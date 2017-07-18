 function axonClick(hfig,~)
    %CALL BACK FUNCTION FOR TRACING AXONS
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,~,cx,cy] = currentOut(hfig);
    
    cats = figData.axonTrace{cs};   %axon trace set for current stack
    cat = cats{ca};                 %trace for current axon
    catsnap = figData.axonTraceSnap{cs}{ca};  %snapped trace for current axon

    
    if isempty(cats{ca})
        % if empty, just adds current point
        cat = [cx, cy, figData.currentZ{cs}];
        catsnap = cat;
    elseif strcmp(buttonPressed,'alt') 
        %remove clicked segements w/i 5 units of alt-clicked location
        klist = [];
        for k=1:size(cat,1)
            if cat(k,1)>cx-15 && cat(k,1)<cx+15 && cat(k,2)>cy-15 && cat(k,2)<cy+15
                klist(end+1) = k;
            end
        end
        
        if ~isempty(klist)
            cat(klist,:)=[];
        end
        
        %remove snapped segements w/i 5 units of alt-clicked location
        mlist = [];
        for m=1:size(catsnap)
            if catsnap(m,1)>cx-15 && catsnap(m,1)<cx+15 && catsnap(m,2)>cy-15 && catsnap(m,2)<cy+15
                mlist(end+1) = m;
            end
        end
        
        if ~isempty(mlist)
            catsnap(mlist,:) = [];
            disp('Segment deleted');
        end
        
        
        
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            cat(end+1,1:3)=[cx cy figData.currentZ{cs}]; %add clicked location to axon trace
            catsnap(end+1,1:3) = [cx,cy,figData.currentZ{cs}]; %add clicked location to snapped axon trace
        end
    end
    
    
    figData.axonTrace{cs}{ca} = cat;
    figData.axonTraceSnap{cs}{ca} = catsnap;
    guidata(hfig,figData);
    fullReplot(hfig);
end
