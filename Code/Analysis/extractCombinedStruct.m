sourceFolder = uigetdir;
saveFolder = uigetdir;
originalFolder = cd(sourceFolder);

matlist = dir(sourceFolder);
matlist = matlist(3:end);

combinedStruct.axonMouse = [];
combinedStruct.boutonMouse = [];
combinedStruct.boutonAxon = [];
combinedStruct.axonLengths = [];
combinedStruct.boutonPresence = [];
combinedStruct.exclude = [];
combinedStruct.absboutonInt = [];
combinedStruct.normboutonInt = [];
combinedStruct.absboutonWidth = [];
combinedStruct.relboutonWidth = [];
combinedStruct.boutonPersist = [];
combinedStruct.boutonForm = [];
combinedStruct.boutonElim = [];
combinedStruct.times = [];

for i = 1:size(matlist,1)-1
    load(matlist(i).name);
    stackNum = figData.numStacks;
    mouse = figData.mouseFileName;
    disp(mouse);
    combinedStruct.axonMouse = [combinedStruct.axonMouse; repmat({mouse},size(outData.axonLengths,1),1)];
    combinedStruct.axonLengths = [combinedStruct.axonLengths; outData.axonLengths];
    
    combinedStruct.times = [combinedStruct.times; figData.stackfileName];
    
    axonNum = size(outData.boutonPresence,2);
    for j = 1:axonNum
        boutonNum = size(outData.boutonInt{j},1);
        combinedStruct.exclude = [combinedStruct.exclude; outData.exclude{j}(1:boutonNum,:)];
        combinedStruct.boutonMouse = [combinedStruct.boutonMouse; repmat({mouse},boutonNum,1)];
        combinedStruct.boutonAxon = [combinedStruct.boutonAxon; repmat(j,boutonNum,1)];
        
        absints = reshape(outData.boutonInt{j}(:,1,:),[size(outData.boutonInt{j},1),3]);
        combinedStruct.absboutonInt = [combinedStruct.absboutonInt;absints];
        
        relints = reshape(outData.boutonInt{j}(:,3,:),[size(outData.boutonInt{j},1),3]);
        combinedStruct.normboutonInt = [combinedStruct.normboutonInt; relints];
        
        abswidth = reshape(outData.boutonWidth{j}(:,1,:),[size(outData.boutonWidth{j},1),3]);
        combinedStruct.absboutonWidth = [combinedStruct.absboutonWidth;abswidth];
        
        relwidth = reshape(outData.boutonWidth{j}(:,3,:),[size(outData.boutonWidth{j},1),3]);
        combinedStruct.relboutonWidth = [combinedStruct.relboutonWidth;relwidth];
        
    end
end

exclude = logical(combinedStruct.exclude);
ints = combinedStruct.normboutonInt;
widths = combinedStruct.relboutonWidth;

combinedStruct.boutonPresence = zeros(size(ints));
combinedStruct.boutonPresence(exclude) = nan;
combinedStruct.boutonPresence(ints > 2 & widths>3) = 1;
present = combinedStruct.boutonPresence;

transitionExclude = [any([exclude(:,1:2)],2), any([exclude(:,2:3)],2)];
combinedStruct.boutonPersist = zeros(size(present,1),2);
combinedStruct.boutonPersist(transitionExclude) = nan;
combinedStruct.boutonPersist(present(:,1:2) == 1 & present(:,2:3) == 1) = 1;

combinedStruct.boutonForm = zeros(size(present,1),2);
combinedStruct.boutonForm(transitionExclude) = nan;
combinedStruct.boutonForm(present(:,1:2) == 0 & present(:,2:3) == 1) = 1;

combinedStruct.boutonElim = zeros(size(present,1),2);
combinedStruct.boutonElim(transitionExclude) = nan;
combinedStruct.boutonElim(present(:,1:2) == 1 & present(:,2:3) == 0) = 1;

combinedStruct.boutonsPerSite = {};
combinedStruct.boutonsPerAxon = {};

uniqueMice = unique(combinedStruct.boutonMouse);

n = 0;

for i = 1:size(uniqueMice,1)
    combinedStruct.boutonsPerSite{i,1} = uniqueMice{i};
    mouseIdx = strcmp(combinedStruct.boutonMouse,uniqueMice(i));
    mouseBoutons = combinedStruct.boutonPresence(mouseIdx);
    mouseBoutons = any(mouseBoutons == 1,2);
    mouseBoutons = sum(mouseBoutons);
    combinedStruct.boutonsPerSite{i,2} = mouseBoutons;
    
    mouseAxons = unique(combinedStruct.boutonAxon(mouseIdx));
    for j = 1:size(mouseAxons)
        n = n+1;
        combinedStruct.boutonsPerAxon{n,1} = uniqueMice{i};
        combinedStruct.boutonsPerAxon{n,2} = mouseAxons(j);
        axonIdx = mouseIdx & combinedStruct.boutonAxon == mouseAxons(j);
        axonBoutons = combinedStruct.boutonPresence(axonIdx);
        axonBoutons = any(axonBoutons == 1,2);
        axonBoutons = sum(axonBoutons);
        combinedStruct.boutonsPerAxon{n,3} = axonBoutons;
    end
end

    


cd(saveFolder)
t = datetime('now','TimeZone','local');
ts = datestr(t,'yymmdd_hhMMss',2000);
save(['combinedsave_' ts '.mat'],'combinedStruct','-v7.3')


