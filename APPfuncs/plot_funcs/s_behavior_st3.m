function s_behavior_st3(animal,session,Data)

    function [dataout,indrmv] = rmoutliers_custome(datain); %From YJN
        [data2575] = prctile(datain, [25, 75]);
        interq = data2575(2) - data2575(1);
        c=3;
        indrmv = find(datain>data2575(2)+interq*c | datain<data2575(1)-interq*c);
        dataout = datain;
        dataout(indrmv) = [];
    end
%% initialization

f=figure('Units','inches','Position',[1,1,7.3,3],'Color',[1,1,1]);

load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10);
load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9);
timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3);
timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4);

hist_onset=zeros(1,30); %0-29
for i=1:length(timestamp_hittarget)
    t=sum(load_cell_onset>timestamp_trialstart(i) & load_cell_onset<timestamp_hittarget(i))
    hist_onset(t+1)=hist_onset(t+1)+1;
end
axes('Position',[0.07,0.2,0.25,0.6])
% h=hist(hist_onset(hist_onset<30),40)
bar(0:29,hist_onset,'EdgeAlpha',0,'FaceColor',[0.2,0.2,0.2])
xlabel('Number of load cell onset')
ylabel('Trials')
set(gca,'box',0)


[dataout,indrmv]=rmoutliers_custome((timestamp_hittarget-timestamp_trialstart)/1000);

[pdf,x1]=ksdensity(dataout,0:0.1:30,'Function','pdf');
[cdf,x2]=ksdensity(dataout,0:0.1:30,'Function','cdf');

axes('Position',[0.38,0.2,0.25,0.6])
plot(x1,pdf,'LineWidth',1,'Color',[0.2,0.2,0.2])
ylabel('PDF')
xlabel('T_{hit target} - T_{trial start}')
ylim([0 0.5])
yticklabels({'0','','','','','0.5'})
set(gca,'box',0)

axes('Position',[0.69,0.2,0.25,0.6])
plot(x2,cdf,'LineWidth',1,'Color',[0.2,0.2,0.2])
ylabel('CDF')
xlabel('T_{hit target} - T_{trial start}')
yticklabels({'0','','','','','1'})
set(gca,'box',0)

st=suptitle([animal '-' session]);
set(st,'fontsize',12)
saveas(gcf,[pwd '\FIGS\s_behavior_st3\'  animal '-' session])
saveas(gcf,[pwd '\FIGS\s_behavior_st3\'  animal '-' session '.png'])
% % pause(5)
close(gcf)
% save([pwd '\FIGS\m_psth_st3\'  animal '-' t1 '-' t2 '.mat'],'bootci_input','psth_data');
end

