function clearBouton(hfig)
    [cs,ca,cb,~,~] = currentOut(hfig);
    figData = guidata(hfig);
    
    figData.boutonCenter{cs}{ca}(cb,1:3) = nan(1,3);
    figData.boutonStatus{cs}{ca}(cb,1:4) = nan(1,4);
    figData.boutonCross{cs}{ca}{cb} = {};
    figData.boutonWidth{cs}{ca}{cb} = {};
    figData.boutonCrossProfile{cs}{ca}{cb} = {};
    figData.boutonCrossSegment{cs}{ca}{cb} = {};
    
    figData.axonCross{cs}{ca}{cb} = {};
    figData.localAxonWidth{cs}{ca}{cb} = {};
    figData.localAxonCenter{cs}{ca}{cb} = {};
    figData.localAxonCrossProfile{cs}{ca}{cb} = {};
    figData.localAxonCrossSegment{cs}{ca}{cb} = {};
    
    figData.boutonPeakInt{cs}{ca}{cb} = {};
    
    disp('bouton cleared')
    guidata(hfig,figData);
    fullReplot(hfig); 

end