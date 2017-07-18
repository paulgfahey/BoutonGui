function fullSave(hfig)
    figData = guidata(hfig);
    sourceFolder = cd('results');
    resultsFolder = cd('resultsTiffs');
    
    completionCheck(hfig);
    stackAxonSummary(hfig);
    perAxonSummary(hfig);
    perBoutonSummary(hfig);
    outData = unshuffleOutput(hfig);
    
    cd(resultsFolder)  
    filename = strrep(figData.mouseFileName,'.mat','');
    t = datetime('now','TimeZone','local');
    ts = datestr(t,'yymmdd_hhMMss',2000);
    save(['boutonfinalsave_' filename '_' ts '.mat'],'figData','outData','-v7.3');
    cd(sourceFolder)
    guidata(hfig, figData)
end

function formatImage
axis square;
set(gca,'xtick',[],'ytick',[]);
set(gca, 'Ydir','reverse');
colormap('bone');
end

function completionCheck(hfig)
    figData = guidata(hfig);
    figData.axonCount = zeros(figData.numStacks,25);
    figData.boutonCount = zeros(25,100);
    figData.boutonPartialCount = zeros(25,100,figData.numStacks);
   for i = 1:figData.numStacks
        for j = 1:25
            figData.axonCount(i,j) = ~isempty(figData.axonTrace{i}{j});  %creates i x j table of axon trace presence
            cbc = figData.boutonCenter{i}{j};
            cbs = figData.boutonStatus{i}{j};
            cbcr = figData.boutonCross{i}{j};
            for k = 1:size(cbc,1)
                complete = ~any([isempty(cbc(k)), isempty(cbs(k)), isempty(cbcr{k})]);
                incomplete = any([~isempty(cbc(k)), ~isempty(cbs(k)), ~isempty(cbcr{k})]);
                figData.boutonCount(j,k,i) = complete;  %creates j x k x i table of bouton analysis completion
                figData.boutonPartialCount(j,k,i) = incomplete;
            end
        end
    end
    [~,b] = find(figData.axonCount);
    figData.maxAxon = max(b);  %finds how many axons are in the stack with the most axons
    
    figData.maxBouton = zeros(figData.numStacks,25);
    for i = 1:figData.numStacks
        for j = 1:25
            findmax = find(figData.boutonPartialCount(j,:,i),1,'last');
            if ~isempty(findmax)
                figData.maxBouton(i,j) = findmax;
            end
        end
    end
    figData.maxBouton = max(figData.maxBouton,[],1);  %finds the maximum number of boutons for each axon
    
    x = 1;
    for j = 1:figData.maxAxon
        for i = 1:figData.numStacks
            stack{x} = num2str(i); %#ok<AGROW>
            if figData.axonCount(i,j)
                axon{x} = num2str(j);
            else
                axon{x} = num2str(0);
            end
            bouton{x} = strrep(strcat(num2str(figData.boutonCount(j,1:figData.maxBouton(j),i))),' ',''); %#ok<AGROW>
            x = x+1;
        end
    end
    
    stack = stack';
    axon = axon';
    bouton = bouton';
    T = table(stack, axon, bouton); %#ok<NASGU>
    %creates table of 0/1 for each axon/bouton having a complete set
    %analysis components 
    
    completionSummary = figure;
    TString = evalc('disp(T)');
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    FixedWidth = get(0,'FixedWidthFontName');
    annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
    filename = strrep(figData.mouseFileName,'.mat','');
    print(completionSummary,'-dpng',[filename 'completion'],'-noui')
    close(completionSummary)
    guidata(hfig,figData)
end

function stackAxonSummary(hfig)
    figData = guidata(hfig);
    for i = 1:figData.numStacks
        if ~isempty(figData.stackfileNameShuffled{i})
            filename = strrep(figData.stackfileNameShuffled{i},'.mat','');

            %SAVE A SUMMARY IMAGE OF ALL AXONS TRACED FOR EACH STACK
            axonSummary = figure;
            image(mean(figData.stackDataShuffled{i},3))
            hold on
            
            cats = figData.axonTraceSnap{i};   %all axon traces for the current stack
            for j = 1:size(cats,2)    %for each axon trace
                if ~isempty(cats{j})
                    line(cats{j}(:,1), cats{j}(:,2),'Color','c','Linestyle','-','linewidth',1);
                    text(mean(cats{j}(:,1)),mean(cats{j}(:,2)) + 15, num2str(j),'Color','c');
                end
            end
            
            csats = figData.axonSkipTraceSnap{i}; %all skip axon traces for the current stack
            for j = 1:size(csats,2)
                if ~isempty(csats{j})
                    for k = 1:size(csats{j},2)
                        if ~isempty(csats{j}{k})
                            line(csats{j}{k}(:,1),csats{j}{k}(:,2),'Color','r','Linestyle','-','linewidth',1);
                        end
                    end
                end
            end
            
            formatImage
            print(axonSummary,'-dpng',[filename 'axons'],'-noui')
            close(axonSummary)
        end
    end
    guidata(hfig,figData)
