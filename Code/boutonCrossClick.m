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
        for k=1:size(cbcs,1)
            if cbcs(k,1)>cx-5 && cbcs(k,1)<cx+5 && cbcs(k,2)>cy-5 && cbcs(k,2)<cy+5
                klist(end+1) = k; %#ok<AGROW>
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
                [cbw,cbc(cb,:),cbcp,cbcseg] = segmentWidth(cbcs(3:4,:),hfig);
                [law,lac,lacp,lacseg] = segmentWidth(cbcs(1:2,:),hfig);
                
                figData.boutonWidth{cs}{ca}{cb} = cbw;
                figData.boutonCrossProfile{cs}{ca}{cb} = cbcp;
                figData.boutonCrossSegment{cs}{ca}{cb} = cbcseg;
                figData.localAxonWidth{cs}{ca}{cb} = law;
                figData.localAxonCenter{cs}{ca}{cb} = lac;
                figData.localAxonCrossProfile{cs}{ca}{cb} = lacp;
                figData.localAxonCrossSegment{cs}{ca}{cb} = lacseg;
                
                figData.currBouton{cs}{ca} = figData.currBouton{cs}{ca} +1;
            end
        end
    end
    
    figData.boutonCross{cs}{ca}{cb} = cbcs;
    figData.boutonStatus{cs}{ca} = cbs;
    figData.boutonCenter{cs}{ca} = cbc;
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end