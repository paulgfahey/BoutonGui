function clearAxon(hfig)
    [cs,ca,~,~,~] = currentOut(hfig);
    figData.axonTrace{cs}{ca} = {};
    figData.axonTraceSnap{cs}{ca} = {};
    figData.axonTraceSnapLength{cs}{ca} = {};
    figData.axonSkipTrace{cs}{ca} = {};
    figData.axonSkipTraceSnap{cs}{ca} = {};
    figData.axonSkipTraceLength{cs}{ca} = {};
    figData.axonTraceSnapSkipped{cs}{ca} = {};
    figData.axonBrightnessProfileWeighted{cs}{ca} = {};
    figData.axonWeightedBrightnessMedian{cs}{ca} = {};
    figData.axonWeightedBrightnessPeaks{cs}{ca} = {};
    guidata(hfig,figData);
    fullReplot(hfig);
end