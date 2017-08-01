function testThresh3(hfig,background,percentMedian, percentMax)

    figData = guidata(hfig);

    filename = strrep(figData.mouseFileName,'.mat','');
    for j = 1:figData.maxAxon
        for k = 1:figData.maxBouton(j)
            boutonSummary = figure;
            for i = 1:figData.numStacks
                cbc = figData.boutonCenter{i}{j};
                cbcs = figData.boutonCross{i}{j}{k};
                lacp = figData.axonCross{i}{j}{k};

                if ~isempty(cbcs)
                    boutonImage = figData.stackDataShuffled{i}(:,:,cbc(k,3));

                    ymin = round(cbc(k,2))-20;
                    ymin(ymin<1)=1;
                    xmin = round(cbc(k,1))-20;
                    xmin(xmin<1)=1;
                    ymax = round(cbc(k,2))+20;
                    ymax(ymax>figData.dims{i}(2)) = figData.dims{i}(2);
                    xmax = round(cbc(k,1))+20;
                    xmax(xmax>figData.dims{i}(1)) = figData.dims{i}(1);

                    boutonImageROI = boutonImage(ymin:ymax,xmin:xmax);

                    subplot(3,3,i)
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    hold on
                    [boutWidth,crossSegment] = backSegment(hfig,cbcs(1:2,:),background,i);
                    line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                    axonWidth = [];
                    for o = 1:floor(size(lacp,1)/2)
                        [width,crossSegment] = backSegment(hfig, lacp(1:2,:),background,i);
                        line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                        axonWidth = [axonWidth;width]; %#ok<AGROW>
                    end
                    titleStr = num2str(round(boutWidth/mean(axonWidth)));
                    if i == 2
                        titleStr = ['background thresh' titleStr];
                    end
                    title(titleStr);
                    axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
                    formatImage

                    subplot(3,3,i+3)
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    hold on
                    [boutWidth,~,~,crossSegment] = segmentWidth(cbcs(1:2,:),hfig,percentMedian,0,i,j);
                    line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                    axonWidth = [];
                    for o = 1:floor(size(lacp,1)/2)
                        [width,~,~,crossSegment] = segmentWidth(lacp(2*o-1:2*o,:),hfig,percentMedian,0,i,j);
                        line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                        axonWidth = [axonWidth;width]; %#ok<AGROW>
                    end
                    titleStr = num2str(round(boutWidth/mean(axonWidth)));
                    if i == 2
                        titleStr = ['percent median int thresh' titleStr];
                    end
                    title(titleStr);
                    axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
                    formatImage

                    subplot(3,3,i+6)
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    hold on
                    [boutWidth, crossSegment] = percentMaxWidth(hfig, cbcs(1:2,:),percentMax,i);
                    line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                    axonWidth = [];
                    for o = 1:floor(size(lacp,1)/2)
                        [width, crossSegment] = percentMaxWidth(hfig,lacp(2*o-1:2*o,:),percentMax,i);
                        line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                        axonWidth = [axonWidth;width]; %#ok<AGROW>
                    end
                    titleStr = num2str(round(boutWidth/mean(axonWidth)));
                    if i == 2
                        titleStr = ['percent max thresh' titleStr];
                    end
                    title(titleStr);
                    axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
                    formatImage
                end


            end
            set(boutonSummary,'Position',get(0,'Screensize'));
            print(boutonSummary,'-dpng',[filename 'A' num2str(j) 'B' num2str(k) 'S' num2str(i) 'testparam'],'-noui')
            close(boutonSummary)
        end
end
end

         

function formatImage
axis square;
set(gca,'xtick',[],'ytick',[]);
set(gca, 'Ydir','reverse');
colormap('bone');
end

function [width,crossSegment] = backSegment(hfig, perpTrace,backThresh,i)
    figData = guidata(hfig);
    
    %properties of the perpendicular trace clicked
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    
    %interp line across bouton
    [xi,yi,int] = improfile(figData.stackDataShuffled{i}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), lengthPerpTrace);
    perpProfile = int;

    perpProfile(perpProfile < backThresh) = nan;
    [imlabel,totalLabels] = bwlabel(~isnan(perpProfile));
    sizeBlob = zeros(1,totalLabels);
    for j = 1:totalLabels
        sizeBlob(j) = length(find(imlabel == j));
    end
    [~,largestBlobNo] = max(sizeBlob);

    if ~isempty(largestBlobNo)
        perpProfile(imlabel ~= largestBlobNo) = nan;
    end
    profile = perpProfile;
    
    indx = [find(~isnan(profile),1,'first');
            find(~isnan(profile),1,'last')];
            
    crossSegment = [xi,yi];
    crossSegment = crossSegment(indx,:);
    
     if ~isempty(crossSegment)
        width = sqrt(sum(diff(crossSegment).^2));
    else
        width = 0;
    end
    
end

function [width,crossSegment] = percentMaxWidth(hfig,perpTrace,percentCutoff,i)
    figData = guidata(hfig);
    %properties of the perpendicular trace clicked
    lengthPerpTrace = sqrt(sum(diff(perpTrace(:,1:2)).^2));
    
    %interp line across bouton
    [xi,yi,int] = improfile(figData.stackDataShuffled{i}(:,:,perpTrace(1,3)),perpTrace(:,1),perpTrace(:,2), lengthPerpTrace);
    perpProfile = int;

    perpProfile(perpProfile < (percentCutoff*max(perpProfile))) = nan;
    [imlabel,totalLabels] = bwlabel(~isnan(perpProfile));
    sizeBlob = zeros(1,totalLabels);
    for j = 1:totalLabels
        sizeBlob(j) = length(find(imlabel == j));
    end
    [~,largestBlobNo] = max(sizeBlob);

    if ~isempty(largestBlobNo)
        perpProfile(imlabel ~= largestBlobNo) = nan;
    end
    profile = perpProfile;
    
     indx = [find(~isnan(profile),1,'first');
            find(~isnan(profile),1,'last')];
            
    crossSegment = [xi,yi];
    crossSegment = crossSegment(indx,:);
    
     if ~isempty(crossSegment)
        width = sqrt(sum(diff(crossSegment).^2));
    else
        width = 0;
    end
    
end


