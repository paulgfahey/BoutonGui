function hfig = boutonQualityControl(hfig)
qcfig = figure;
set(qcfig,'Name','Quality Control','NumberTitle','off')
set(qcfig,'KeyPressFcn',{@keyPress,hfig});
hfig = boutonQCCompletionCheck(hfig);
hfig = boutonSummaryCalc(hfig);
qcfig = shuffleIDs(hfig,qcfig);
qcfigData = guidata(qcfig);
replotQC(qcfig,hfig);
guidata(qcfig,qcfigData);
end


function keyPress(qcfig,events,hfig)
qcfigData = guidata(qcfig);

if strcmp(events.Key,'leftarrow') && qcfigData.index>1
    qcfigData.index = qcfigData.index - 1;
end

if strcmp(events.Key,'rightarrow') && qcfigData.index < size(qcfigData.reviewBoutons,1)
    qcfigData.index = qcfigData.index + 1;
end

if strcmp(events.Key,'space')
    qcfigData.failed(qcfigData.index) = ~qcfigData.failed(qcfigData.index);
end

if strcmp(events.Key,'uparrow')
    [hfig,qcfig] = changeWidth(hfig, qcfig, 1.1);
end

if strcmp(events.Key,'downarrow')
    [hfig,qcfig] = changeWidth(hfig,qcfig,.9);
end

if strcmp(events.Key,'e')
    hfig = commitAndSummary(hfig,qcfig);
    qcfig = shuffleIDs(hfig,qcfig);
    qcfigData = guidata(qcfig);
end

guidata(qcfig,qcfigData)
replotQC(qcfig,hfig)
guidata(qcfig,qcfigData);
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
                    if isempty(figData.boutonThresh{i}{j}{k})
                        figData.boutonThresh{i}{j}{k} = .75;
                    end
                    
                    [cbw,cbc(k,:),cbcp,cbcseg] = segmentWidth(cbcs(1:2,:),hfig,figData.boutonThresh{i}{j}{k},0,i,j);
                    figData.boutonWidth{i}{j}{k} = cbw;
                    figData.boutonCrossProfile{i}{j}{k} = cbcp;
                    figData.boutonCrossSegment{i}{j}{k} = cbcseg;

                    figData.boutonCenter{i}{j} = cbc;
                end
            end
        end
    end
    
    guidata(hfig,figData);
end



function qcfig = shuffleIDs(hfig,qcfig)
    figData = guidata(hfig);
    qcfigData = guidata(qcfig);
    boutonIDs = [];
    incompleteBout = [];
    boutonIDsPassed = [];
    incompletePassed = [];
    
    order = 1;
    
    for i = 1:figData.numStacks
        for j = 1:25
            if ~isempty(figData.boutonCenter{i}{j}) & ~all(isnan(figData.boutonCenter{i}{j}))
                cbc = figData.boutonCenter{i}{j};
                
                for k = 1:size(cbc,1)
                    cbcseg = figData.boutonCrossSegment{i}{j}{k};
                    if ~any(isnan(cbc(k,:))) & ~isempty(cbcseg)
                        boutonIDs(end+1,1:5) = [i j k 1 order];
                    else
                        incompleteBout(end+1,1:5) = [i j k 0 order];
                    end
                    order = order+1;
                end
                prevPassed = figData.boutonPassed{i}{j};
                prevPassed = [i*ones(size(prevPassed,1),1), j*ones(size(prevPassed,1),1), prevPassed];

                if ~isempty(prevPassed)
                    if ~isempty(boutonIDs)
                        passed = ismember(boutonIDs(:,1:3),prevPassed,'rows');
                        boutonIDsPassed = [boutonIDsPassed;boutonIDs(find(passed),:)];
                        boutonIDs(find(passed),:) = [];
                    end
                    
                    if ~isempty(incompleteBout)
                        passed = ismember(incompleteBout(:,1:3),prevPassed,'rows');
                        incompletePassed = [incompletePassed;incompleteBout(find(passed),:)];
                        incompleteBout(find(passed),:) = [];
                    end
                end
            end
        end
    end
    
    qcfigData.boutonIDs = boutonIDs;
    qcfigData.incompleteBout = incompleteBout;
    
    boutonIDs = boutonIDs(randperm(size(boutonIDs,1)),:);
    incompleteBout = incompleteBout(randperm(size(incompleteBout,1)),:);
    reviewBoutons = [boutonIDs;incompleteBout; boutonIDsPassed;incompletePassed];
    qcfigData.reviewBoutons = reviewBoutons;
    
    qcfigData.failed = [ones(size([boutonIDs;incompleteBout],1),1); zeros(size([boutonIDsPassed; incompletePassed],1),1)];
    
    
    qcfigData.index = 1;
    
    guidata(qcfig,qcfigData);
end

