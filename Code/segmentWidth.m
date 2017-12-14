function [width,backboneCenter,perpProfile, crossSegment] = segmentWidth(perpTrace,hfig,slope,intercept,i,j)
    figData = guidata(hfig);
%     interpN = 100;
%     stdevCut = 1.25;
%     
%     
%     %interp line across bouton
%     [xi,yi,int] = improfile(figData.stackDataShuffled{i}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), interpN);
%     intfit=fit((1:interpN)', int, 'gauss1','Lower',[0,0,0],'Upper',[100,interpN,100]);
%     coeff = coeffvalues(intfit);
%     perpProfile = int;
%     backbone = figData.axonBrightnessProfile{i}{j}(:,1:2);
%     crossSegment = [xi,yi];
%     perpCenter = crossSegment(round(coeff(2)),:);
%     perpCenterDiff = bsxfun(@minus,backbone,perpCenter);
%     [~,a] = min(sum(sqrt(perpCenterDiff.^2),2));
%     backboneCenter = [backbone(a,1:2),perpTrace(1,3),a];
%     cutoff = (.75 + 1.5*median(int)/30) * coeff(3);
%     
%     segmentRange = (round(coeff(2)-cutoff)) : (round(coeff(2)+cutoff));
%     crossSegment = crossSegment(segmentRange,:);
%     if ~isempty(crossSegment)
%         width = sqrt(sum(sum(diff(crossSegment)).^2));
%     else
%         width = 0;
%     end
% end
%     
    
    
    
    
    
    
    
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