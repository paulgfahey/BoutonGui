function axonRegionClick(hfig,~)
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,cb,cx,cy] = currentOut(hfig);
    
    arc = figData.axonRegionCenter{cs}{ca};
    
    if strcmp(buttonPressed,'alt')
        for k = 1:size(arc,1)
            if arc(k,1)>cx-10 && arc(k,1)<cx+10 && arc(k,2)>cy-10 && arc(k,2)<cy+10
                arc(k,:) = nan(1,3);
                figData.axonMask{cs}{ca}{k} = [];
                figData.axonBoundary{cs}{ca}{k} = [];
                disp('Axon Region deleted')
            end
        end
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            arc(cb,:) = [cx, cy, figData.currentZ{cs}];
            [~,fit_mask,bounds] = adjMask(hfig);
            figData.axonMask{cs}{ca}{cb} = fit_mask;
            figData.axonBoundary{cs}{ca}{cb} = bounds{1};
            figData.boutonCross{cs}{ca}{cb} = {};
            set(hfig,'Name','Click to trace across a bouton ','NumberTitle','off')
            set(hfig,'WindowButtonDownFcn',@boutonCrossClick);
            set(hfig,'WindowButtonMotionFcn','');
            figData.thresh = figData.thresh*.3;
        end
    end
    
    figData.axonRegionCenter{cs}{ca} = arc;
    

    
    
    guidata(hfig,figData);
    fullReplot(hfig);
end