end

function perAxonSummary(hfig)
    figData = guidata(hfig);
    for i = 1:figData.numStacks
        if ~isempty(figData.stackfileNameShuffled{i})
            filename = strrep(figData.stackfileNameShuffled{i},'.mat','');
            %SAVE A SUMMARY FIGURE FOR EACH AXON, WITH BOUTON CENTERS
            %LABELED
            cats = figData.axonTraceSnap{i};
            csats = figData.axonSkipTraceSnap{i};
            for j = 1:figData.maxAxon
                if ~isempty(cats{j})   %for each axon
                    perAxonSummary = figure;
                    image(mean(figData.stackDataShuffled{i},3))
                    hold on                    
                    line(cats{j}(:,1), cats{j}(:,2),'Color','c','Linestyle','-','linewidth',1);
                    text(round(mean(cats{j}(:,1))),round(mean(cats{j}(:,2)+15)), num2str(j),'Color','c');
                    figData.rawAxonLengths{i}{j} = sum(sqrt(sum(diff(cats{j}).^2,2)));
             
                    cbc = figData.boutonCenter{i}{j};
                    if ~isempty(cbc)  
                        scatter(cbc(:,1),cbc(:,2),'r');
                        for k = 1:size(cbc,1)  %for each bouton center on that axon
                            figData.boutonNums = text(cbc(k,1)+15,cbc(k,2),num2str(k),'Color','red');
                        end
                    end
                    
                    if ~isempty(csats{j})
                        figData.skipAxonLength{i}{j} = 0;
                        for k = 1:size(csats{j},2)
                            if ~isempty(csats{j}{k})
                                line(csats{j}{k}(:,1), csats{j}{k}(:,2),'Color','r','Linestyle','-','linewidth',1);
                                figData.skipAxonLength{i}{j} = figData.skipAxonLength{i}{j} + sum(sqrt(sum(diff(csats{j}{k}(:,1:2).^2,2))));
                            end
                        end
                    end
                    
                    if ~isempty(figData.axonSkipTraceLength{i}{j})
                        figData.axonLengths{i}{j} = figData.rawAxonLengths{i}{j} - figData.axonSkipTraceLength{i}{j};
                    else
                        figData.axonLengths{i}{j} = figData.rawAxonLengths{i}{j};
                    end
                      
                    formatImage
                    print(perAxonSummary,'-dpng',[filename 'A' num2str(j)],'-noui');
                    close(perAxonSummary)
                end
            end
        end
    end
    guidata(hfig,figData)
end

