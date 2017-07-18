function boutonCrossClick(hfig,~)
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,cb,cx,cy] = currentOut(hfig);
    
    cbcs = figData.boutonCross{cs}{ca}{cb}; %current bouton cross set
    
    if isempty(cbcs)
        cbcs = [cx, cy, figData.currentZ{cs}];
    elseif strcmp(buttonPressed, 'alt')
        klist = [];
        for k=1:size(cbcs,1)
            if cbcs(k,1)>cx-5 && cbcs(k,1)<cx+5 && cbcs(k,2)>cy-5 && cbcs(k,2)<cy+5
                klist(end+1) = k;
            end
        end
        if ~isempty(klist)
            klist = [klist,(klist-1+2*mod(klist,2))];
            cbcs(klist,:) = [];
            disp('Segment Deleted')
        end
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            cbcs(end+1,:) = [cx, cy, figData.currentZ{cs}];
             if size(cbcs,1) >= 4
                figData.currBouton{cs}{ca} = figData.currBouton{cs}{ca} +1;
                figData.boutonCross{cs}{ca}{figData.currBouton{cs}{ca}} = {};
                set(hfig,'Name','Click to Add boutons','NumberTitle','off')
                set(hfig,'WindowButtonDownFcn',{@boutonClick});
                set(hfig,'WindowButtonMotionFcn',@maskMotion);
            end
        end
    end
    
    figData.boutonCross{cs}{ca}{cb} = cbcs;
    
    
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end