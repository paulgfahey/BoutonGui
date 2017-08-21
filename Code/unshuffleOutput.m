function outData = unshuffleOutput(hfig)
    figData = guidata(hfig);

    outData.axonLengths = nan(figData.maxAxon,figData.numStacks);

    for j = 1:figData.maxAxon
        outData.boutonPresence{j} = nan(figData.maxBouton(j),figData.numStacks);
        outData.exclude{j} = nan(figData.maxBouton(j),figData.numStacks);
        outData.boutonInt{j} = nan(figData.maxBouton(j),3,figData.numStacks);
        outData.boutonWidth{j} = nan(figData.maxBouton(j),3,figData.numStacks);

        for m = 1:figData.numStacks
            i = figData.stackKey(m);

            outData.axonLengths(j,i) = figData.axonIncludedTraceLength{i}{j};
            
            outData.boutonPresence{j}(1:size(figData.boutonStatus{m}{j},1),i) = any(figData.boutonStatus{m}{j}(:,1:2),2);
            excluded = figData.boutonStatus{m}{j}(:,3);
            excluded(isnan(excluded)) = 1;
            outData.exclude{j}(1:size(figData.boutonStatus{m}{j},1),i) = excluded;
            

            
            for k = 1:figData.maxBouton(j)
                if ~outData.exclude{j}(k,i) %&& all(figData.boutonCount(j,k,:))
                    disp([i,j,k]);
                    indx = figData.boutonCenter{m}{j}(k,4);
                    
                    outData.boutonInt{j}(k,1,i) = figData.axonBrightnessProfile{m}{j}(indx,4);
                    outData.boutonInt{j}(k,2,i) = figData.axonBrightnessProfileBaseline{m}{j}(indx,4);
                    outData.boutonInt{j}(k,3,i) = figData.axonBrightnessProfileWeighted{m}{j}(indx,4);

                    outData.boutonWidth{j}(k,1,i) = figData.boutonWidth{m}{j}{k};
                    outData.boutonWidth{j}(k,2,i) = nanmean(figData.localAxonWidth{m}{j}{k});
                    outData.boutonWidth{j}(k,3,i) = outData.boutonWidth{j}(k,1,i) - outData.boutonWidth{j}(k,2,i);
                else
                    outData.boutonInt{j}(k,:,i) = nan(1,3,1);
                    outData.boutonWidth{j}(k,:,i) = nan(1,3,1);
                end
            end
        end
        
        outData.boutonPresence{j}(logical(outData.exclude{j})) = nan;
        
        presence = outData.boutonPresence{j};
        
        outData.boutonPersist{j} = presence(:,[1,2,1]) == 1 & presence(:,[2,3,3]) == 1;
        outData.boutonForm{j} = presence(:,[1,2,1]) == 0 & presence(:,[2,3,3]) == 1;
        outData.boutonElim{j}  = presence(:,[1,2,1]) == 1 & presence(:,[2,3,3]) == 0;

        
    end
    
    guidata(hfig,figData);
    
end
