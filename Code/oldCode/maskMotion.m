function maskMotion(hfig,~,~,~,~)
    figData = guidata(hfig);
    [~,~,bounds] = adjMask(hfig);
    try delete(figData.cursor); end %#ok<*TRYNC>
    if ~isempty(bounds)
        hold on
        figData.cursor = plot(bounds{1}(:,2), bounds{1}(:,1),'r');
    end
    guidata(hfig,figData);
end
