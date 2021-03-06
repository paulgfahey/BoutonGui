function [width,backboneCenter,perpProfile, crossSegment] = segmentWidth(perpTrace,hfig,slope,intercept,i,j)
    figData = guidata(hfig);
    
    %properties of the perpendicular trace clicked
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    perpCenter = round(mean(perpTrace(:,1:2),1));
    
    %interp line across bouton
    [xi,yi,int] = improfile(figData.stackDataShuffled{i}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), lengthPerpTrace);
    perpProfile = int;
    
    %use local median backbone int for width cutoff
    backbone = figData.axonBrightnessProfile{i}{j}(:,1:2);
    perpCenter = round(mean(perpTrace(:,1:2),1));
    perpCenterDiff = bsxfun(@minus,backbone,perpCenter);
    [~,a] = min(sum(sqrt(perpCenterDiff.^2),2));
    medianint = figData.axonBrightnessProfileBaseline{i}{j}(a,4); 
    backboneCenter = [backbone(a,1:2),perpTrace(1,3),a];
    
    %find index of largest blob over medianint threshold
    [profile] = pickBlob(int,medianint,slope,intercept);
    indx = [find(~isnan(profile),1,'first');
            find(~isnan(profile),1,'last')];
    
    %measure width from blob indices
    crossSegment = [xi,yi];
    crossSegment = crossSegment(indx,:);
    if ~isempty(crossSegment)
        width = sqrt(sum(diff(crossSegment).^2));
    else
        width = 0;
    end
end

function [profile] = pickBlob(int,medianint,slope,intercept)
    int(int < (slope*medianint + intercept)) = nan;
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