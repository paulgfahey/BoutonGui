function hfig = boutonQCCompletionCheck(hfig)
    figData = guidata(hfig);
    figData.axonCount = zeros(figData.numStacks,25);
    figData.boutonCount = zeros(25,100);
    figData.boutonPartialCount = zeros(25,100,figData.numStacks);
   for i = 1:figData.numStacks
        for j = 1:25
            figData.axonCount(i,j) = ~isempty(figData.axonTrace{i}{j});  %creates i x j table of axon trace presence
            cbc = figData.boutonCenter{i}{j};
            cbs = figData.boutonStatus{i}{j};
            cbcr = figData.boutonCross{i}{j};
            
            kmax = max([size(cbc,1),size(cbs,1)]);
            cbcdiff = diff([size(cbc,1);kmax]);
            if cbcdiff > 0
                cbc = [cbc;nan(cbcdiff,size(cbc,2))];
                figData.boutonCenter{i}{j} = cbc;
            end
            
            cbsdiff = diff([size(cbs,1);kmax]);
            if cbsdiff>0
                cbs = [cbs;nan(cbsdiff,size(cbs,2))];
                figData.boutonStatus{i}{j} = cbs;
            end
            
            for k = 1:kmax
                complete = ~any([k>size(cbc,1), any(isnan(cbc(k,:))), k>size(cbs,1), any(isnan(cbs(k,:))), isempty(cbcr{k})]);
                incomplete = ~complete & any([~any(isnan(cbc(k,:))), ~k>size(cbs,1), ~any(isnan(cbs(k,:))), ~isempty(cbcr{k})]);
                figData.boutonCount(j,k,i) = complete;  %creates j x k x i table of bouton analysis completion
                figData.boutonPartialCount(j,k,i) = incomplete;
            end
        end
    end
    [~,b] = find(figData.axonCount);
    figData.maxAxon = max(b);  %finds how many axons are in the stack with the most axons
    
    figData.maxBouton = zeros(figData.numStacks,25);
    for i = 1:figData.numStacks
        for j = 1:25
            findMaxPartial = find(figData.boutonPartialCount(j,:,i),1,'last');
            findMaxComplete = find(figData.boutonCount(j,:,i),1,'last');
            findMax = max([findMaxPartial,findMaxComplete]);
            if ~isempty(findMax)
                figData.maxBouton(i,j) = findMax;
            end
        end
    end
    figData.maxBouton = max(figData.maxBouton,[],1);  %finds the maximum number of boutons for each axon
    
    for i = 1:figData.numStacks
        for j = 1:25
            cbc = figData.boutonCenter{i}{j};
            
            cbcdiff = diff([size(cbc,1);figData.maxBouton(j)]);
            if cbcdiff>0
                cbc = [cbc;nan(cbcdiff,size(cbc,2))];
                figData.boutonCenter{i}{j} = cbc;
            end
            
            cbs = figData.boutonStatus{i}{j};
            
            cbsdiff = diff([size(cbs,1);figData.maxBouton(j)]);
            if cbsdiff>0
                cbs = [cbs;nan(cbsdiff,size(cbs,2))];
                figData.boutonStatus{i}{j} = cbs;
            end
        end
    end

    x = 1;
    for j = 1:figData.maxAxon
        for i = 1:figData.numStacks
            stack{x} = num2str(i); 
            if figData.axonCount(i,j)
                axon{x} = num2str(j); 
            else
                axon{x} = num2str(0); 
            end
            bouton{x} = strrep(strcat(num2str(figData.boutonCount(j,1:figData.maxBouton(j),i))),' ',''); 
            x = x+1;
        end
    end
    
    guidata(hfig,figData);


end
