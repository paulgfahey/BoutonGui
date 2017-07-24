function [hfig] = autoSkipAxonInt(hfig)
    %skips axon regions with median axon int below adjustable threshold
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
  
    %load unskipped median axon intensity
    medianInt = figData.axonBrightnessProfileBaseline{cs}{ca};
    
    %load unskipped axon intensity divided by median local axon intensity
    profile = figData.axonBrightnessProfileWeighted{cs}{ca};

    %load auto threshold for median axon int
    thresh = figData.autoSkipAxonIntThresh{cs}{ca};
    
    %set backbone regions < autothresh to nan;
    profile(medianInt(:,4)<thresh,4) = nan;
    
    %save autoskipped profile 
    figData.axonTraceSnapSkipped{cs}{ca} = profile;

    guidata(hfig,figData)
end
