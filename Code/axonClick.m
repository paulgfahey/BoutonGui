 function axonClick(hfig,~)
    %CALL BACK FUNCTION FOR TRACING AXONS
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,~,cx,cy] = currentOut(hfig);
    
    cats = figData.axonTrace{cs};   %axon trace set for current stack
    cat = cats{ca};                 %trace for current axon
    catsnap = figData.axonTraceSnap{cs}{ca};  %snapped trace for current axon
    catsnapskip = figData.axonTraceSnapSkipped{cs}{ca};

    
    if isempty(cats{ca})
        % if empty, just adds current point
        cat = [cx, cy, figData.currentZ{cs}, double(figData.stackDataShuffled{cs}(cx,cy,figData.currentZ{cs}))];
        catsnap = cat;
        catsnapskip = cat;
    elseif strcmp(buttonPressed,'alt') 
        %remove clicked segements w/i 5 units of alt-clicked location
        klist = [];
        for k=1:size(cat,1)
            if cat(k,1)>cx-15 && cat(k,1)<cx+15 && cat(k,2)>cy-15 && cat(k,2)<cy+15
                klist(end+1) = k; %#ok<*AGROW>
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
        
        nlist = [];
        for m=1:size(catsnapskip)
            if catsnapskip(m,1)>cx-15 && catsnapskip(m,1)<cx+15 && catsnapskip(m,2)>cy-15 && catsnapskip(m,2)<cy+15
                nlist(end+1) = m;
            end
        end
        
        if ~isempty(nlist)
            catsnapskip(nlist,:) = [];
            disp('Segment deleted');
        end
        
        
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            cat(end+1,1:4)=[cx cy figData.currentZ{cs},double(figData.stackDataShuffled{cs}(cy,cx,figData.currentZ{cs}))]; %add clicked location to axon trace
            catsnap(end+1,1:4) = [cx,cy,figData.currentZ{cs},double(figData.stackDataShuffled{cs}(cy,cx,figData.currentZ{cs}))]; %add clicked location to snapped axon trace
            catsnapskip(end+1,1:4) = [cx,cy,figData.currentZ{cs},double(figData.stackDataShuffled{cs}(cy,cx,figData.currentZ{cs}))]; %add clicked location to snapped skipped axon trace
        end
    end
    
    
    figData.axonTrace{cs}{ca} = cat;
    figData.axonTraceSnap{cs}{ca} = catsnap;
    figData.axonTraceSnapSkipped{cs}{ca} = catsnapskip;
    guidata(hfig,figData);
    fullReplot(hfig);
end
