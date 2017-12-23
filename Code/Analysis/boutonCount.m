boutonsPerSite = {};
boutonsPerAxon = {};


uniqueMice = unique(combinedStruct.boutonMouse);

n = 0;

for i = 1:size(uniqueMice,1)
    boutonsPerSite{i,1} = uniqueMice{i};
    mouseIdx = strcmp(combinedStruct.boutonMouse,uniqueMice(i));
    mouseBoutons = combinedStruct.boutonPresence(mouseIdx);
    mouseBoutons = any(mouseBoutons == 1,2);
    mouseBoutons = sum(mouseBoutons);
    boutonsPerSite{i,2} = mouseBoutons;
    
    mouseAxons = unique(combinedStruct.boutonAxon(mouseIdx));
    for j = 1:size(mouseAxons)
        n = n+1;
        boutonsPerAxon{n,1} = uniqueMice{i};
        boutonsPerAxon{n,2} = mouseAxons(j);
        axonIdx = mouseIdx & combinedStruct.boutonAxon == mouseAxons(j);
        axonBoutons = combinedStruct.boutonPresence(axonIdx);
        axonBoutons = any(axonBoutons == 1,2);
        axonBoutons = sum(axonBoutons);
        boutonsPerAxon{n,3} = axonBoutons;
    end
end

    