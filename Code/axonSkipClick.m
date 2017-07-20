function axonSkipClick(hfig,~)
    %CALL BACK FUNCTION FOR SKIPPING AXON LENGTH
    %assume that every two points creates a box around skipped axon
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType'); 
    [cs,ca,~,cx,cy] = currentOut(hfig);
    csa = figData.axonSkipTrace{cs}{ca}; %current skip axon being traced
    
    if isempty(csa) && ~strcmp(buttonPressed,'alt')
            csa = [cx, cy, figData.currentZ{cs}];
            figData.axonSkipTraceSnap{cs}{ca} = csa;
            
    elseif strcmp(buttonPressed,'alt') %remove paired points w/i 15 units of alt-clicked location
        klist = [];
        for k=1:size(csa,1)
            if csa(k,1)>cx-15 && csa(k,1)<cx+15 && csa(k,2)>cy-15 && csa(k,2)<cy+15
                klist(end+1) = k; %#ok<AGROW>
            end
        end
        if ~isempty(klist)
            klist = [klist, (klist-1+2*mod(klist,2))];
            csa(klist,:) = [];
            disp('Segment deleted')
        end
        
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            csa(end+1,1:3)=[cx cy figData.currentZ{cs}]; %add clicked location to skipped axon trace   
        end
    end
    
    figData.axonSkipTrace{cs}{ca} = csa;
    guidata(hfig,figData);
    
    hfig = snapAndRemoveSkip(hfig);  %shifts skipped region to axon backbone
    figData = guidata(hfig);
    guidata(hfig,figData);
    fullReplot(hfig);
end
