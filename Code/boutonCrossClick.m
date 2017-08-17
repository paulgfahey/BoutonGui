function boutonCrossClick(hfig,~)
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,cb,cx,cy] = currentOut(hfig);
    
    cbcs = figData.boutonCross{cs}{ca}{cb}; %current bouton cross set
    cbs = figData.boutonStatus{cs}{ca};
    cbc = figData.boutonCenter{cs}{ca};
    
    if isempty(cbcs) && ~strcmp(buttonPressed,'alt')
        cbcs = [cx, cy, figData.currentZ{cs}];
    elseif strcmp(buttonPressed, 'alt')
        klist = [];
        for k=1:size(cbc,1)
            if cbc(k,1)>cx-15 && cbc(k,1)<cx+15 && cbc(k,2)>cy-15 && cbc(k,2)<cy+15
                klist(end+1) = k; %#ok<AGROW>
            end
        end
        if ~isempty(klist)
            cbcs = [];
            cbs(klist,:) = nan;
            cbc(klist,:) = nan;
            disp('Bouton Deleted')
        end
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            cbcs(end+1,:) = [cx, cy, figData.currentZ{cs}];
             if size(cbcs,1) >= 2
                cbs(cb,:) = figData.boutonStatusMatrix;
                [~,cbc(cb,:),~,~] = segmentWidth(cbcs(1:2,:),hfig,.5,0,cs,ca);

                figData.currBouton{cs}{ca} = figData.currBouton{cs}{ca} + 1;
                
                set(hfig,'Name','Click to add local axon diameter','NumberTitle','off')
                set(hfig,'WindowButtonDownFcn',{@axonCrossClick});
            end
        end
    end
    
    figData.boutonCross{cs}{ca}{cb} = cbcs;
    figData.boutonStatus{cs}{ca} = cbs;
    figData.boutonCenter{cs}{ca} = cbc;
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end