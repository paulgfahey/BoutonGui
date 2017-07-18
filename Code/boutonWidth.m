function [width, cropbouton] = boutonWidth(hfig,perpTrace)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    %length of the perpendicular trace clicked
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    
    %distance to expand roi image beyond centerpoint of clicked trace
    roiheight = 25;
    roilength = 50;
    
    %properties of clicked trace
    center = round(mean(perpTrace(:,1:2),1));
    perpslope = [diff(perpTrace(:,1)) diff(perpTrace(:,2))]./lengthPerpTrace;
    paraslope = [perpslope(2),-perpslope(1)];
    
    %create roi along axes relative to perpSlope
    corners = [-roiheight * perpslope + roilength * paraslope;...
               -roiheight * perpslope - roilength * paraslope;...
                roiheight * perpslope - roilength * paraslope;...
                roiheight * perpslope + roilength * paraslope];
    
    %center roi on backbone point closes to center of perpTrace
    backbone = figData.axonBrightnessProfile{cs}{ca}(:,1:2);
    [~,a] = min(sum(sqrt((backbone-center).^2),2));
    corners = corners + backbone(a,1:2);
    
    %correct corners outside of image dimensions
    corners(corners<0) = 0;
    corners(corners(:,1)>figData.dims{cs}(1),1) = figData.dims{cs}(1);
    corners(corners(:,2)>figData.dims{cs}(2),2) = figData.dims{cs}(2);
    
    %create mask from corners
    mask = poly2mask(corners(:,1),corners(:,2),figData.dims{cs}(1),figData.dims{cs}(2));
    
    %fetch stack data
    stack = figData.stackDataShuffled{cs}(:,:,perpTrace(1,3));

    %find angle of slope, rotate mask and stack by that angle
    angle = atand(perpslope(1)/perpslope(2));
    rotatemask = imrotate(mask,angle);
    stack = imrotate(stack,angle);
    rotatebouton = stack.*uint8(rotatemask);
    cropbouton = rotatebouton.*uint8(rotatemask);
    
    %interp line across bouton
    [xi,yi,int] = improfile(figData.stackDataShuffled{cs}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), lengthPerpTrace);
    
    %use local median backbone int for width cutoff
    medianint = figData.axonBrightnessProfileWeights{cs}{ca}(a,4); 
    
    %find index of largest blob over medianint threshold
    [profile] = pickBlob(int,medianint);
    indx = [find(~isnan(profile),1,'first');
            find(~isnan(profile),1,'last')];
    
    %measure width from blob indices
    crossSegment = [xi,yi];
    crossSegment = crossSegment(indx,:);
    width = sqrt(sum(diff(crossSegment).^2));
    
    guidata(hfig,figData);
end


function [profile] = pickBlob(int,medianint)
    int(int < .175*medianint) = nan; %exclude values under Thresh * MeanBackgroundInt
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
