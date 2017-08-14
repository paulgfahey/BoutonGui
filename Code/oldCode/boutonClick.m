function boutonClick(hfig,~)
    %CALL BACK FUNCTION FOR ADDING BOUTONS
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,cb,cx,cy] = currentOut(hfig);
    
    cbs = figData.boutonStatus{cs}{ca}; %bouton status set for current axon
    cbc = figData.boutonCenter{cs}{ca}; %bouton center set for current axon
    
    
    if strcmp(buttonPressed,'alt')
        for k=1:size(cbc,1)
            if cbc(k,1)>cx-10 && cbc(k,1)<cx+10 && cbc(k,2)>cy-10 && cbc(k,2)<cy+10
                cbs(k,:) = nan(1,4);
                cbc(k,:) = nan(1,3);
                figData.boutonMask{cs}{ca}{k} = [];
                figData.boutonBoundary{cs}{ca}{k} = [];
                disp('Bouton deleted')
            end
        end
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            cbs(cb,:) = figData.boutonStatusMatrix;
            cbc(cb,:) = [cx, cy, figData.currentZ{cs}];
            [~,fit_mask,bounds] = adjMask(hfig);
            figData.boutonMask{cs}{ca}{cb} = fit_mask;
            figData.boutonBoundary{cs}{ca}{cb} = bounds{1};
            figData.boutonCross{cs}{ca}{cb} = {};
            
            set(hfig,'Name','Click to create axon region ','NumberTitle','off')
            set(hfig,'WindowButtonDownFcn',@axonRegionClick);
            set(hfig,'WindowButtonMotionFcn',@maskMotion);
            
            if figData.thresh*1.5>0
                figData.thresh = figData.thresh*1.75;
            else
                figData.thresh = .9;
            end
    
        end
    end
   
    figData.boutonStatus{cs}{ca} = cbs;
    figData.boutonCenter{cs}{ca} = cbc;
    
    
    guidata(hfig,figData);
    fullReplot(hfig);
end