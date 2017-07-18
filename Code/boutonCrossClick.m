function boutonCrossClick(hfig,~)
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,cb,cx,cy] = currentOut(hfig);
    
    cbcs = figData.boutonCross{cs}{ca}{cb}; %current bouton cross set
    cbw = figData.boutonWidth{cs}{ca}{cb};
    cbcp = figData.boutonCrossProfile{cs}{ca}{cb};
    cbcseg = figData.boutonCrossSegment{cs}{ca}{cb};
    law = figData.localAxonWidth{cs}{ca}{cb};
    lacp = figData.localAxonCrossProfile{cs}{ca}{cb};
    lacseg = figData.localAxonCrossSegment{cs}{ca}{cb};
    cbs = figData.boutonStatus{cs}{ca};
    cbc = figData.boutonCenter{cs}{ca};
    
    
    
    
    if isempty(cbcs) && ~strcmp(buttonPRessed,'alt')
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
            cbs(klist,:) = nan(1,4);
            cbc(klist,:) = nan(1,3);
            disp('Bouton Deleted')
        end
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            cbcs(end+1,:) = [cx, cy, figData.currentZ{cs}];
             if size(cbcs,1) >= 4
                cbs(cb,:) = figData.boutonStatusMatrix;
                [cbw,cbc(cb,:),cbcp,cbcseg] = segmentWidth(cbcs(3:4,1:2),hfig);
                [law,~,lacp,lacseg] = segmentWidth(cbcs(1:2,1:2),hfig);
                
                
                figData.currBouton{cs}{ca} = figData.currBouton{cs}{ca} +1;
                figData.boutonCross{cs}{ca}{figData.currBouton{cs}{ca}} = {};
                set(hfig,'Name','Click to Add boutons','NumberTitle','off')
                set(hfig,'WindowButtonDownFcn',{@boutonClick});
                set(hfig,'WindowButtonMotionFcn',@maskMotion);
            end
        end
    end
    
    figData.boutonCross{cs}{ca}{cb} = cbcs;
    figData.boutonStatus{cs}{ca} = cbs;
    figData.boutonCenter{cs}{ca} = cbc;
    
    
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end