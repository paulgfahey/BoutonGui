function [width, rotBouton, rotCross, rotBackbone,corners] = boutonShape(hfig,perpTrace)
    
    [width,crossSegment] = boutonWidth(perpTrace,hfig);
    
    [rotBouton,rotCross,rotBackbone,corners] = rotateBouton(perpTrace,crossSegment,hfig);
    
end

function [width,crossSegment] = boutonWidth(perpTrace,hfig)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);

    %length of the perpendicular trace clicked
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    
    %interp line across bouton
    [xi,yi,int] = improfile(figData.stackDataShuffled{cs}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), lengthPerpTrace);
    
    %use local median backbone int for width cutoff
    backbone = figData.axonBrightnessProfile{cs}{ca}(:,1:2);
    perpCenter = round(mean(perpTrace(:,1:2),1));
    [~,a] = min(sum(sqrt((backbone-perpCenter).^2),2));
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

function [rotBouton, rotCross, rotBackbone, corners] = rotateBouton(perpTrace,crossSegment,hfig)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    %distance to expand roi image beyond centerpoint of clicked trace
    roiheight = 12.5;
    roilength = 25;
    
    %properties of clicked trace
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    perpCenter = round(mean(perpTrace(:,1:2),1));
    perpslope = [diff(perpTrace(:,1)) diff(perpTrace(:,2))]./lengthPerpTrace;
    paraslope = [perpslope(2),-perpslope(1)];
    
    %rotation properties
    angle = atand(perpslope(1)/perpslope(2));
    
    %rotate stack
    stack = figData.stackDataShuffled{cs}(:,:,perpTrace(1,3));
    stack = imrotate(stack,-angle);
    dimsRot = size(stack)';
    
    %create roi along axes relative to perpSlope
    corners = [-roiheight * perpslope + roilength * paraslope;...
               -roiheight * perpslope - roilength * paraslope;...
                roiheight * perpslope - roilength * paraslope;...
                roiheight * perpslope + roilength * paraslope];
            
    %center roi on backbone point closes to center of perpTrace
    backbone = figData.axonBrightnessProfile{cs}{ca}(:,1:2);
    [~,a] = min(sum(sqrt((backbone-perpCenter).^2),2));
    backboneCenter = backbone(a,1:2);
    corners = corners + backbone(a,1:2);
    
    %rotate corners, backbone, backbone center
    dimsRaw = figData.dims{cs}';
    corners = rotatePoints(corners',angle,dimsRaw, dimsRot);
    backboneCenter = rotatePoints(backboneCenter',angle,dimsRaw, dimsRot);
    backbone = rotatePoints(backbone',angle,dimsRaw,dimsRot);
    
    %find rotated backbone points inside corners;
    backbone = backbone(:,backbone(1,:) > min(corners(1,:)) & backbone(1,:) < max(corners(1,:)));
    backbone = backbone(:,backbone(2,:) > min(corners(2,:)) & backbone(2,:) < max(corners(2,:)));
    rotBackbone = backbone;
    
    %rotate crossSegment
    rotCross = rotatePoints(crossSegment(:,1:2)',angle,dimsRaw, dimsRot);
    
    %crop stack
    stack = imcrop(stack,[min(corners(1,:)),min(corners(2,:)),2*roilength,2*roiheight]);
    rotBouton = stack;
    
    %normalize to roi window
    rotCross = rotCross - min(corners,[],2)+1;
    rotBackbone = rotBackbone - min(corners,[],2)+1;
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

function points = rotatePoints(points,angle,dimsRaw, dimsRot)
    rotationMatrix = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];
    points = points - dimsRaw/2;
    points = rotationMatrix * points;
    points = points + dimsRot/2;
end
