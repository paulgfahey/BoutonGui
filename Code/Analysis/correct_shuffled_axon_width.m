function correct_shuffled_axon_width

    [filename,path] = uigetfile;
    loadFile = uiimport(fullfile(path,filename));
    figData = loadFile.figData;
    outData = loadFile.outData;

    for i = 1:figData.numStacks
        for j = 1:figData.maxAxon
                checkFig = figure; %#ok<NASGU>
                set(checkFig, 'Position', get(0, 'Screensize'));
                if length(figData.axonCrossFitAng)>=i;
                    if ~isempty(figData.axonCrossFitAng{i})
                        fitAng = nan(size(figData.axonCrossFitAng{i}{j}));
                        fitPoints = nan(size(figData.axonCrossFitPoints{i}{j}));
                        fitCutPoints = nan(size(figData.axonCrossFitCutPoints{i}{j}));
                        fitLengths = nan(size(figData.axonCrossFitLengths{i}{j}));

                        n = 1;
                        for k = 1:size(fitCutPoints,1)
                            if ~isnan(figData.axonCrossFitCutPoints{i}{j}(k,1))
                                [trueIdx,points] = findIdx(i,j,k,figData);
                                fitAng(trueIdx,:) = figData.axonCrossFitAng{i}{j}(k,:);
                                fitPoints(trueIdx,:) = figData.axonCrossFitPoints{i}{j}(k,:);
                                fitCutPoints(trueIdx,:) = figData.axonCrossFitCutPoints{i}{j}(k,:);
                                fitLengths(trueIdx,:) = figData.axonCrossFitLengths{i}{j}(k,:);


                                n = n+1;
                                if mod(n,10) == 0
                                    subplot(1,2,1);
                                    hold on
                                    text(points(1)+5,points(2)+5,num2str(k));
                                    plot(points(1),points(2),'or')
                                    subplot(1,2,2);
                                    hold on
                                    text(points(1)+5,points(2)+5,num2str(trueIdx));
                                    plot(points(1),points(2),'ok')
                                end
                            end
                        end

                        pause;
                        close;

                        figData.axonCrossFitAng{i}{j} = fitAng;
                        figData.axonCrossFitPoints{i}{j} = fitPoints;
                        figData.axonCrossFitCutPoints{i}{j} = fitCutPoints;
                        figData.axonCrossFitLengths{i}{j} = fitLengths;

                        %extract legitimate cross lengths
                        fittedLengthsNanless = fitLengths(~isnan(fitLengths));
                        fittedLengthsIdx = find(~isnan(fitLengths));

                        %perform median filter
                        medFiltN = 7;
                        fittedFilteredProfile = medfilt1(fittedLengthsNanless,medFiltN);

                        %interpolate median filtered widths to full axon length
                        if length(fittedLengthsNanless)>1
                            fittedFilteredProfileInterp = interp1(fittedLengthsIdx, fittedFilteredProfile, 1:length(figData.axonTraceSnapSkipped{i}{j}(:,1)));
                            fittedFilteredProfileInterp(1:min(fittedLengthsIdx)) = fittedFilteredProfile(1);
                            fittedFilteredProfileInterp(max(fittedLengthsIdx):end) = fittedFilteredProfile(end);

                            figData.axonCrossFitFilteredProfile{i}{j} = fittedFilteredProfileInterp;
                        else
                            figData.axonCrossFitFilteredProfile{i}{j} = nan(size(figData.axonCrossFitFilteredProfile{i}{j}));
                        end
                        

                    end
                end
        end
    end

    filename = strrep(figData.mouseFileName,'.mat','');
    t = datetime('now','TimeZone','local');
    ts = datestr(t,'yymmdd_hhMMss',2000);
    save(['boutonfinalsave_' filename '_' ts '.mat'],'figData','outData','-v7.3');
end

function [trueIdx,points] = findIdx(i,j,k,figData)
    points = figData.axonCrossFitCutPoints{i}{j}(k,:);
    axonTrace = figData.axonTraceSnapSkipped{i}{j};
    points = [mean([points(1),points(3)]), mean([points(2),points(4)])];
    centDiff = sqrt((axonTrace(:,1) - points(1)) .^2 + (axonTrace(:,2) - points(2)).^2);
    [~,ind] = min(centDiff);
    trueIdx = min(ind);
end