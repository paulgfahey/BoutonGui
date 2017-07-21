function figData = newFigParam(hfig,~)
% INSTANTIATES figData for new figure
    figData = guidata(hfig);
    
    %user enters mouse ID 
    figData.mouseID = input('Mouse Identifier: ','s');

    while isempty(figData.mouseID)
        disp('invalid mouse identifier');
        figData.mouseID = input('Mouse Identifier: ','s');
    end

    
    
    %load up filenames and stack data for each imaging session
    disp('Enter stacks in order of date of imaging');
    stackCheck =  input('Enter Stack Number  [or enter "done"]     ','s');

    while ~strcmp(stackCheck,'done') 
        if isnumeric(str2double(stackCheck)) && ~isempty(stackCheck)
            inputNum = str2double(stackCheck);
            [filename,path] = uigetfile;
            importFile = uiimport(fullfile(path,filename));
            try
                figData.stackfileName{inputNum} = filename;
                figData.stackData{inputNum} = importFile.stackData;
            catch ME
                if strcmp(ME.identifier,'MATLAB:nonExistentField')
                    disp(ME.message)
                    warning('Invalid File.  Selected file must be struct with fields fileName and stackData')
                else
                    disp(ME.message)
                end
                rethrow(ME)
            end
        else
            warning('Invalid Input')
        end
        stackCheck = input('Enter Stack Number  [or enter "done"]     ','s');
    end

    %display stacks as entered so user can check
    disp(figData.stackfileName);

    
    figData.numStacks = size(figData.stackfileName,2);
    figData.stackKey = randperm(figData.numStacks); 
    %figData.stackKey{i} gives the true position of that shuffled data

    for i = 1:figData.numStacks
        figData.stackDataShuffled{i} = figData.stackData{figData.stackKey(i)};
        figData.stackfileNameShuffled{i} = figData.stackfileName{figData.stackKey(i)};
        
        %filtered images used to draw bouton cursor
        for j = 1:size(figData.stackDataShuffled{i},3)
            figData.stackDataShuffledProcessed{i}(:,:,j) = imfilter(figData.stackDataShuffled{i}(:,:,j),gausswin(3)*gausswin(3)');
        end
        
        %size and position variables
        figData.cs = 1;     %current stack
        figData.dims{i} = size(figData.stackDataShuffled{i}(:,:,1));
        figData.depth{i} = size(figData.stackDataShuffled{i},3);
        figData.centers{i} = figData.dims{i}/2;
        figData.zoomFactor{i} = [-50, 50];
        figData.range{i} = [-1 1] .* figData.centers{i};
        figData.overlay = 1;
        
        %for intensity adjustment
        figData.high_in{i} = .25;
        figData.high_out{i} = .25;
        
        %bouton entry matrices
        figData.boutonStatusMatrix = [1 0 0 0];
        figData.boutonClasses = {'Alpha','Beta','Exclude','Absent'};
        figData.boutonString = figData.boutonClasses{logical(figData.boutonStatusMatrix)};
        figData.boutonStatus{i} = cell(1);
        
        %current positioning
        figData.currentZ{i} = 1;
        figData.currAxon{i} = 1;

        %for establishing background intensity
        figData.backgroundInt{i} = {};
        figData.backgroundZ{i} = {};
        figData.backgroundMask{i} = {};
        figData.backgroundBoundary{i} = {};
        figData.backgroundMeanInt{i} = [];
        
        for j = 1:25 %automatically allows spots for 25 axons per stack
            %for axon backbone tracing/snapping
            figData.axonTrace{i}{j}={};
            figData.axonTraceSnap{i}{j} = {};            
            figData.axonTraceSnapLength{i}{j} = [];
            
            %for skipped region tracing/snapping
            figData.axonSkipTrace{i}{j} = [];
            figData.axonSkipTraceSnap{i}{j} = {};
            figData.axonSkipTraceLength{i}{j} = [];
            
            %combination of above
            figData.axonTraceSnapSkipped{i}{j} = {};
            
            %axon intensity profile analysis
            figData.axonBrightnessNormBaseline{i}{j} = {};
            figData.axonBrightnessProfile{i}{j} = {};
            figData.axonBrightnessProfileWeights{i}{j} = {};
            figData.axonBrightnessProfileWeighted{i}{j} = {};
            figData.axonWeightedBrightnessMedian{i}{j} = {};
            figData.axonWeightedBrightnessPeaks{i}{j} = {};
            
            %bouton properties
            figData.currBouton{i}{j} = 1;
            figData.boutonCenter{i}{j} = [];
            figData.boutonStatus{i}{j} = [];
            
            figData.axonRegionCenter{i}{j} = [];
            
            for k = 1:100 % auto allows spots for 100 boutons per axon
                
                
                %bouton perpendicular traces for calculating bouton width
                figData.boutonCross{i}{j}{k} = {};
                figData.boutonWidth{i}{j}{k} = {};
                figData.boutonCrossProfile{i}{j}{k} = {};
                figData.boutonCrossSegment{i}{j}{k} = {};
                
                %axon perpendicular traces for calculating local axon width
                figData.axonCross{i}{j}{k} = {};
                figData.localAxonWidth{i}{j}{k} = {};
                figData.localAxonCenter{i}{j}{k} = {};
                figData.localAxonCrossProfile{i}{j}{k} = {};
                figData.localAxonCrossSegment{i}{j}{k} = {};
                
                figData.boutonPeakInt{i}{j}{k} = {};
            end
        end
    end
end