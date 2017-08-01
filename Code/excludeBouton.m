function excludeBouton(hfig,i,j,k)
    figData = guidata(hfig);
    
    figData.boutonCross{i}{j}{k} = {};
    figData.boutonWidth{i}{j}{k} = {};
    figData.boutonCrossProfile{i}{j}{k} = {};
    figData.boutonCrossSegment{i}{j}{k} = {};
    
    figData.axonCross{i}{j}{k} = {};
    figData.localAxonWidth{i}{j}{k} = {};
    figData.localAxonCenter{i}{j}{k} = {};
    figData.localAxonCrossProfile{i}{j}{k} = {};
    figData.localAxonCrossSegment{i}{j}{k} = {};
    
    figData.boutonPeakInt{i}{j}{k} = {};
    
    guidata(hfig,figData);
    fullReplot(hfig); 
end