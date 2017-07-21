function fullReplot(hfig)
    figData = guidata(hfig);
    [cs,ca,cb,~,~] = currentOut(hfig);

    image(imadjust(figData.stackDataShuffled{cs}(:,:,figData.currentZ{cs}),[0 figData.high_in{cs}], [0 figData.high_out{cs}]));
    set(gca,'units','normalized')
    set(gca,'xtick',[],'ytick',[]) 
    xlim(figData.range{cs} + figData.centers{cs}(1));
    ylim(figData.range{cs} + figData.centers{cs}(2));
    title(['shuffstack:  ' num2str(cs) '    z-plane: ' num2str(figData.currentZ{cs}) '      Axon: ' num2str(ca) ...
        '      Bouton: ' num2str(cb)   '      Status: ' figData.boutonString '     range: ' num2str(round(figData.range{cs}(2)))],'fontweight','bold')
    axis square;
    
    if figData.overlay
        hold on
        axonReplot(hfig);
        boutonReplot(hfig);
        hold off
    end
    
    guidata(hfig,figData)
end


