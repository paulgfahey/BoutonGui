function BoutonGui(~) 
%GUI FOR ENTERING AXON TRACES AND BOUTON TRACES FOR INTENSITY
%MEASUREMENT AND TURNOVER
    
    %open new figure, assign figData (used to hold all user-defined data)
    hfig=figure('Visible','on','Color',[.9 .8 .7]);
    figData = guidata(hfig);
    colormap('gray')
    
    %Enter new mouse file name, or enter load to select previous file
    figData.mouseFileName = input('Mouse File Name  (or "load")    ','s');
    while isempty(figData.mouseFileName)
        disp('invalid mouse file name');
        figData.mouseFileName = input('Mouse File Name   ','s');
    end
    
    if strcmp(figData.mouseFileName,'load')  
        [filename,path] = uigetfile;
        loadFile = uiimport(fullfile(path,filename));
        figData = loadFile.figData;
        guidata(hfig,figData)
    else
       guidata(hfig,figData) 
       figData = newFigParam(hfig);  %instantiates new file with all relevant figData parameters
       guidata(hfig,figData)
    end


    set(hfig,'WindowButtonDownFcn',{@axonClick});   %opens in axon mode
    set(hfig,'Name','Click to trace axon','NumberTitle','off')
    set(hfig,'WindowScrollWheelFcn',{@mouseWheel,figData.stackDataShuffled{figData.cs}});
    set(hfig,'KeyPressFcn',{@keyPress,figData.stackDataShuffled{figData.cs}});

    guidata(hfig,figData);
    fullReplot(hfig);
end

function mouseWheel(hfig,events,~)
figData = guidata(hfig);
    [cs,~,~,~,~] = currentOut(hfig);
    buttonPressed = get(hfig,'CurrentCharacter');
    % PRESS 1 TO ZOOM WITH MOUSE SCROLL WHEEL
    if strcmp(buttonPressed,'1')
        if events.VerticalScrollCount < 0 & figData.range{cs}(2) > figData.zoomFactor{cs}
            figData.range{cs} = figData.range{cs} - figData.zoomFactor{cs};
        end
        if events.VerticalScrollCount > 0
            figData.range{cs} = figData.range{cs} + figData.zoomFactor{cs};
        end
    % PRESS 2 TO CHANGE THRESHOLD SENSITIVITY WITH MOUSE SCROLL WHEEL
    elseif strcmp(buttonPressed,'2')
        if figData.thresh > 0.001 && events.VerticalScrollCount < 0
            figData.thresh = figData.thresh * .9;
        end
        if figData.thresh * 1.1 < 1 && events.VerticalScrollCount > 0
            figData.thresh = figData.thresh * 1.1;
        end
    % PRESS 3 TO SCROLL VERTICALLY WITH MOUSE SCROLL WHEEL
    elseif strcmp(buttonPressed,'3')
        moveBin = figData.range{cs}(1,1)*.1;
        if events.VerticalScrollCount<0
            figData.centers{cs}(1,2) = figData.centers{cs}(1,2) - moveBin;
        end
        if events.VerticalScrollCount>0
            figData.centers{cs}(1,2) = figData.centers{cs}(1,2) + moveBin;
        end
    % PRESS 4 TO SCROLL HORIZONTALLY WITH MOUSE SCROLL WHEEL
    elseif strcmp(buttonPressed,'4')
        moveBin = figData.range{cs}(1,1)*.1;
        if events.VerticalScrollCount<0
            figData.centers{cs}(1,1) = figData.centers{cs}(1,1) + moveBin;
        end
        if events.VerticalScrollCount>0
            figData.centers{cs}(1,1) = figData.centers{cs}(1,1) - moveBin;
        end
    %PRESS 6 TO SCROLL THROUGH TIMEPOINTS WITH MOUSE SCROLL WHEEL
    elseif strcmp(buttonPressed,'6')
        if events.VerticalScrollCount<0 && figData.cs > 1
            figData.cs = figData.cs - 1;
        end
        if events.VerticalScrollCount>0 && figData.cs < figData.numStacks
            figData.cs = figData.cs + 1;
        end
    %DEFAULTS TO SCROLL WHEEL CHANGING Z PLANE
    else
        if figData.currentZ{cs} > 1 && events.VerticalScrollCount < 0
            figData.currentZ{cs} = figData.currentZ{cs}-1;
        elseif figData.currentZ{cs} < size(figData.stackDataShuffled{cs},3) && events.VerticalScrollCount > 0
            figData.currentZ{cs} = figData.currentZ{cs} + 1;
        end
    end
    
    guidata(hfig,figData)   
    fullReplot(hfig);
