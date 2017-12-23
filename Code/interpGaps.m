function interpBackbone = interpGaps(hfig, profile)
    %interpolate across nan gaps in intensity trace    
    figData = guidata(hfig);
    
    [imlabel,totalLabels] = bwlabel(isnan(profile));
    for j = 1:totalLabels
        indfirst = find((imlabel == j),1,'first');
        indlast = find((imlabel == j),1,'last');
        sizeGap = length(find(imlabel == j));
        if indfirst <= 1
            if indlast+1 > size(profile,1)
                indprev = profile(indlast);
            else
                indprev = profile(indlast+1);
            end
        else
            indprev = profile(indfirst-1);
        end
        
        if indlast >= length(profile)
            indpost = indprev;
        else
            indpost = profile(indlast+1);
        end
        interpGap= interp1([1,sizeGap+2],[indprev,indpost],1:sizeGap+2);
        profile(indfirst:indlast) = interpGap(2:end-1);
    end
    interpBackbone = profile;
    guidata(hfig,figData);
end