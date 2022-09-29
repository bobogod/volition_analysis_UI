function m_behavior_DCZ_st3(animal,DataPaths)

    function [dataout,indrmv] = rmoutliers_custome(datain); %From YJN
        [data2575] = prctile(datain, [25, 75]);
        interq = data2575(2) - data2575(1);
        c=2;
        indrmv = find(datain>data2575(2)+interq*c | datain<data2575(1)-interq*c);
        dataout = datain;
        dataout(indrmv) = [];
    end

%% load data
behavior=struct();
behavior_DCZ=struct();

for index=1:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    isDCZ=length(strfind(DataPaths{index},'DCZ'));
    if isDCZ
        behavior_DCZ(end+1).load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10);
        behavior_DCZ(end).load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9);
        behavior_DCZ(end).timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3);
        behavior_DCZ(end).timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4);
    else
        behavior(end+1).load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10);
        behavior(end).load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9);
        behavior(end).timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3);
        behavior(end).timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4);
    end
end

behavior=behavior(2:end);
behavior_DCZ=behavior_DCZ(2:end);

%% before DCZ
hist_onset=zeros(1,30); %0-29
datains=[];
for index=1:length(behavior)
    
    for i=1:length(behavior(index).timestamp_hittarget)
        t=sum(behavior(index).load_cell_onset>behavior(index).timestamp_trialstart(i) & ...
            behavior(index).load_cell_onset<behavior(index).timestamp_hittarget(i));
        hist_onset(t+1)=hist_onset(t+1)+1;
    end
    
    datains=[datains;(behavior(index).timestamp_hittarget-behavior(index).timestamp_trialstart)/1000];
end
[dataout,indrmv]=rmoutliers_custome(datains);
[pdf,~]=ksdensity(dataout,0:0.05:30,'Function','pdf','Bandwidth',0.5);
[cdf,~]=ksdensity(dataout,0:0.05:30,'Function','cdf','Bandwidth',0.5);
pdf(pdf<0)=0;

%% DCZ
hist_onset_DCZ=zeros(1,30); %0-29
datains_DCZ=[];
for index=1:length(behavior_DCZ)
    
    for i=1:length(behavior_DCZ(index).timestamp_hittarget)
        t=sum(behavior_DCZ(index).load_cell_onset>behavior_DCZ(index).timestamp_trialstart(i) & ...
            behavior_DCZ(index).load_cell_onset<behavior_DCZ(index).timestamp_hittarget(i));
        hist_onset_DCZ(t+1)=hist_onset_DCZ(t+1)+1;
    end
    datains_DCZ=[datains_DCZ;(behavior_DCZ(index).timestamp_hittarget-behavior_DCZ(index).timestamp_trialstart)/1000];

end
[dataout,indrmv]=rmoutliers_custome(datains_DCZ);
[pdf_DCZ,~]=ksdensity(dataout,0:0.05:30,'Function','pdf','Bandwidth',0.5);
[cdf_DCZ,~]=ksdensity(dataout,0:0.05:30,'Function','cdf','Bandwidth',0.5);
pdf_DCZ(pdf_DCZ<0)=0;

f=figure('Units','inches','Position',[1,1,7.3,3],'Color',[1,1,1]);

axes('Position',[0.07,0.2,0.25,0.6])
% h=hist(hist_onset(hist_onset<30),40)
bar(0:29,hist_onset/sum(hist_onset),'EdgeAlpha',0,'FaceColor','k','FaceAlpha',0.6)
hold on
bar(0:29,hist_onset_DCZ/sum(hist_onset_DCZ),'EdgeAlpha',0,'FaceColor',[0.8510,0.3765,0.1569],'FaceAlpha',0.6)
xlabel('Number of load cell onset')
ylabel('Percentage of Trials')
set(gca,'box',0)

axes('Position',[0.38,0.2,0.25,0.6])
plot(0:0.05:30,pdf,'LineWidth',1,'Color',[0.2,0.2,0.2])
hold on
plot(0:0.05:30,pdf_DCZ,'LineWidth',1,'Color',[0.8510,0.3765,0.1569])
ylabel('PDF')
xlabel('T_{hit target} - T_{trial start}')
ylim([0 0.5])
yticklabels({'0','','','','','0.5'})
set(gca,'box',0)

axes('Position',[0.69,0.2,0.25,0.6])
plot(0:0.05:30,cdf,'LineWidth',1,'Color',[0.2,0.2,0.2])
hold on
plot(0:0.05:30,cdf_DCZ,'LineWidth',1,'Color',[0.8510,0.3765,0.1569])
ylabel('CDF')
xlabel('T_{hit target} - T_{trial start}')
ylim([0 1])
yticklabels({'0','','','','','1'})
set(gca,'box',0)
legend({'before DCZ','after DCZ'},'Box',0,'Location','best')




if DataPaths{1}(end-20)=='Z'
    t1=DataPaths{1}(end-26:end-20);
else
    t1=DataPaths{1}(end-23:end-20);
end
if DataPaths{end}(end-20)=='Z'
    t2=DataPaths{end}(end-26:end-20);
else
    t2=DataPaths{end}(end-23:end-20);
end

st=suptitle([animal '-' t1 '-' t2]);
set(st,'fontsize',12)

saveas(gcf,[pwd '\FIGS\m_behavior_DCZ_st3\'  animal '-' t1 '-' t2])
saveas(gcf,[pwd '\FIGS\m_behavior_DCZ_st3\'  animal '-' t1 '-' t2 '.png'])
% % pause(5)
% % close(gcf)
% save([pwd '\FIGS\m_psth_st3\'  animal '-' t1 '-' t2 '.mat'],'bootci_input','psth_data');
end

