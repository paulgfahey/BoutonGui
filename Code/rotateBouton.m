function [boutonImageROIRot] = rotateBouton(perpTrace,center,hfig,i)
    figData = guidata(hfig);
    [cs,~,~,~,~] = currentOut(hfig);
    
    %find angle of rotation
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    perpslope = [diff(perpTrace(:,1)) diff(perpTrace(:,2))]./lengthPerpTrace;
    angle = atand(perpslope(1)/perpslope(2));
    
    %rotate stack
    stack = figData.stackDataShuffled{i}(:,:,perpTrace(1,3));
    stack = imrotate(stack,-angle);
    
    %rotation matrix for angle
    rotationMatrix = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];
    
    %need to correct for larger dimensions in rotated image
    dimsRaw = figData.dims{cs}';
    dimsRot = size(stack)';
    
    %rotate position relative to center, then reposition in new dims
    points = center' - dimsRaw/2;
    points = rotationMatrix * points;
    center = points + dimsRot/2;
    
    %define ROI relative to center
    ymin = round(center(1))-25;
    ymin(ymin<0)=0;
    xmin = round(center(2))-25;
    xmin(xmin<0)=0;
    
    %crop stack to ROI
    stack = imcrop(stack,[ymin,xmin,50,50]);
    boutonImageROIRot = stack;
end