function fullSave2(hfig)
    sourceFolder = cd('results');
    resultsFolder = cd('resultsTiffs');
    
    hfig = completionCheck(hfig);
    hfig = boutonSummaryCalc(hfig);
    stackAxonSummary(hfig);
    perAxonSummary(hfig);
    perBoutonSummary(hfig);
    outData = unshuffleOutput(hfig); %#ok<NASGU>
    figData = guidata(hfig);
    
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

function hfig = completionCheck(hfig)
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
            
            kmax = max([size(cbc,1),size(cbs,1)]);
            cbcdiff = diff([size(cbc,1);kmax]);
            if cbcdiff > 0
                cbc = [cbc;nan(cbcdiff,size(cbc,2))];
                figData.boutonCenter{i}{j} = cbc;
            end
            
            cbsdiff = diff([size(cbs,1);kmax]);
            if cbsdiff>0
                cbs = [cbs;nan(cbsdiff,size(cbs,2))];
                figData.boutonStatus{i}{j} = cbs;
            end
            
            for k = 1:kmax
                complete = ~any([k>size(cbc,1), any(isnan(cbc(k,:))), k>size(cbs,1), any(isnan(cbs(k,:))), isempty(cbcr{k})]);
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
    
    for i = 1:figData.numStacks
        for j = 1:25
            cbc = figData.boutonCenter{i}{j};
            
            cbcdiff = diff([size(cbc,1);figData.maxBouton(j)]);
            if cbcdiff>0
                cbc = [cbc;nan(cbcdiff,size(cbc,2))];
                figData.boutonCenter{i}{j} = cbc;
            end
            
            cbs = figData.boutonStatus{i}{j};
            
            cbsdiff = diff([size(cbs,1);figData.maxBouton(j)]);
            if cbsdiff>0
                cbs = [cbs;nan(cbsdiff,size(cbs,2))];
                figData.boutonStatus{i}{j} = cbs;
            end
        end
    end

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

