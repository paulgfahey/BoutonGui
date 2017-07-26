function testThresh2(interceptMin, interceptMax, slopeMin, slopeMax,n,hfig)

figData = guidata(hfig);

filename = strrep(figData.mouseFileName,'.mat','');
for j = 1:figData.maxAxon
    for k = 1:figData.maxBouton(j)
        if all(figData.boutonCount(j,k,:))
            
            for i = 1:figData.numStacks
                boutonSummary = figure;
                cbc = figData.boutonCenter{i}{j};
                cbcs = figData.boutonCross{i}{j}{k};
                lacp = figData.axonCross{i}{j}{k};
                
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
                
                intercept = interceptMin:(interceptMax-interceptMin)/(n-1):interceptMax;
                slope = slopeMin:(slopeMax-slopeMin)/(n-1):slopeMax;
                
                

                for m = 1:n^2
                    subplot(n,n,m)
                    image(imadjust(boutonImageROI,[0 figData.high_in{i}],[0 figData.high_out{i}]));
                    hold on
                    s = mod((m-1),n)+1;
                    in = floor((m-1)/n)+1;
                    [boutWidth,~,~,crossSegment] = segmentWidth(cbcs(1:2,:),hfig,slope(s),intercept(in));
                    line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                    axonWidth = [];
                    for o = 1:floor(size(lacp,1)/2)
                        [width,~,~,crossSegment] = segmentWidth(lacp(2*o-1:2*o,:),hfig,slope(s),intercept(in));
                        line(crossSegment(:,1)-xmin+1,crossSegment(:,2)-ymin+1,'Color','g');
                        axonWidth = [axonWidth;width]; %#ok<AGROW>
                    end
                    title(['slope ' num2str(slope(s)) 'int ' num2str(intercept(in)) ' ' num2str(round(boutWidth/mean(axonWidth)))]);
                    axis([0 size(boutonImageROI,1) 0 size(boutonImageROI,2)]);
                    formatImage
                    
                end
                set(boutonSummary,'Position',get(0,'Screensize'));
                print(boutonSummary,'-dpng',[filename 'A' num2str(j) 'B' num2str(k) 'S' num2str(i) 'testparam'],'-noui')
                close(boutonSummary)
            end
            
        end
    end
end
end

         

function formatImage
axis square;
set(gca,'xtick',[],'ytick',[]);
set(gca, 'Ydir','reverse');
colormap('bone');
end
                    