end

function keyPress(hfig,events,~)  
    %callback function for key press
    figData = guidata(hfig);
    [cs,ca,cb,~,~] = currentOut(hfig);
    
    % ARROW KEYS TRANSLATE
    moveBin=figData.range{cs}(1,1)*.1;             %size of center adjustment per arrow keypress
    if strcmp(events.Key,'leftarrow') 
        figData.centers{cs}(1,1) = figData.centers{cs}(1,1)-moveBin;
    end
    
    if strcmp(events.Key,'rightarrow')
        figData.centers{cs}(1,1) = figData.centers{cs}(1,1)+moveBin;
    end
    
    if strcmp(events.Key,'uparrow')
        figData.centers{cs}(1,2) = figData.centers{cs}(1,2)-moveBin;
    end
    
    if strcmp(events.Key,'downarrow')
        figData.centers{cs}(1,2) = figData.centers{cs}(1,2)+moveBin;
    end    
    
    % +/- ZOOM
    if strcmp(events.Key,'equal')                      %ZOOM IN
        figData.range{cs} = figData.range{cs} + figData.zoomFactor{cs};
    end
    
    if strcmp(events.Key,'hyphen')                     %ZOOM OUT
        figData.range{cs} = figData.range{cs} - figData.zoomFactor{cs};
    end
    
    %CHANGE BOUTON STATUS MATRIX Q/W/E/R
     if any(strcmp(events.Key,{'q','w','e','r'}))
        figData.boutonStatusMatrix = strcmp(events.Key,{'q','w','e','r'});
        figData.boutonStatus{cs}{ca}(cb,:) = figData.boutonStatusMatrix;
        figData.boutonString = figData.boutonClasses{find(figData.boutonStatusMatrix)}; %#ok<*FNDSB>
     end
     
    %ADJUST ASSISTED BOUTON BOUNDARY THRESHOLD WITH l/;
    if strcmp(events.Key,'l') && figData.thresh > 0.001
        figData.thresh = figData.thresh * .9;
    end
    
    if strcmp(events.Key,'semicolon') && (figData.thresh * 1.1) < 1
        figData.thresh = figData.thresh * 1.1;
    end
    
    %DECREASE/INCREASE MAX INPUT/OUTPUT BRIGHTNESS o/p 9/0, RESPECTIVELY
    if strcmp(events.Key,'9') && figData.high_out{cs}>0
        figData.high_out{cs}=figData.high_out{cs}*.9;
        figData.high_out{cs}(figData.high_out{cs} < 0) = 0;        
    end
    
    if strcmp(events.Key,'0') && figData.high_out{cs}<1
        figData.high_out{cs} = figData.high_out{cs}*1.1;
        figData.high_out{cs}(figData.high_out{cs} > 1) = 1;
    end
    
    if strcmp(events.Key,'o') && figData.high_in{cs}>0
        figData.high_in{cs} = figData.high_in{cs}*.9;
        figData.high_in{cs}(figData.high_in{cs} < 0) = 0;
    end
    
    if strcmp(events.Key,'p') && figData.high_in{cs}<1
        figData.high_in{cs} = figData.high_in{cs}*1.1;
        figData.high_in{cs}(figData.high_in{cs} > 1) = 1;
    end
    
    %MOVE UP OR DOWN IN SHUFFSTACK m/,
    if strcmp(events.Key,'m') && cs < figData.numStacks
        figData.cs = cs+1;
        guidata(hfig,figData);
        [cs,ca,cb,~,~] = currentOut(hfig);
    end
    
    if strcmp(events.Key,'comma') && cs > 1
        figData.cs = cs-1;
        guidata(hfig,figData);
        [cs,ca,cb,~,~] = currentOut(hfig);
    end
    
    %ADVANCE OR RETURN TO BOUTON ON CURRENT AXON BY PRESSING u/i
    if strcmp(events.Key,'u') && cb >1
        cb = cb -1;
    end
    
    if strcmp(events.Key,'i')
        cb = cb +1;
    end
    
    %ADVANCE OR RETURN TO AXON BY PRESSING j/k
    if strcmp(events.Key,'j') && ca>1
        ca = ca - 1;
        cb = size(figData.boutonCenter{cs}{ca},1)+1;        
    end
    
    if strcmp(events.Key,'k')
        ca = ca + 1;
        cb = size(figData.boutonCenter{cs}{ca},1)+1;        
    end
    
    %SNAP BACKBONE 'C'
    if strcmp(events.Key,'c')
        [hfig,figData] = snapToBackbone(hfig,figData.axonTrace{cs}{ca});
        guidata(hfig,figData);
        disp('Trace Snapped');
    end
    
    %REPLOT
    figData.cs = cs;
    figData.currAxon{cs} = ca;
    figData.currBouton{cs}{ca} = cb;
    guidata(hfig,figData);
    if any(strcmp(events.Key,{'leftarrow','rightarrow','uparrow','downarrow','equal','hyphen','9','0','o','p','m','comma','q','w','e','r','u','i','j','k','c'}))
        fullReplot(hfig);
    end
    
    %CLEAR OVERLAY BY PRESSING 'SPACE'
    if strcmp(events.Key,'space')
        figData.overlay = ~figData.overlay;
        guidata(hfig,figData)
        fullReplot(hfig);
    end
    
    %ENTER AXON TRACING MODE 'A'
    if strcmp(events.Key,'a')
        set(hfig,'Name','Click to trace axon','NumberTitle','off')
        set(hfig,'WindowButtonDownFcn',{@axonClick});
        set(hfig,'WindowButtonMotionFcn','');
    end
    
    %ENTER AXON SKIPPING MODE 'S'
    if strcmp(events.Key,'s')
        set(hfig,'Name','Click to trace skipped axon','NumberTitle','off')
        set(hfig,'WindowButtonDownFcn',{@axonSkipClick});
        set(hfig,'WindowButtonMotionFcn','');
    end
    
    %ENTER BOUTON STATUS/BOUNDARY MODE 'D'
    if strcmp(events.Key,'d')
        set(hfig,'Name','Click to Add boutons','NumberTitle','off')
        set(hfig,'WindowButtonDownFcn',{@boutonClick});
        set(hfig,'WindowButtonMotionFcn',@maskMotion);
    end
    
    %ENTER BOUTON/AXON CROSS TRACE MODE 'F'
    if strcmp(events.Key,'f')
        set(hfig,'Name','Click to trace across a bouton ','NumberTitle','off')
        set(hfig,'WindowButtonDownFcn',@boutonCrossClick);
        set(hfig,'WindowButtonMotionFcn','');
    end
    
    %ENTER AXON BOUNDARY MODE 'V'
    if strcmp(events.Key,'v')
        set(hfig,'Name','Click to create axon region','NumberTitle','off')
        set(hfig,'WindowButtonDownFcn',@axonRegionClick);
        set(hfig,'WindowButtonMotionFcn',@maskMotion);
    end
    
    %ENTER BACKGROUND ROI MODE 'B'
    if strcmp(events.Key,'b')
        set(hfig,'Name','Click to outline background ROI','NumberTitle','off')
        set(hfig, 'WindowButtonDownFcn',@backgroundClick);
        set(hfig, 'WindowButtonMotionFcn',@backgroundCursorMotion);
    end
    
    % QUICK SAVE DATA BY PRESSING 'X'
    if strcmp(events.Key,'x')
        tic
        disp('Quick Saving...')
        t = datetime('now','TimeZone','local');
        ts = datestr(t,'yymmdd_hhMMss',2000);
        save(['boutonautosave_' figData.mouseFileName '_' ts '.mat'],'figData','-v7.3');
        disp('Quick Save Complete');
        toc
    end
     
    % FINAL SAVE DATA BY PRESSING 'Z'
    if strcmp(events.Key,'z')
        tic
        disp('Full Saving...')
        fullSave2(hfig)
        toc
    end
    
    
    %CLEAR AXON BY PRESSING 'F1'
    if strcmp(events.Key,'f1') 
        clearAxon(hfig);
        figData = guidata(hfig);
    end
    
    %CLEAR BOUTON BY PRESSING 'F2'
    if strcmp(events.Key,'f2')
        clearBouton(hfig);      
        figData = guidata(hfig);
    end
    
    
    
    figData.cs = cs;
    figData.currAxon{cs} = ca;
    figData.currBouton{cs}{ca} = cb;
    guidata(hfig,figData) %Save figure data
end