function perBoutonSummary(hfig)
    figData = guidata(hfig);
    %SAVE A SUMMARY FIGURE FOR EACH BOUTON WITH ALL ELEMENTS PERFORMED
    filename = strrep(figData.mouseFileName,'.mat','');
    for j = 1:figData.maxAxon
        for k = 1:figData.maxBouton(j)
            if all(figData.boutonCount(j,k,:))
                boutonSummary = figure; 
                for i = 1:figData.numStacks
                    %Abbreviated version
                    cbc = figData.boutonCenter{i}{j};
                    cbbo = figData.boutonBoundary{i}{j};
                    cbbm = figData.boutonMask{i}{j};
                    cbcr = figData.boutonCross{i}{j};
                    cats = figData.axonTraceSnap{i}{j};
                    cbam = figData.axonMask{i}{j};
                    
                    

                    %Create filtered versions of raw image at boundary z plane
                    boutonImage = figData.stackDataShuffled{i}(:,:,cbc(k,3));
                    boutonMaskImage = boutonImage.*uint8(cbbm{k});
                    boutonAntiMaskImage = boutonImage.*uint8(~cbbm{k});
                    axonMaskImage = boutonImage.*uint8(cbam{k});

                    %Intensity and Pixel coordinates for line tracing intensity
                    %along longitudinal axis of bouton, nan for outside mask
                    [intx, inty, int] = improfile(boutonMaskImage, cats(:,1), cats(:,2), figData.axonTraceSnapLength{i}{j});
                    figData.boutonBackboneBoutonOnly{i}{j}{k} = [int, intx, inty];
                    figData.boutonBackboneBoutonOnly{i}{j}{k}(int==0,:) = nan;


                    %Intensity and Pixel coordinates for line tracing intensity
                    %along axon backbone outside bouton, nan for inside bouton
                    [intx, inty, int] = improfile(boutonAntiMaskImage, cats(:,1), cats(:,2), figData.axonTraceSnapLength{i}{j});
                    figData.boutonBackboneOnly{i}{j}{k} = [int, intx, inty];
                    figData.boutonBackboneOnly{i}{j}{k}(int==0,:) = nan;

                    %Intensity and Pixel coordinates for line tracing across
                    %bouton perpendicular axis
                    [intx, inty, int] = improfile(boutonMaskImage, cbcr{k}(3:4,1), cbcr{k}(3:4,2), 100);
                    figData.boutonCrossOnly{i}{j}{k} = [int, intx, inty];
                    figData.boutonCrossOnly{i}{j}{k}(int==0,:) = [];
                    idx = figData.boutonCrossOnly{i}{j}{k};
                    [~, minId] = min(idx(:,2));
                    [~, maxId] = max(idx(:,2));
                    figData.boutonCrossOnlySegment{i}{j}{k} = [idx(minId,2:3);idx(maxId,2:3)];
                    figData.boutonCrossOnlyLength{i}{j}{k} = sqrt(sum(diff(figData.boutonCrossOnlySegment{i}{j}{k}).^2));

                    %Intensity and Pixel Coordinates for line tracing across
                    %proximal axon perpendicular axon
                    [intx, inty, int] = improfile(axonMaskImage, cbcr{k}(1:2,1), cbcr{k}(1:2,2), 100);
                    figData.axonCrossOnly{i}{j}{k} = [int, intx, inty];
                    figData.axonCrossOnly{i}{j}{k}(int==0,:) = [];
                    idx = figData.axonCrossOnly{i}{j}{k};
                    [~, minId] = min(idx(:,2));
                    [~, maxId] = max(idx(:,2));
                    figData.axonCrossOnlySegment{i}{j}{k} = [idx(minId,2:3);idx(maxId,2:3)];
                    
                    if ~isempty(figData.axonCrossOnlySegment{i}{j}{k})
                        figData.axonCrossOnlyLength{i}{j}{k} = sqrt(sum(diff(figData.axonCrossOnlySegment{i}{j}{k}).^2));
                        figData.boutonAxonWidthRatio{i}{j}{k} = figData.boutonCrossOnlyLength{i}{j}{k} ./ figData.axonCrossOnlyLength{i}{j}{k};
                    end

                    %create an roi centered around that bouton
                    ymin = round(min(cbbo{k}(:,1)))-25;
                    ymin(ymin<0)=0;
                    xmin = round(min(cbbo{k}(:,2)))-25;
                    xmin(xmin<0)=0;
                    ymax = round(max(cbbo{k}(:,1)))+25;
                    xmax = round(max(cbbo{k}(:,2)))+25;

                    pos = figData.stackKey(i); %image plotting order is unshuffled
                    subplot(figData.numStacks,3,3*pos-2)
                    boutonImageROI = boutonImage(ymin:ymax,xmin:xmax);
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    statStrAbbr = {'Alpha','Beta','Exclude','Absent'};
                    title(['Status: ' statStrAbbr(figData.boutonStatus{i}{j}(k,:)>0)]);
                    ylabel(strrep(figData.stackfileNameShuffled{i},'.mat',''));
                    formatImage

                    subplot(figData.numStacks,3,3*pos-1)
                    cbcrs = figData.boutonCrossOnlySegment{i}{j}{k};
                    cacrs = figData.axonCrossOnlySegment{i}{j}{k};
                    hold on
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    plot(cbbo{k}(:,2)-xmin+1, cbbo{k}(:,1)-ymin+1,'r');
                    plot(cats(:,1)-xmin+1, cats(:,2)-ymin+1,'g');
                    plot(cbcrs(:,1)-xmin+1, cbcrs(:,2)-ymin+1, 'm');
                    plot(cacrs(:,1)-xmin+1, cacrs(:,2)-ymin+1, 'm');
                    axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
                    title(['max.width.ratio = ' num2str(round(figData.boutonAxonWidthRatio{i}{j}{k},3))]);
                    formatImage

                    subplot(figData.numStacks,3,3*pos)
                    hold on
                    axonBackboneSegment = figData.boutonBackboneOnly{i}{j}{k}(:,1) - figData.axonBrightnessProfileWeights{i}{j}(:,4);
                    axonBackboneSegment = axonBackboneSegment + figData.axonBrightnessNormBaseline{i}{j};
                    boutonBackboneSegment = figData.boutonBackboneBoutonOnly{i}{j}{k}(:,1) - figData.axonBrightnessProfileWeights{i}{j}(:,4);
                    boutonBackboneSegment = boutonBackboneSegment + figData.axonBrightnessNormBaseline{i}{j};
                    plot(boutonBackboneSegment/figData.axonWeightedBrightnessMedian{i}{j},'r');
                    plot(axonBackboneSegment/figData.axonWeightedBrightnessMedian{i}{j},'k');
                    figData.boutonMaxInt{i}{j}{k} = max(boutonBackboneSegment);
                    title(['mean.int.ratio = ' num2str(round(figData.boutonMaxInt{i}{j}{k} / figData.axonWeightedBrightnessMedian{i}{j},3))]);
                    axisrange = boutonWindowPlotRange(boutonBackboneSegment);
                    axis(axisrange)
                end
                set(boutonSummary, 'Position', get(0, 'Screensize'));
                print(boutonSummary,'-dpng',[filename 'A' num2str(j) 'B' num2str(k)], '-noui');
                close(boutonSummary)
            end
        end
    end
    guidata(hfig,figData)
