function [cursor_mask,bounds] = backgroundAdjCursor(hfig,~,~,~,~)
    figData = guidata(hfig);
    [cs,~,~,cx,cy] = currentOut(hfig);
    cursor_mask = zeros(figData.dims{cs});
    r = 200;
    if cx > r/2 & cx < figData.dims{cs}-100 & cy > r/2 & cy < figData.dims{cs}-100
        cursor_mask(floor(cy-r/2):floor(cy+r/2),floor(cx-r/2):floor(cx+r/2)) = 1;
        bounds = bwboundaries(cursor_mask,4);
    else
        cursor_mask = [];
        bounds = {};
    end
    guidata(hfig,figData);
end