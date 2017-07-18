function cursorMotion(hfig,~,~,~)
    figData = guidata(hfig);
    [~,bounds] = adjCursor(hfig);
    try delete(figData.cursor); end
    if ~isempty(bounds)
        hold on
        figData.cursor = plot(bounds{1}(:,2), bounds{1}(:,1),'r');
    end
    guidata(hfig,figData);
end


