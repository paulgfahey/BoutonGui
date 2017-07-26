function fullSave2(hfig)
    figData = guidata(hfig);
    sourceFolder = cd('results');
    resultsFolder = cd('resultsTiffs');
    
    completionCheck(hfig);
    boutonSummaryCalc(hfig);
    stackAxonSummary(hfig);
    perAxonSummary(hfig);
    perBoutonSummary(hfig);
%     outData = unshuffleOutput(hfig); %#ok<NASGU>
    
    cd(resultsFolder)  
%     filename = strrep(figData.mouseFileName,'.mat','');
%     t = datetime('now','TimeZone','local');
%     ts = datestr(t,'yymmdd_hhMMss',2000);
%     save(['boutonfinalsave_' filename '_' ts '.mat'],'figData','outData','-v7.3');
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
                complete = ~any([any(isnan(cbc(k,:))), k>size(cbs,1), any(isnan(cbs(k,:))), isempty(cbcr{k})]);
                incomplete = ~complete & any([~any(isnan(cbc(k,:))), ~k>size(cbs,1), ~any(isnan(cbs(k,:))), ~isempty(cbcr{k})]);
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
            findMaxPartial = find(figData.boutonPartialCount(j,:,i),1,'last');
            findMaxComplete = find(figData.boutonCount(j,:,i),1,'last');
            findMax = max([findMaxPartial,findMaxComplete]);
            if ~isempty(findMax)
                figData.maxBouton(i,j) = findMax;
            end
        end
    end
    figData.maxBouton = max(figData.maxBouton,[],1);  %finds the maximum number of boutons for each axon
    
    x = 1;
    for j = 1:figData.maxAxon
        for i = 1:figData.numStacks
            stack{x} = num2str(i); 
            if figData.axonCount(i,j)
                axon{x} = num2str(j); 
            else
                axon{x} = num2str(0); 
            end
            bouton{x} = strrep(strcat(num2str(figData.boutonCount(j,1:figData.maxBouton(j),i))),' ',''); 
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
            
            catss = figData.axonTraceSnapSkipped{i};
            for j = 1:size(catss,2)
                if ~isempty(catss{j})
                    %plot unskipped regions
                    cats = catss{j};
                    cats(isnan(cats(:,4)),:) = nan;
                    line(cats{j}(:,1), cats{j}(:,2),'Color','c','Linestyle','-','linewidth',1);
                    text(mean(cats{j}(:,1)),mean(cats{j}(:,2)) + 15, num2str(j),'Color','c');
                    %plot skipped regions
                    csat = catss{j};
                    csat(~isnan(csat(:,4)),:) = nan;
                    line(csat(:,1),csat(:,2),'Color','r','LineStyle','-','linewidth',1);
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
            catss = figData.axonTraceSnapSkipped{i};
            for j = 1:figData.maxAxon
                if ~isempty(catss{j})   %for each axon
                    perAxonSummary = figure;
                    image(mean(figData.stackDataShuffled{i},3))
                    hold on    
                    %plot unskipped regions
                    cats = catss{j};
                    cats(isnan(cats(:,4)),:) = nan;
                    line(cats{j}(:,1), cats{j}(:,2),'Color','c','Linestyle','-','linewidth',1);
                    text(mean(cats{j}(:,1)),mean(cats{j}(:,2)) + 15, num2str(j),'Color','c');
                    
                    %plot skipped regions
                    csat = catss{j};
                    csat(~isnan(csat(:,4)),:) = nan;
                    line(csat(:,1),csat(:,2),'Color','r','LineStyle','-','linewidth',1);
                    
                    %plot boutons
                    cbc = figData.boutonCenter{i}{j};
                    if ~isempty(cbc)  
                        scatter(cbc(:,1),cbc(:,2),'r');
                        for k = 1:size(cbc,1)  %for each bouton center on that axon
                            figData.boutonNums = text(cbc(k,1)+15,cbc(k,2),num2str(k),'Color','red');
                        end
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
                    cbcr = figData.boutonCross{i}{j}{k};
                    
                    cbcseg = figData.boutonCrossSegment{i}{j}{k};
                    lacseg = figData.localAxonCrossSegment{i}{j}{k};
                    
                    %Create filtered versions of raw image at appropriate z plane
                    boutonImage = figData.stackDataShuffled{i}(:,:,cbc(k,3));
                    
                    %create a 40x40 roi centered around that bouton
                    ymin = round(cbc(k,2))-20;
                    ymin(ymin<1)=1;
                    xmin = round(cbc(k,1))-20;
                    xmin(xmin<1)=1;
                    ymax = round(cbc(k,2))+20;
                    ymax(ymax>figData.dims{i}(2)) = figData.dims{i}(2);
                    xmax = round(cbc(k,1))+20;
                    xmax(xmax>figData.dims{i}(1)) = figData.dims{i}(1);
                    
                    %plot brightness boosted bouton, unrotated
                    pos = figData.stackKey(i); %image plotting order is unshuffled
                    subplot(figData.numStacks,5,5*pos-4)
                    boutonImageROI = boutonImage(ymin:ymax,xmin:xmax);
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    statStrAbbr = {'Alpha','Beta','Exclude','Absent'};
                    title(['Status: ' statStrAbbr(figData.boutonStatus{i}{j}(k,:)>0)]);
                    ylabel(strrep(figData.stackfileNameShuffled{i},'.mat',''));
                    formatImage
                    
                    
                    %plot brightness boosted bouton, unrotated with trace overlays
                    subplot(figData.numStacks,5,5*pos-3)
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    hold on
                    
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        backbone = figData.axonTraceSnapSkipped{i}{j};
                        backbone = backbone(backbone(:,2) > ymin & backbone(:,2) < ymax,:);
                        backbone = backbone(backbone(:,1) > xmin & backbone(:,1) < xmax,:);

                        backbone1 = backbone;
                        backbone1(isnan(backbone1(:,4)),:) = nan;
                        line(backbone1(:,1)-xmin+1,backbone1(:,2)-ymin+1,'Color','b');

                        backbone2 = backbone;
                        backbone2(~isnan(backbone2(:,4)),:) = nan;
                        line(backbone(:,1)-xmin+1, backbone2(:,2)-ymin+1,'Color','r');
                        
                        line(cbcseg(:,1)-xmin+1,cbcseg(:,2)+1-ymin,'Color','g');
                        for m = 1:floor(size(lacseg,1)/2)
                            line(lacseg(m*2-1:m*2,1)-xmin+1,lacseg(m*2-1:m*2,2)+1-ymin,'Color','g');
                        end
                        title('clicked overlays')
                        axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end
                    
                    formatImage
                    
                    %plot bouton and axon cross int with thresholds
                    subplot(figData.numStacks,5,5*pos-2)
                    hold on
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        [boutonProfile,axonProfile] = boutonWidthPlotting(i,j,k,hfig);
                        plot(boutonProfile(:,1),boutonProfile(:,2));
                        for m = 1:size(axonProfile,2)
                            plot(axonProfile{m}(:,1),axonProfile{m}(:,2));
                        end
                        plot([-10,10],[.5,.5],'--');
                        axis([-10 10, 0 8])
                        widthRatio = round(figData.boutonWidth{i}{j}{k}/mean(figData.localAxonWidth{i}{j}{k}),2);
                        title(['bouton:axon width = ' num2str(widthRatio)]);
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end
                    
                    %plot bouton and axon longitudinal int with thresholds
                    subplot(figData.numStacks,5,5*pos-1)
                    backbone = figData.axonTraceSnapSkipped{i}{j};
                    backbone = backbone(backbone(:,2) > ymin & backbone(:,2) < ymax,:);
                    backbone = backbone(backbone(:,1) > xmin & backbone(:,1) < xmax,:);
                    hold on
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        plot(backbone(:,4))
                        axis([0,size(backbone,1),.75,20]);
                        peakToInt = max(backbone(:,4));
                        title(['bouton peak : med int = ' num2str(round(peakToInt,2))]);
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end
                    
                    %plot brightness boosted bouton, rotated
                    subplot(figData.numStacks,5,5*pos)
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        boutonImageROIRot = rotateBouton(cbcr(1:2,:),cbc(k,1:2),hfig,i);
                        image(imadjust(boutonImageROIRot,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                        hold on
                        formatImage
                        title('rotated');
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end
                end
                
                set(boutonSummary, 'Position', get(0, 'Screensize'));
                print(boutonSummary,'-dpng',[filename 'A' num2str(j) 'B' num2str(k)], '-noui');
                close(boutonSummary)
            end
        end
    end
    guidata(hfig,figData)
end

function [boutonProfile, axonProfile] = boutonWidthPlotting(cs,ca,cb,hfig)
    figData = guidata(hfig);

    backbone = figData.axonBrightnessProfile{cs}{ca}(:,1:2);
    boutonIndx = find(ismember(backbone(:,1:2),figData.boutonCenter{cs}{ca}(cb,1:2),'rows'),1,'first');
    
    boutonProfileInt = figData.boutonCrossProfile{cs}{ca}{cb};
    weight = figData.axonBrightnessProfileBaseline{cs}{ca}(boutonIndx,4); 
    boutonProfileInt = (boutonProfileInt / weight);
    [~,ind] = max(boutonProfileInt);
    boutonProfileInd = (1:size(boutonProfileInt,1)) - ind;
    boutonProfile = nan(size(boutonProfileInt,1),2);
    boutonProfile(:,2) = boutonProfileInt;
    boutonProfile(:,1) = boutonProfileInd;
    
    axonProfile = {};
    for m = 1:size(figData.localAxonCrossProfile{cs}{ca}{cb},2)
        axonIndx = find(ismember(backbone(:,1:2),figData.localAxonCenter{cs}{ca}{cb}(m,1:2),'rows'),1,'first');
        axonProfileInt = figData.localAxonCrossProfile{cs}{ca}{cb}{m};
        weight = figData.axonBrightnessProfileBaseline{cs}{ca}(axonIndx,4); 
        axonProfileInt = (axonProfileInt /weight);
        [~,ind] = max(axonProfileInt);
        axonProfileInd = (1:size(axonProfileInt,1)) - ind;
        axonProfile{m} = nan(size(axonProfileInt,1),2); %#ok<*AGROW>
        axonProfile{m}(:,2) = axonProfileInt;
        axonProfile{m}(:,1) = axonProfileInd;
    end
end

function outData = unshuffleOutput(hfig)
    figData = guidata(hfig);

    outData.axonLengths = nan(figData.maxAxon,figData.numStacks);

    for j = 1:figData.maxAxon
        outData.boutonPresence{j} = nan(figData.maxBouton(j),figData.numStacks);
        outData.exclude{j} = nan(figData.maxBouton(j),figData.numStacks);
        outData.boutonInt{j} = nan(figData.maxBouton(j),3,figData.numStacks);
        outData.boutonWidth{j} = nan(figData.maxBouton(j),3,figData.numStacks);

        for m = 1:figData.numStacks
            i = figData.stackKey(m);

            outData.axonLengths(j,i) = figData.axonIncludedTraceLength{cs}{ca};
            
            outData.boutonPresence{j}(1:size(figData.boutonStatus{m}{j},1),i) = any(figData.boutonStatus{m}{j}(:,1:2),2);
            outData.exclude{j}(:,i) = figData.boutonStatus{m}{j}(:,3);
            

            for k = 1:figData.maxBouton(j)
                if outData.exclude{j}(k,i) == 0 && all(figData.boutonCount(j,k,:))
                outData.boutonInt{j}(k,1,i) = figData.boutonPeakInt{m}{j}{k};
                outData.boutonInt{j}(k,2,i) = figData.axonBrightnessProfileBaseline{m}{j};
                outData.boutonInt{j}(k,3,i) = outData.boutonInt{j}(k,1,i) / outData.boutonInt{j}(k,2,i);

                outData.boutonWidth{j}(k,1,i) = figData.boutonWidth{m}{j}{k};
                outData.boutonWidth{j}(k,2,i) = mean(figData.localAxonWidth{m}{j}{k});
                outData.boutonWidth{j}(k,3,i) = outData.boutonWidth{j}(k,1,i) / outData.boutonWidth{j}(k,2,i);
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

function boutonSummaryCalc(hfig)
    figData = guidata(hfig);
    
    for j = 1:figData.maxAxon
        for k = 1:figData.maxBouton(j)
            if all(figData.boutonCount(j,k,:))
                for i = 1:figData.numStacks
                    
                    %bouton cross summary calculations
                    cbc = figData.boutonCenter{i}{j};
                    cbcs = figData.boutonCross{i}{j}{k};

                    [cbw,cbc(cb,:),cbcp,cbcseg] = segmentWidth(cbcs(1:2,:),hfig,.75,0);
                    figData.boutonWidth{i}{j}{k} = cbw;
                    figData.boutonCrossProfile{i}{j}{k} = cbcp;
                    figData.boutonCrossSegment{i}{j}{k} = cbcseg;
                    
                    
                    %local axon cross summary calculations
                    cacs = figData.axonCross{i}{j}{k};
                    
                    law = [];
                    lac = [];
                    lacp = {};
                    lacseg = [];
                    
                    for m = 1:floor(size(cacs,1)/2)
                        [lawi,laci,lacpi,lacsegi] = segmentWidth(cacs(2*m-1:2*m,:),hfig,.5,0);
                        law = [law;lawi]; %#ok<*AGROW>
                        lac = [lac;laci];
                        lacp{end+1} = lacpi;
                        lacseg = [lacseg;lacsegi];
                    end
                    
                    figData.localAxonWidth{cs}{ca}{cb} = law;
                    figData.localAxonCenter{cs}{ca}{cb} = lac;
                    figData.localAxonCrossProfile{cs}{ca}{cb} = lacp;
                    figData.localAxonCrossSegment{cs}{ca}{cb} = lacseg;
                    
                end
            end
        end
    end
    
    figData.boutonCenter{i}{j} = cbc;
    guidata(hfig,figData);
end


