function [width,backboneCenter,perpProfile, crossSegment] = segmentWidth(perpTrace,hfig)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);

    %properties of the perpendicular trace clicked
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    perpCenter = round(mean(perpTrace(:,1:2),1));
    
    %interp line across bouton
    [xi,yi,int] = improfile(figData.stackDataShuffled{cs}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), lengthPerpTrace);
    perpProfile = int;
    
    %use local median backbone int for width cutoff
    backbone = figData.axonBrightnessProfile{cs}{ca}(:,1:2);
    perpCenter = round(mean(perpTrace(:,1:2),1));
    [~,a] = min(sum(sqrt((backbone-perpCenter).^2),2));
    backboneCenter = [backbone(a,1:2),figData.currentZ{cs}];
    medianint = figData.axonBrightnessProfileWeights{cs}{ca}(a,4); 
    
    %find index of largest blob over medianint threshold
    [profile] = pickBlob(int,medianint);
    indx = [find(~isnan(profile),1,'first');
            find(~isnan(profile),1,'last')];
    
    %measure width from blob indices
    crossSegment = [xi,yi];
    crossSegment = crossSegment(indx,:);
    width = sqrt(sum(diff(crossSegment).^2));
end

function [profile] = pickBlob(int,medianint)
    int(int < .5*medianint) = nan; %exclude values under Thresh * MeanBackgroundInt
    [imlabel,totalLabels] = bwlabel(~isnan(int));
    sizeBlob = zeros(1,totalLabels);
    for j = 1:totalLabels
        sizeBlob(j) = length(find(imlabel == j));
    end
    [~,largestBlobNo] = max(sizeBlob);

    if ~isempty(largestBlobNo)
        int(imlabel ~= largestBlobNo) = nan;
    end
    profile = int;
end