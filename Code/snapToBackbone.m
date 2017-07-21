function [hfig] = snapToBackbone(hfig,trace)
    %automatically centers backbone trace on local high intensity points
    %standardizes material for calculating intensity profile and median
    
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    n = 4; %rough distance between interpolated points
    spread = 5; %multiplier of unit separation, determines search space for axon center
    
    if isempty(figData.backgroundMeanInt{cs})
        disp('Error: Must select Background ROIs before using snap function')
        return
    end
    
    tic
    
    %extract trace components and parameters
    clickedX = trace(:,1);
    clickedY = trace(:,2);
    clickedZ = trace(:,3);
    traceLength = round(sum(sqrt(sum(diff(trace(:,1:2)).^2,2))));
    traceSize = size(trace,1);
    
    %interpolate trace every ~n pixels
    [xinterp,yinterp,~] = improfile(zeros(figData.dims{cs}),trace(:,1),trace(:,2),traceLength/n);
    
    %zinterp assigns clickedZ to interpolated points between clicked points
    zinterp = nan(size(xinterp,1),1);
    for i = 1:traceSize-1
        xi = sort([clickedX(i),clickedX(i+1)]);
        yi = sort([clickedY(i),clickedY(i+1)]);
        zi = clickedZ(i);
        zinterp(xinterp>=xi(1) & xinterp<=xi(2) & yinterp>=yi(1) & yinterp <= yi(2)) = zi;
    end
    
    %for each x/y set of interpolated points, find middle point
    xj = xinterp(1:end-1)+diff(xinterp)/2;  
    yj = yinterp(1:end-1)+diff(yinterp)/2;
    zj = zinterp(1:end-1);
    
    %perpendicular line segment at interp centers with length dependent on
    %spread multiplier
    xk = round([xj + spread*diff(yinterp)/2, xj - spread*diff(yinterp)/2]); 
    yk = round([yj - spread*diff(xinterp)/2, yj + spread*diff(xinterp)/2]);
    
    %Exclude segments with a point outside the image. 
    klist = false(1,size(xk,1));
    klist(any(xk>figData.dims{cs}(1),2) | any(xk<1,2)) = true;
    klist(any(yk>figData.dims{cs}(2),2) | any(yk<1,2)) = true;
    xk(klist,:) = [];
    yk(klist,:) = [];
    
    %find snap points for each perpendicular line segment
    for i = 1:length(xk)
        %interpolate perpendicular line segment with 10 points
        [xl,yl,int] = improfile(figData.stackDataShuffled{cs}(:,:,zj(i)),xk(i,:)',yk(i,:)',10);
        
        %find maximum in largest intensity blob, snap backbone trace to that point
        [profile] = pickBlob(hfig,int);
        [~,ind] = max(profile);
        xj(i) = round(xl(ind));
        yj(i) = round(yl(ind));
    end
    
    snapped = [xj,yj,zj];
    figData.axonTraceSnap{cs}{ca} = snapped;
    figData.axonTraceSnapLength{cs}{ca} = sum(sqrt(sum(diff(snapped(:,1:2)).^2,2)));
    guidata(hfig,figData)
    hfig = axonProfile(hfig);
    toc
end

function [profile] = pickBlob(hfig,plane)
%finds largest blob in interpolated segment, sets all outside points to nan
    figData = guidata(hfig);
    [cs,~,~,~,~] = currentOut(hfig);
    plane(plane < figData.backgroundThresh*figData.backgroundMeanInt{cs}) = nan; %exclude values under Thresh * MeanBackgroundInt
    [imlabel,totalLabels] = bwlabel(~isnan(plane));
    sizeBlob = zeros(1,totalLabels);
    for j = 1:totalLabels
        sizeBlob(j) = length(find(imlabel == j));
    end
    [~,largestBlobNo] = max(sizeBlob);

    if ~isempty(largestBlobNo)
        plane(imlabel ~= largestBlobNo) = nan;
    end
    profile = plane;
end
