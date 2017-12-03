function hfig = axonQualityControl(hfig)
    [cs,ca,~,~,~] = currentOut(hfig);
    tic; hfig = genAxonCross(hfig); toc
    figData = guidata(hfig);
    
    qcfig = figure;
    set(qcfig,'Name','Quality Control','NumberTitle','off')
    set(qcfig,'KeyPressFcn',{@keyPress,hfig});
    qcfigData = guidata(qcfig);

    
    qcfigData.fittedCutPoints = figData.axonCrossFitCutPoints{cs}{ca};
    qcfigData.index = 1;
    nanlessCutPoints = qcfigData.fittedCutPoints(~isnan(qcfigData.fittedCutPoints(:,1)),:);
    qcfigData.failed = ones(size(nanlessCutPoints,1),1);
    qcfigData.nanlessPoints = qcfigData.fittedCutPoints(~isnan(qcfigData.fittedCutPoints(:,1)),:);
    qcfigData.nanlessIdx = find(~isnan(qcfigData.fittedCutPoints(:,1)));
    
    guidata(qcfig,qcfigData);
    
    replotQC(qcfig,hfig);
    guidata(hfig,figData)
    guidata(qcfig,qcfigData);
end




function keyPress(qcfig,events,hfig)
qcfigData = guidata(qcfig);

if strcmp(events.Key,'leftarrow') && qcfigData.index>1
    qcfigData.index = qcfigData.index - 1;
end

if strcmp(events.Key,'rightarrow') && qcfigData.index < size(qcfigData.failed,1)
    qcfigData.index = qcfigData.index + 1;
end

if strcmp(events.Key,'space')
    qcfigData.failed(qcfigData.index) = ~qcfigData.failed(qcfigData.index);
end

if any(strcmp(events.Key,{'leftarrow','rightarrow','space'}))
    guidata(qcfig,qcfigData)
    replotQC(qcfig,hfig);
end

if strcmp(events.Key,'e')
    hfig = commitAndSummary(hfig,qcfig);
    qcfigData = guidata(qcfig);
end

end



function replotQC(qcfig,hfig)
    [cs,ca,~,~,~] = currentOut(hfig);
    
    figData = guidata(hfig);
    qcfigData = guidata(qcfig);
    idx = qcfigData.index;
    failed = qcfigData.failed(idx);
    points = qcfigData.nanlessPoints(idx,:);
    
    
    ymin = round(min([points(2),points(4)]))-50;
    ymin(ymin<1)=1;
    xmin = round(min([points(1),points(3)]))-50;
    xmin(xmin<1)=1;
    ymax = round(max([points(2),points(4)]))+50;
    ymax(ymax>figData.dims{cs}(2)) = figData.dims{cs}(2);
    xmax = round(max([points(1),points(3)]))+50;
    xmax(xmax>figData.dims{cs}(1)) = figData.dims{cs}(1);
        
    axonImage = figData.stackDataShuffled{cs}(:,:,points(5));
    axonImageROI = axonImage(ymin:ymax,xmin:xmax);
    image(imadjust(axonImageROI,[0,figData.high_in{cs}], [0 figData.high_out{cs}]));
    hold on
    
    backbone = figData.axonTraceSnapSkipped{cs}{ca}; 
    backbone = backbone(backbone(:,2) > ymin & backbone(:,2) < ymax,:);
    backbone = backbone(backbone(:,1) > xmin & backbone(:,1) < xmax,:);
    backbone1 = backbone;
    backbone1(isnan(backbone1(:,4)),:) = nan;
    line(backbone1(:,1)-xmin+1, backbone1(:,2)-ymin+1, 'Color','b');
    
    backbone2 = backbone;
    backbone2(~isnan(backbone2(:,4)),:) = nan;
    line(backbone(:,1)-xmin+1, backbone2(:,2)-ymin+1,'Color','r');
    
    line([points(1), points(3)]-xmin+1,[points(2),points(4)]-ymin+1, 'Color',[.2 1 .2], 'LineWidth',2);
    
    axis([0 size(axonImageROI,1) 0 size(axonImageROI,2)]);
    
    titleStr = {' PASSED',' FAILED'};
    titleStr = strjoin(titleStr(find([~failed,failed])));
    title(titleStr);
    
    axis square;
    set(gca,'xtick',[],'ytick',[]);
    set(gca, 'Ydir','reverse');
    colormap('bone');

    
    guidata(qcfig,qcfigData);
end

function hfig = commitAndSummary(hfig,qcfig)
    [cs,ca,~,~,~] = currentOut(hfig);
    figData = guidata(hfig);
    qcfigData = guidata(qcfig);
    
    failed = qcfigData.nanlessIdx(qcfigData.failed>0);
    
    figData.axonCrossFitAng{cs}{ca}(failed,:) = nan;
    figData.axonCrossFitPoints{cs}{ca}(failed,:) = nan; 
    figData.axonCrossFitCutPoints{cs}{ca}(failed,:) = nan;
    figData.axonCrossFitLengths{cs}{ca}(failed,:) = nan;
    
    %extract legitimate cross lengths
    fittedLengths = figData.axonCrossFitLengths{cs}{ca};
    fittedLengthsNanless = fittedLengths(~isnan(fittedLengths));
    fittedLengthsIdx = find(~isnan(fittedLengths));
    
    %perform median filter
    medFiltN = 7;
    fittedFilteredProfile = medfilt1(fittedLengthsNanless,medFiltN);
    
    %interpolate median filtered widths to full axon length
    fittedFilteredProfileInterp = interp1(fittedLengthsIdx, fittedFilteredProfile, 1:length(figData.axonTraceSnapSkipped{cs}{ca}(:,1)));
    fittedFilteredProfileInterp(1:min(fittedLengthsIdx)) = fittedFilteredProfile(1);
    fittedFilteredProfileInterp(max(fittedLengthsIdx):end) = fittedFilteredProfile(end);
    
    figData.axonCrossFitFilteredProfile{cs}{ca} = fittedFilteredProfileInterp;
    
    figure;
    plane = round(nanmean(figData.axonCrossFitPoints{cs}{ca}(:,5)));
    axonImage = figData.stackDataShuffled{cs}(:,:,plane);
    image(imadjust(axonImage,[0,figData.high_in{cs}], [0 figData.high_out{cs}]));
    for i = 1:length(figData.axonCrossFitCutPoints{cs}{ca}(:,1))
        points = figData.axonCrossFitCutPoints{cs}{ca}(i,:);
        line([points(1),points(3)], [points(2),points(4)], 'Color',[.2 1 .2], 'LineWidth', 2);
    end
    
    subplot(2,1,1);
    hold on;
    plot(figData.axonBrightnessProfile{cs}{ca}(:,4));
    plot(figData.axonBrightnessProfileBaseline{cs}{ca}(:,4));
    subplot(2,1,2);
    plot(figData.axonCrossFitFilteredProfile{cs}{ca});
    
    guidata(hfig,figData);   
end
