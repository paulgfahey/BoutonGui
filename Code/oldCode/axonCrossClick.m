function axonCrossClick(hfig,~)
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,ca,cb,cx,cy] = currentOut(hfig);
    
    cacs = figData.axonCross{cs}{ca}{cb};
    
    if isempty(cacs) && ~strcmp(buttonPressed,'alt')
        cacs = [cx, cy, figData.currentZ{cs}];
    elseif strcmp(buttonPressed,'alt')
        klist = [];
        for k = 1:size(cacs)
            if cacs(k,1)>cs-15 && cacs(k,1)<cx+15 && cacs(k,2)>cy-15 && cacs(k,2)<cy+15
                klist(end+1) = k; 
            end
        end
        if ~isempty(klist)
            for k = 1:size(klist,1)
                kpair = [k,k-1+2*mod(k,2)];
                cacs(kpair,:) = [];
                disp('axon cross deleted')
            end
        end
    else
        if ~any([cs cy]<0) && ~any([cx cy] > figData.dims{cs})
            cacs(end+1,:) = [cx, cy, figData.currentZ{cs}];
            if size(cacs,1)>=8
                set(hfig,'Name','Click to add boutons','NumberTitle','off')
                set(hfig,'WindowButtonDownFcn',{@boutonCrossClick});
            end
        end
    end
       
    figData.axonCross{cs}{ca}{cb} = cacs;
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end


    
