function [cursor_mask,bounds] = adjCursor(hfig,~,~,~)
    figData = guidata(hfig);
    [cs,~,~,cx,cy] = currentOut(hfig);
    cursor_mask = zeros(figData.dims{cs});
    r = figData.radius;
    cursor_mask(floor(cy-r/2):floor(cy+r/2),floor(cx-r/2):floor(cx+r/2)) = 1;
    bounds = bwboundaries(cursor_mask,4);
    guidata(hfig, figData);
end