function [hfig,qcfig] = changeWidth(hfig,qcfig,direction)
    figData = guidata(hfig);
    qcfigData = guidata(qcfig);
    
    
    i = qcfigData.reviewBoutons(qcfigData.index,1);
    j = qcfigData.reviewBoutons(qcfigData.index,2);
    k = qcfigData.reviewBoutons(qcfigData.index,3);
    
    figData.boutonThresh{i}{j}{k} = figData.boutonThresh{i}{j}{k} * direction;
    
    exclude = find(figData.boutonStatus{i}{j}(k,:)) == 3;
    nanbouton = any(isnan(figData.boutonStatus{i}{j}(k,:)));
    nocross = isempty(figData.boutonCross{i}{j}{k});
    if ~any([exclude, nanbouton, nocross])
        %bouton cross summary calculations
        cbcs = figData.boutonCross{i}{j}{k};
        cbc = figData.boutonCenter{i}{j};

        [cbw,cbc(k,:),cbcp,cbcseg] = segmentWidth(cbcs(1:2,:),hfig,figData.boutonThresh{i}{j}{k},0,i,j);
        figData.boutonWidth{i}{j}{k} = cbw;
        figData.boutonCrossProfile{i}{j}{k} = cbcp;
        figData.boutonCrossSegment{i}{j}{k} = cbcseg;

        figData.boutonCenter{i}{j} = cbc;
    end
    
    guidata(hfig,figData)
    guidata(qcfig,qcfigData)
end

function replotQC(qcfig,hfig)
    figData = guidata(hfig);
    qcfigData = guidata(qcfig);

    index = qcfigData.index;
    i = qcfigData.reviewBoutons(index,1);
    j = qcfigData.reviewBoutons(index,2);
    k = qcfigData.reviewBoutons(index,3);
    
    cbc = figData.boutonCenter{i}{j};
    centered = ~any(isnan(cbc(k,1:3)),2);
    complete = qcfigData.reviewBoutons(index,4);
    failed = qcfigData.failed(index);

    hold off
    if centered
        plotCenter = cbc(k,:);
        
        ymin = round(plotCenter(2))-50;
        ymin(ymin<1)=1;
        xmin = round(plotCenter(1))-50;
        xmin(xmin<1)=1;
        ymax = round(plotCenter(2))+50;
        ymax(ymax>figData.dims{i}(2)) = figData.dims{i}(2);
        xmax = round(plotCenter(1))+50;
        xmax(xmax>figData.dims{i}(1)) = figData.dims{i}(1);
        
        boutonImage = figData.stackDataShuffled{i}(:,:,plotCenter(3));
        boutonImageROI = boutonImage(ymin:ymax,xmin:xmax);
        image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
        hold on
        
        if complete
            backbone = figData.axonTraceSnapSkipped{i}{j};
            backbone = backbone(backbone(:,2) > ymin & backbone(:,2) < ymax,:);
            backbone = backbone(backbone(:,1) > xmin & backbone(:,1) < xmax,:);

            backbone1 = backbone;
            backbone1(isnan(backbone1(:,4)),:) = nan;
            line(backbone1(:,1)-xmin+1,backbone1(:,2)-ymin+1,'Color','b');

            backbone2 = backbone;
            backbone2(~isnan(backbone2(:,4)),:) = nan;
            line(backbone(:,1)-xmin+1, backbone2(:,2)-ymin+1,'Color','r');

            cbcseg = figData.boutonCrossSegment{i}{j}{k};
            line(cbcseg(:,1)-xmin+1,cbcseg(:,2)+1-ymin,'Color',[1 .2 .2],'LineWidth',2);

            axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
        end
        
    else
        clf
        text(.4,.5,'NO CENTER');
        axis([0,1,0,1])
%         set(gca,'Visible','off');
        hold on
    end
    
    titleStr = {' PASSED',' FAILED',' INCOMPLETE'};
    titleStr = strjoin(titleStr(find([~failed,failed,~complete])));
    statStrAbbr = {'Alpha','Beta','Exclude','Absent'};
    title(['ID: ' num2str([i j k])    ' Status: ' statStrAbbr(figData.boutonStatus{i}{j}(k,:)>0), titleStr]);

    axis square;
    set(gca,'xtick',[],'ytick',[]);
    set(gca, 'Ydir','reverse');
    colormap('bone');

    guidata(qcfig,qcfigData);
end



function hfig = commitAndSummary(hfig,qcfig)
    figData = guidata(hfig);
    qcfigData = guidata(qcfig);

    for i = 1:figData.numStacks
        for j = 1:25
            if ~isempty(figData.boutonCenter{i}{j})
                idx = ismember(qcfigData.reviewBoutons(:,1:2),[i,j],'rows');
                idx = find(idx .* ~qcfigData.failed);
                passed = figData.boutonPassed{i}{j};
                passed = [passed;qcfigData.reviewBoutons(idx,3)];
                passed = sort(passed);
                figData.boutonPassed{i}{j} = passed;
            end
        end
    end
    
    guidata(hfig,figData);

    failed = qcfigData.reviewBoutons(find(qcfigData.failed),:);
    failedComplete = failed(find(failed(:,4)),:);
    failedIncomplete = failed(find(~failed(:,4)),:);
    
    [~,idx] = sort(failedComplete(:,5));
    failedComplete = failedComplete(idx,1:3);
    
    [~,idx] = sort(failedIncomplete(:,5));
    failedIncomplete = failedIncomplete(idx,1:3);
    
    failed = [failedComplete;failedIncomplete];
    
    disp(failed);
    
    stack = failed(:,1);
    axon = failed(:,2);
    bouton = failed(:,3);
    T = table(stack,axon,bouton);
    qcFailSummary = figure;
    TString = evalc('disp(T)');
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    FixedWidth = get(0,'FixedWidthFontName');
    an = annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

    figure(qcfig)
end
