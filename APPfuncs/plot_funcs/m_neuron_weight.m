function m_neuron_weight(animal,DataPaths)
%% initialization
OFFLINE=1;
align_tags={'TRIALSTART','HITTARGET'};
colors=viridis(length(DataPaths));

f=figure;f.Color=[1,1,1];
drawnow

scts=[];
neg_firing=cell(1,length(DataPaths));
pos_firing=neg_firing;

for index=1:length(DataPaths)
    disp([num2str(index) ' started'])
    Data=load(DataPaths{index}).Data;
    positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
    negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
    others=[];
    units=[positives;negatives;others]
    
    position=Data.Behavior.Position;
    totaltime=Data.Meta.Nev.DataDurationSec;
    x=1:1:totaltime*1000-1;
    [timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
    timestamp_trialstart=timestamp_trialstart(grading);  timestamp_hittarget=timestamp_hittarget(grading); timestamp_baselinestart=timestamp_baselinestart(grading);
    if ~OFFLINE
        [mean_base_t,std_base_t]=load_base_new(Data);
        mean_base_t=mean_base_t(:,grading);
        std_base_t=std_base_t(:,grading);
    else
        [mean_base_t,std_base_t]=calc_base_offline(Data);
    end
    
    %% get spike data
    spikes=Data.UnitsOnline;
    index_p=find(spikes.SpikeNotes(:,1)==positives(1) & spikes.SpikeNotes(:,2)==positives(2));
    index_n=find(spikes.SpikeNotes(:,1)==negatives(1) & spikes.SpikeNotes(:,2)==negatives(2));
    if OFFLINE
        index_p=spikes.SpikeNotes(index_p,3);
        index_n=spikes.SpikeNotes(index_n,3);
        spikes=Data.UnitsOffline;
    end
    spikes_p=spikes.SpikeTimes{index_p};
    spikes_n=spikes.SpikeTimes{index_n};
    
    %% calc normalized firing rate
    for i=1:length(timestamp_hittarget)
        if std_base_t(1,i)>0 && std_base_t(2,i)>0
            if timestamp_hittarget(i)>0
                pos_firing{index}=[pos_firing{index} (sum(spikes_p>timestamp_trialstart(i) & spikes_p<timestamp_hittarget(i))/(timestamp_hittarget(i)-timestamp_trialstart(i))*1000-mean_base_t(1,i))/std_base_t(1,i)];
                neg_firing{index}=[neg_firing{index} (sum(spikes_n>timestamp_trialstart(i) & spikes_n<timestamp_hittarget(i))/(timestamp_hittarget(i)-timestamp_trialstart(i))*1000-mean_base_t(2,i))/std_base_t(2,i)];
            else
%                 pos_firing{index}=[pos_firing{index} (sum(spikes_p>timestamp_trialstart(i) & spikes_p<timestamp_trialstart(i)+20000)/20000*1000-mean_base_t(1,i))/std_base_t(1,i)];
%                 neg_firing{index}=[neg_firing{index} (sum(spikes_n>timestamp_trialstart(i) & spikes_n<timestamp_trialstart(i)+20000)/20000*1000-mean_base_t(2,i))/std_base_t(2,i)];
            end
        end
    end
    
    scts=[scts scatter(pos_firing{index},neg_firing{index},30/(length(DataPaths)^0.333),'o','MarkerFaceColor',colors(index,:),'MarkerFaceAlpha',1/(length(DataPaths)^0.333),'MarkerEdgeAlpha',0)];
    hold on
end


%% other plots
line([-7 7],[7 -7],'color','k')
line([-7 7],[0,0],'color','k')
line([0 0],[-7 7],'color','k')
t_color=viridis(20);
for i=1:20; line([4+i/10,4.2+i/10],[6.6,6.6],'color',t_color(i,:),'linewidth',5); end
text(4.1,6,"early",'HorizontalAlign','center','FontSize',8)
text(6.1,6,"late",'HorizontalAlign','center','FontSize',8)
text(6.1,5.6,"session",'HorizontalAlignment','center','FontSize',8)
text(4.1,5.6,"session",'HorizontalAlignment','center','FontSize',8)
text(5.5,-6.5,'max','HorizontalAlignment','center','FontSize',10)
text(-5.5,6.5,'min','HorizontalAlignment','center','FontSize',10)
set(gca,'box','on')
axis equal
set(gca,'XTick',get(gca,'YTick'))
xlim([-7 7])
ylim([-7 7])

xlabel('normalized firing rate of positive unit','FontSize',10)
ylabel('normalized firing rate of negative unit','FontSize',10)
tt=suptitle([ animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)]);
set(tt,'FontSize',12);

saveas(gcf,[pwd '\FIGS\m_neuron_weight\'  animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)])
%     pause(5)
%     close(gcf)
end

