function clearBouton(hfig)
    [cs,ca,cb,~,~] = currentOut(hfig);
    figData = guidata(hfig);
    figData.boutonCenter{cs}{ca}(cb,:) = nan(1,size(figData.boutonCenter,2));
    figData.boutonStatus{cs}{ca}(cb,:) = nan(1,size(figData.boutonStatus,2));
    figData.boutonBoundary{cs}{ca}{cb} = {};
    figData.boutonMask{cs}{ca}{cb} = {};
    figData.boutonCross{cs}{ca}{cb} = {};
    figData.axonCross{cs}{ca}{cb} = {};
    figData.axonRegionCenter{cs}{ca}(cb,:) = nan;
    figData.axonMask{cs}{ca}{cb} = {};
    figData.axonBoundary{cs}{ca}{cb} = {};
    disp('bouton cleared')
    guidata(hfig,figData);
    fullReplot(hfig); 

end