function backgroundClick(hfig,~)
    figData = guidata(hfig);
    buttonPressed = get(hfig,'SelectionType');
    [cs,~,~,cx,cy] = currentOut(hfig);
    
    if strcmp(buttonPressed,'alt')
       for k = 1:size(figData.backgroundMask{cs},1)
            if  figData.backgroundMask{cs}{k}(cx,cy) == 1 && figData.currentZ{cs} == figData.backgroundZ{cs}{k}
                figData.backgroundMask{cs}{k} = {};
            end
       end
    else
        if ~any([cx cy] < 0) && ~any([cx cy] > figData.dims{cs})
            currROI = size(figData.backgroundMask{cs},1) + 1;
            [cursor_mask,bounds] = backgroundAdjCursor(hfig);
            figData.backgroundZ{cs}{currROI} = figData.currentZ{cs};
            figData.backgroundMask{cs}{currROI} = cursor_mask;
            figData.backgroundBoundary{cs}{currROI} = bounds{1};
            for i = 1:size(figData.backgroundMask{cs},1)
                temp = figData.stackDataShuffled{cs}(:,:,figData.backgroundZ{cs}{i});
                figData.backgroundInt{cs}{end+1} = temp(logical(figData.backgroundMask{cs}{i}));
            end
        end
    end
    
    allInts = [];
    for j = 1:size(figData.backgroundInt{cs},1)
        allInts = [allInts;figData.backgroundInt{cs}{j}];
    end
    figData.backgroundMeanInt{cs} = mean(allInts);
    plot(bounds{1}(:,2), bounds{1}(:,1),'r')
    guidata(hfig,figData);
end