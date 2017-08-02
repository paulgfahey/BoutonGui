function axonReplot(hfig)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    
    cats = figData.axonTraceSnapSkipped{cs};
    
    if ~isempty(cats)
        for i = 1:size(cats,2)
            cat = cats{i};
            if ~isempty(cat)
                cat(isnan(cat(:,4)),:) = nan;
                text(mean(cat(:,1)),mean(cat(:,2)),num2str(i),'Color',[.5,.5,.7]);
                
                %plot all segments in currentZ
                catInPlane = cat;
                catInPlane(cat(:,3) ~= figData.currentZ{cs},:) = nan;
                if ~isempty(catInPlane)
                    line(catInPlane(:,1),catInPlane(:,2),'Color','c','LineStyle','-','linewidth',1);
                end
    
                %plot all segments outside of current Z
                catOutOfPlane = cat;
                catOutOfPlane(cat(:,3) == figData.currentZ{cs},:) = nan;

                catBelowPlane = catOutOfPlane;
                catBelowPlane(catBelowPlane(:,3)>figData.currentZ{cs},:) = nan;

                catAbovePlane = catOutOfPlane;
                catAbovePlane(catAbovePlane(:,3)<figData.currentZ{cs},:) = nan;
    
                if ~isempty(catBelowPlane)
                    line(catBelowPlane(:,1),catBelowPlane(:,2),'Color',[.5,.5,.9],'LineStyle','-','linewidth',1);
                end

                if ~isempty(catAbovePlane)
                    line(catAbovePlane(:,1),catAbovePlane(:,2),'Color',[.5,.5,.9],'LineStyle','-','linewidth',1);
                end
                
                
                %plot segments transitioning into or out of current plane
                inPlane = logical(cat(:,3) == figData.currentZ{cs});
                inPlaneLeft = logical([inPlane(2:end); 0]);
                inPlaneRight = logical([0; inPlane(1:end-1)]);

                belowPlaneLeft = inPlaneLeft & not(inPlane) & (cat(:,3) < figData.currentZ{cs});
                abovePlaneLeft = inPlaneLeft & not(inPlane) & (cat(:,3) > figData.currentZ{cs});

                belowPlaneRight = inPlaneRight & not(inPlane) & (cat(:,3)<figData.currentZ{cs});
                abovePlaneRight = inPlaneRight & not(inPlane) & (cat(:,3)>figData.currentZ{cs});

                belowPlaneLeft = belowPlaneLeft + [0; belowPlaneLeft(1:end-1)];
                abovePlaneLeft = abovePlaneLeft + [0; abovePlaneLeft(1:end-1)];

                belowPlaneRight = belowPlaneRight + [belowPlaneRight(2:end);0];
                abovePlaneRight = abovePlaneRight + [abovePlaneRight(2:end);0];

                belowPlaneTransition = cat;
                belowPlaneTransition(~belowPlaneLeft & ~belowPlaneRight,:) = nan;

                abovePlaneTransition = cat;
                abovePlaneTransition(~abovePlaneLeft & ~abovePlaneRight,:) = nan;

                if~isempty(belowPlaneTransition)
                    line(belowPlaneTransition(:,1),belowPlaneTransition(:,2),'Color',[.5,.5,.6],'LineStyle','-','linewidth',1);
                end

                if~isempty(abovePlaneTransition)
                    line(abovePlaneTransition(:,1),abovePlaneTransition(:,2),'Color',[.5,.5,.6],'LineStyle','-','linewidth',1);
                end
                
                cat = cats{i};
                cat(~isnan(cat(:,4)),:) = nan;
                line(cat(:,1),cat(:,2),'Color','r','LineStyle','-','linewidth',1);
            end
        end
    end
end