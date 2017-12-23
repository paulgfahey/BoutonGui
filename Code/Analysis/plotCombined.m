figure;

ints = combinedStruct.boutonInt(:,3,:);
ints = reshape(ints,[size(ints,1),3]);

widths = combinedStruct.boutonWidth(:,3,:);
widths = reshape(widths,[size(widths,1),3]);

present = ints>2 & widths>3;
present = double(present);
present(isnan(ints)) = nan;
present(isnan(widths)) = nan;

formed = diff(present,1,2)<0;
eliminated = diff(present,1,2)>0;

formedFilter = [formed(:,1);formed(:,2)];
eliminatedFilter = [eliminated(:,1); eliminated(:,2)];
intSeg = [ints(:,1:2); ints(:,2:3)];
widthSeg = [widths(:,1:2); widths(:,2:3)];


subplot(2,2,1);
hold on

for i = 1:size(intSeg,1)
    if formedFilter(i) == 1
        plot(intSeg(i,:),widthSeg(i,:),'.-b')
    elseif eliminatedFilter(i) == 1
        plot(intSeg(i,:), widthSeg(i,:),'.-r')
    else
        plot(intSeg(i,:), widthSeg(i,:), '.-k')
    end
end

figure;

subplot(1,2,1);
hold on;

diffInts = diff(ints,1,2);
diffWidths = diff(widths,1,2);

for i = 1:size(diffInts,1)
    for j = 1:2
        if formed(i,j) == 1
            plot(j, diffInts(i,j),'.b')
        elseif eliminated(i,j) == 1
            plot(j, diffInts(i,j),'.r')
        else
            plot(j, diffInts(i,j),'.k')
        end
    end
end
xlim([0,3]);

subplot(1,2,2);
hold on;
for i = 1:size(diffWidths,1)
    for j = 1:2
        if formed(i,j) == 1
            plot(j, diffWidths(i,j),'.b')
        elseif eliminated(i,j) == 1
            plot(j, diffWidths(i,j),'.r')
        else
            plot(j, diffWidths(i,j),'.k')
        end
    end
end
xlim([0,3]);


