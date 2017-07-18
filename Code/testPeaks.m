figData = guidata(gcf);
test = figData.axonBrightnessProfile{1}{1};
test1 = figData.axonBrightnessPeaks{1}{1};
test2 = figData.axonMedianBrightness{1}{1};

figure
subplot(3,1,1)
title('raw')
hold on
plot(test(:,4)/test2);
% scatter(test1(:,4),test1(:,5)/test2);
axis([0,800,-2,10]);
hold off

subplot(3,1,2)
title('linear (detrend fxn)')
hold on
test4 = detrend(test(:,4));
test4 = test4 + abs(min(test4));
test4 = test4/median(test4);
plot(test4);
axis([0,800,-2,10]);
hold off

subplot(3,1,3)
hold on
title('polynomial fit')
x = 1:size(test(:,4),1);
opol = 6;
[p,s,mu] = polyfit(x,test(:,4)',opol);
f_y = polyval(p,x,[],mu);
test4 = test(:,4)' - f_y;
test4 = test4 + abs(min(test4));
test4 = test4 / median(test4);
plot(test4);
axis([0,800,-2,10]);
hold off




% for n = 1:6
%     figure;
%     for wn = .1:.1:.9
%         [b,a] = butter(n,wn,'high');
%         test3 = filter(b,a,test(:,4));
%         subplot(3,3,wn/.1);
%         plot(test3/test2);
%         
%     end
%     
% % 
% % end
% x = 1:size(test(:,4),1);
% figure
% 
% for opol = 1:6
%     [p,s,mu] = polyfit(x,test(:,4)',opol);
%     f_y = polyval(p,x,[],mu);
%     test4 = test(:,4)' - f_y;
%     test4 = test4 + abs(min(test4));
%     test4 = test4 / median(test4);
% %     test4 = test4/median(test4);
%     subplot(3,2,opol)
%     plot(test4);
%     axis([0,800,-2,10]);
% end