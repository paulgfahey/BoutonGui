function [fit_center,fit_mask,bounds] = invAdjMask(hfig)
    figData = guidata(hfig);
    [cs,~,~,cx,cy] = currentOut(hfig);
    sz = 1000;
    fit_center = zeros(1+2*sz);
    fit_center(sz+1, sz+1) = 1;
    if any([cx cy] < 0) || any([cx cy] > figData.dims{cs})
        fit_center = [];
        fit_mask = [];
        bounds = [];
    else
        winmin = [cy-sz,cx-sz];
        winmax = [cy+sz,cx+sz];
        if any(winmin<0)
            idx = find(winmin<0);
            winmin(idx) = 1;
            winmax(idx) = 1+2*sz;
        end
        if any(winmax>figData.dims{cs})
            idx = find(winmax>figData.dims{cs});
            winmin(idx) = figData.dims{cs}(idx)-(2*sz);
            winmax(idx) = figData.dims{cs}(idx);
        end
        winy = winmin(1):winmax(1);
        winx = winmin(2):winmax(2);
        fit_window =  figData.stackDataShuffledProcessedComplement{cs}(winy, winx, figData.currentZ{cs}); 
        fit_window = imsegfmm(fit_window, fit_center>0,figData.thresh);
        fit_mask = zeros(figData.dims{cs});
        fit_mask (winy, winx) = fit_window;
        bounds = bwboundaries(fit_mask,4);
    end
    guidata(hfig,figData);
end