function hfig = autoSkipIntThreshold(hfig,direction)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    figData.autoSkipAxonThresh{cs}{ca} = figData.autoSkipAxonThresh{cs}{ca} + (.5 * direction);
    guidata(hfig,figData);
    hfig = axonProfile(hfig);
end