end

function outData = unshuffleOutput(hfig)
    figData = guidata(hfig);

    outData.axonLengths = nan(figData.maxAxon,figData.numStacks);

    for j = 1:figData.maxAxon
        outData.boutonPresence{j} = nan(figData.maxBouton(j),figData.numStacks);
        outData.exclude{j} = nan(figData.maxBouton(j),figData.numStacks);
        outData.abSwitch{j} = zeros(figData.maxBouton(j),figData.numStacks);
        outData.boutonInt{j} = nan(figData.maxBouton(j),3,figData.numStacks);
        outData.boutonWidth{j} = nan(figData.maxBouton(j),3,figData.numStacks);

        for m = 1:figData.numStacks
            i = figData.stackKey(m);

            outData.axonLengths(j,i) = figData.axonLengths{m}{j};

            outData.boutonPresence{j}(1:size(figData.boutonStatus{m}{j},1),i) = any(figData.boutonStatus{m}{j}(:,1:2),2);
            outData.exclude{j}(:,i) = figData.boutonStatus{m}{j}(:,3);
            outData.abSwitch{j}(:,i) = outData.boutonPresence{j}(:,i)==1 & (figData.boutonStatus{m}{j}(:,1) ~= figData.boutonStatus{m}{j}(:,2));


            for k = 1:figData.maxBouton(j)
                if outData.exclude{j}(k,i) == 0 && all(figData.boutonCount(j,k,:))
                outData.boutonInt{j}(k,1,i) = figData.boutonMaxInt{m}{j}{k};
                outData.boutonInt{j}(k,2,i) = figData.axonWeightedBrightnessMedian{m}{j};
                outData.boutonInt{j}(k,3,i) = outData.boutonInt{j}(k,1,i) / outData.boutonInt{j}(k,2,i);

                outData.boutonWidth{j}(k,1,i) = figData.boutonCrossOnlyLength{m}{j}{k};
                outData.boutonWidth{j}(k,2,i) = figData.axonCrossOnlyLength{m}{j}{k};
                outData.boutonWidth{j}(k,3,i) = figData.boutonAxonWidthRatio{m}{j}{k};
                end
            end
        end

        outData.exclude{j} = any(outData.exclude{j},2);
        outData.boutonPresence{j}(outData.exclude{j},:) = nan;

        outData.boutonPersist{j} = outData.boutonPresence{j}(:,1:2) == 1 & outData.boutonPresence{j}(:,2:3) == 1;
        outData.boutonForm{j} = outData.boutonPresence{j}(:,1:2) == 0 & outData.boutonPresence{j}(:,2:3) == 1;
        outData.boutonElim{j} = outData.boutonPresence{j}(:,1:2) == 1 & outData.boutonPresence{j}(:,2:3) == 0;

    end
    
    guidata(hfig,figData);
end

function [axisrange] = boutonWindowPlotRange(boutonBackboneSegment)
center = round(median(find(~isnan(boutonBackboneSegment(:,1)))));
xmin = center - 15;
xmax = center + 15;
if xmin < 0
    xmin = 0;
end
if xmax > length(boutonBackboneSegment(:,1))
    xmax = length(boutonBackboneSegment(:,1));
end
axisrange = [xmin xmax 0 12];
end