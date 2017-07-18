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
        axonPlot(hfig);
        boutonPlot(hfig);
        hold off
    end
    
    guidata(hfig,figData)
end


function axonPlot(hfig)
    figData = guidata(hfig);
    [cs,ca,~,~,~] = currentOut(hfig);
    cats = figData.axonTraceSnap{cs}; %axon traces for current stack
    if ~isempty(cats)
        for i = 1:size(cats,2)
            cat = cats{i};
            if ~isempty(cat)
                text(mean(cat(:,1)),mean(cat(:,2)),num2str(i),'Color',[.5,.5,.7]);

                catInPlane = cat;
                catInPlane(cat(:,3) ~= figData.currentZ{cs},:) = nan;
                if ~isempty(catInPlane)
                    line(catInPlane(:,1),catInPlane(:,2),'Color','c','LineStyle','-','linewidth',1);
                end

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
            end
        end
    end

    csat = figData.axonSkipTraceSnap{cs}{ca};
    if ~isempty(csat)
        csaplot = [];

        for i = 1:size(csat,2)
            csa = csat{i};
            if ~isempty(csa) && size(csa,1)>1
                csaplot = [csaplot;nan(1,3);csa]; %#ok<AGROW>
            end
        end

        if ~isempty(csaplot)
            line(csaplot(:,1),csaplot(:,2),'Color','r','LineStyle','-','linewidth',1);
        end
    end
end

function boutonPlot(hfig)
    figData = guidata(hfig);
    [cs,ca,cb,~,~] = currentOut(hfig);

    cbc = figData.boutonCenter{cs}{ca};
    statStrAbbr = {'A','B','E','X','T'};
    if ~isempty(cbc)
        for j = 1:size(cbc,1)
            figData.boutonNums = text(cbc(j,1)+5,cbc(j,2),[num2str(j) statStrAbbr(figData.boutonStatus{cs}{ca}(j,:)>0)],'Color','red');
        end
    end

    cbcr = figData.boutonCross{cs}{ca}{cb};
    if ~isempty(cbcr)
        for j = 2:2:size(cbcr,1)
            line(cbcr(j-1:j,1), cbcr(j-1:j,2),'Color','y','LineStyle','-','linewidth',1)
        end
    end


    cbbs = figData.boutonBoundary{cs}{ca};
    if ~isempty(cbbs)
        for i = 1:size(cbbs,2)
            cbb = figData.boutonBoundary{cs}{ca}{i};
            if ~isempty(cbb)
                line(cbb(:,2),cbb(:,1),'Color','r','LineStyle','-','linewidth',1)
            end
        end
    end
    
    arb = figData.axonBoundary{cs}{ca};
    if ~isempty(arb)
        carb = figData.axonBoundary{cs}{ca}{cb};
        if ~isempty(carb)
            line(carb(:,2),carb(:,1),'Color',[.9 .5 .5],'LineStyle','-','linewidth',1)
        end
    end
    
    autoPeaks = figData.axonWeightedBrightnessPeaks{cs}{ca};
    if ~isempty(autoPeaks)
        [imlabel, totalLabels] = bwlabel(~isnan(autoPeaks(:,4)));
        for j = 1:totalLabels
            peakSegment = autoPeaks(imlabel == j,:);
            scatter(mean(peakSegment(:,1)),mean(peakSegment(:,2)),'or')
        end
    end

end

