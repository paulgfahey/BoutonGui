
function [cs, ca, cb, cx, cy] = currentOut(hfig)
%shortens commonly used current stack/axon/bouton/x/y for abbr access
    
    figData = guidata(hfig);
    cs = figData.cs;
    ca = figData.currAxon{cs};
    cb = figData.currBouton{cs}{ca};
    currPoint = get(gca,'CurrentPoint');
    cx = round(currPoint(1,1));
    cy = round(currPoint(1,2));
end
