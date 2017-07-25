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
                law = [];
                lac = [];
                lacp = {};
                lacseg = [];

                for i = 1:floor(size(cacs,1)/2)
                    [lawi,laci,lacpi,lacsegi] = segmentWidth(cacs(2*i-1:2*i,:),hfig,.5,0);
                    law = [law;lawi]; %#ok<*AGROW>
                    lac = [lac;laci];
                    lacp{end+1} = lacpi;
                    lacseg = [lacseg;lacsegi];
                end
                
                figData.localAxonWidth{cs}{ca}{cb} = law;
                figData.localAxonCenter{cs}{ca}{cb} = lac;
                figData.localAxonCrossProfile{cs}{ca}{cb} = lacp;
                figData.localAxonCrossSegment{cs}{ca}{cb} = lacseg;
                
                set(hfig,'Name','Click to add boutons','NumberTitle','off')
                set(hfig,'WindowButtonDownFcn',{@boutonCrossClick});
                
            end
        end
    end
    
                
    figData.axonCross{cs}{ca}{cb} = cacs;
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end


    
