function boutonReplot(hfig)
    figData = guidata(hfig);
    [cs,ca,cb,~,~] = currentOut(hfig);

    cbc = figData.boutonCenter{cs}{ca};
    statStrAbbr = {'A','B','E','X','T'};
    if ~isempty(cbc)
        for j = 1:size(cbc,1)
            if ~any(isnan(cbc(j,:)))
                figData.boutonNums = text(cbc(j,1)+5,cbc(j,2),[num2str(j) statStrAbbr(figData.boutonStatus{cs}{ca}(j,:)>0)],'Color','red');
            end
        end
    end

    cbcr = figData.boutonCross{cs}{ca}{cb};
    if ~isempty(cbcr)
        for j = 2:2:size(cbcr,1)
            line(cbcr(j-1:j,1), cbcr(j-1:j,2),'Color','g','LineStyle','-','linewidth',1)
        end
    end
    
    cacr = figData.axonCross{cs}{ca}{cb};
    if ~isempty(cacr)
        for j = 2:2:size(cacr,1)
            line(cacr(j-1:j,1),cacr(j-1:j,2),'Color','y','LineStyle','-','linewidth',1)
        end
    end
    
    autoPeaks = figData.axonWeightedBrightnessPeaks{cs}{ca};
    if ~isempty(autoPeaks)
        [imlabel, totalLabels] = bwlabel(~isnan(autoPeaks(:,4)));
        for j = 1:totalLabels
            peakSegment = autoPeaks(imlabel == j,:);
            scatter(mean(peakSegment(:,1)),mean(peakSegment(:,2)),'or')
        end
    end

end