function hfig = boutonSummaryCalc(hfig)
    figData = guidata(hfig);
    
    for j = 1:figData.maxAxon
        for k = 1:figData.maxBouton(j)
            for i = 1:figData.numStacks
                exclude = find(figData.boutonStatus{i}{j}(k,:)) == 3;
                nanbouton = any(isnan(figData.boutonStatus{i}{j}(k,:)));
                nocross = isempty(figData.boutonCross{i}{j}{k});
                if any([exclude, nanbouton, nocross])
                    %wipe all data for excluded boutons
                    excludeBouton(hfig,i,j,k)
                else
                    %bouton cross summary calculations
                    cbcs = figData.boutonCross{i}{j}{k};
                    cbc = figData.boutonCenter{i}{j};
                    
                    [cbw,cbc(k,:),cbcp,cbcseg] = segmentWidth(cbcs(1:2,:),hfig,.75,0,i,j);
                    figData.boutonWidth{i}{j}{k} = cbw;
                    figData.boutonCrossProfile{i}{j}{k} = cbcp;
                    figData.boutonCrossSegment{i}{j}{k} = cbcseg;

                    figData.boutonCenter{i}{j} = cbc;

                    %local axon cross summary calculations
                    cacs = figData.axonCross{i}{j}{k};

                    law = [];
                    lac = [];
                    lacp = {};
                    lacseg = [];
                    
                    
                    guidata(hfig,figData);

                    for m = 1:floor(size(cacs,1)/2)
                        [lawi,laci,lacpi,lacsegi] = segmentWidth(cacs(2*m-1:2*m,:),hfig,.75,0,i,j);
                        law = [law;lawi]; %#ok<*AGROW>
                        lac = [lac;laci];
                        lacp{end+1} = lacpi;
                        lacseg = [lacseg;lacsegi];
                    end

                    figData.localAxonWidth{i}{j}{k} = law;
                    figData.localAxonCenter{i}{j}{k} = lac;
                    figData.localAxonCrossProfile{i}{j}{k} = lacp;
                    figData.localAxonCrossSegment{i}{j}{k} = lacseg;
                end
            end
        end
    end
    
    guidata(hfig,figData);
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
                    line(cats(:,1), cats(:,2),'Color','c','Linestyle','-','linewidth',1);
                    text(mean(cats(:,1)),mean(cats(:,2)) + 15, num2str(j),'Color','c');
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
                    line(cats(:,1), cats(:,2),'Color','c','Linestyle','-','linewidth',1);
                    text(mean(cats(:,1)),mean(cats(:,2)) + 15, num2str(j),'Color','c');
                    
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
            boutonSummary = figure; 
            for i = 1:figData.numStacks
                %Abbreviated version
                cbc = figData.boutonCenter{i}{j};
                cbcr = figData.boutonCross{i}{j}{k};
                cbcp = nan(size(cbc));

                if ~any(isnan(cbc(k,:)))

                    cbcseg = figData.boutonCrossSegment{i}{j}{k};
                    lacseg = figData.localAxonCrossSegment{i}{j}{k};

                    %shift bouton center to local peak
                    backbone = figData.axonTraceSnapSkipped{i}{j};
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        cbcp(k,:) = cbc(k,:);
                        disp([i,j,k]);
                        [maxtab,~] = peakdet(backbone(:,4),backbone(cbc(k,4),4)/10);
                        [~,indx] = min(abs(maxtab(:,1)-cbc(k,4)));
                        if abs(maxtab(indx,1)-cbc(k,4)) < 5
                            cbcp(k,:) = [backbone(maxtab(indx,1),1:3),maxtab(indx,1)];
                        end
                        axonIndx = cbcp(k,4);
                        figData.boutonBrightness{i}{j}(k,1) = figData.axonBrightnessProfile{i}{j}(axonIndx,4);
                        figData.boutonBrightness{i}{j}(k,2) = figData.axonBrightnessProfileBaseline{i}{j}(axonIndx,4);
                        figData.boutonBrightness{i}{j}(k,3) = figData.axonTraceSnapSkipped{i}{j}(axonIndx,4);
                        plotCenter = cbcp(k,:);
                    else
                        plotCenter = cbc(k,:);
                    end
                    
                    boutonImage = figData.stackDataShuffled{i}(:,:,plotCenter(3));
                    
                    
                    %create a 40x40 roi centered around that bouton
                    ymin = round(plotCenter(2))-50;
                    ymin(ymin<1)=1;
                    xmin = round(plotCenter(1))-50;
                    xmin(xmin<1)=1;
                    ymax = round(plotCenter(2))+50;
                    ymax(ymax>figData.dims{i}(2)) = figData.dims{i}(2);
                    xmax = round(plotCenter(1))+50;
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
                    
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                        hold on
                        
                        backbone = figData.axonTraceSnapSkipped{i}{j};
                        backbone = backbone(backbone(:,2) > ymin & backbone(:,2) < ymax,:);
                        backbone = backbone(backbone(:,1) > xmin & backbone(:,1) < xmax,:);

                        backbone1 = backbone;
                        backbone1(isnan(backbone1(:,4)),:) = nan;
                        line(backbone1(:,1)-xmin+1,backbone1(:,2)-ymin+1,'Color','c');

                        backbone2 = backbone;
                        backbone2(~isnan(backbone2(:,4)),:) = nan;
                        line(backbone(:,1)-xmin+1, backbone2(:,2)-ymin+1,'Color','r');
                        
                        line(cbcseg(:,1)-xmin+1,cbcseg(:,2)+1-ymin,'Color','g','LineWidth',2);
                        for m = 1:floor(size(lacseg,1)/2)
                            line(lacseg(m*2-1:m*2,1)-xmin+1,lacseg(m*2-1:m*2,2)+1-ymin,'Color','c','LineWidth',2);
                        end
                        
                        scatter(cbcp(k,1)-xmin+1,cbcp(k,2)-ymin+1);
                        
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
                        plot([-10,10],[.75,.75],'--');
                        axis([-10 10, 0 20])
                        
                        realWidths = figData.localAxonWidth{i}{j}{k};
                        realWidths = realWidths(realWidths>1);
                        
                        widthDiff = figData.boutonWidth{i}{j}{k} - mean(realWidths);
                        if widthDiff < 1
                            printDiff = '<1';
                        else
                            printDiff = num2str(round(widthDiff,2));
                        end
                        
                        if figData.boutonWidth{i}{j}{k} < 1
                            printBout = '<1';
                        else
                            printBout = num2str(round(figData.boutonWidth{i}{j}{k},2));
                        end
                        
                        
                        title(['Bouton: ' printBout ' Axon: ' num2str(round(mean(realWidths),2)) ' Diff: ' printDiff]);
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end

                    %plot bouton and axon longitudinal int with thresholds
                    subplot(figData.numStacks,5,5*pos-1)
                    hold on
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        backbone = figData.axonTraceSnapSkipped{i}{j};
                        xrange = cbcp(k,4)-20:cbcp(k,4)+20;
                        xrange(xrange<1) = [];
                        xrange(xrange>size(backbone,1)) = [];
                        plot(xrange,backbone(xrange',4)); 
                        axis([cbcp(k,4)-20 cbcp(k,4)+20 0 25]);
                        peakToInt = backbone(cbcp(k,4),4);
                        scatter(cbcp(k,4),peakToInt);
                        title(['bouton peak : med int = ' num2str(round(peakToInt,2))]);
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end   
                        
                    %plot brightness boosted bouton, rotated
                    subplot(figData.numStacks,5,5*pos)
                    if find(figData.boutonStatus{i}{j}(k,:)) ~= 3
                        boutonImageROIRot = rotateBouton(cbcr(1:2,:),cbcp(k,1:2),hfig,i);
                        image(imadjust(boutonImageROIRot,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                        hold on
                        formatImage
                        title('rotated');
                    else
                        text(.4,.5,'EXCLUDED')
                        set(gca,'Visible','off')
                    end

                end
            end
            figData.boutonCenterPeakCorrected{i}{j} = cbcp;    
            set(boutonSummary, 'Position', get(0, 'Screensize'));
            print(boutonSummary,'-dpng',[filename 'A' num2str(j) 'B' num2str(k)], '-noui');
            close(boutonSummary)

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


