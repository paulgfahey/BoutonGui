f = figure;
set(f,'position',[0 0 300 720]);

uicontrol('style','pushbutton','string','Insert New Mouse','fontunits','normalized','fontsize',.2,'position',[25 625 250 70],'Callback',@BoutonGUI.GUIs.InsertNewMouse);

