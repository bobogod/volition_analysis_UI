function s_firing_trial(animal,session,Data)
%% initialize spike data
positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
OFFLINE=1
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


%% calc firing rate each trial
[timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
f=figure;f.Color='w';hold on
for i=1:length(timestamp_trialstart)
    if timestamp_hittarget(i)>0
        if ismember(i,grading)
            t=sum(spikes_p>timestamp_trialstart(i) & spikes_p<timestamp_hittarget(i));            
            scatter(i,t*1000/(timestamp_hittarget(i)-timestamp_trialstart(i)),'ro','filled')
            t=sum(spikes_n>timestamp_trialstart(i) & spikes_n<timestamp_hittarget(i));
            scatter(i,t*1000/(timestamp_hittarget(i)-timestamp_trialstart(i)),'bo','filled')
        else
            t=sum(spikes_p>timestamp_trialstart(i) & spikes_p<timestamp_hittarget(i));            
            scatter(i,t*1000/(timestamp_hittarget(i)-timestamp_trialstart(i)),'o','filled','MarkerEdgeColor',[0.6,0,0],'MarkerFaceColor',[0.6,0,0])
            t=sum(spikes_n>timestamp_trialstart(i) & spikes_n<timestamp_hittarget(i));
            scatter(i,t*1000/(timestamp_hittarget(i)-timestamp_trialstart(i)),'o','filled','MarkerEdgeColor',[0,0,0.6],'MarkerFaceColor',[0,0,0.6])
        end
    else
        if ismember(i,grading)
            t=sum(spikes_p>timestamp_trialstart(i) & spikes_p<timestamp_trialstart(i)+20000);
            scatter(i,t/20,'ro')
            t=sum(spikes_n>timestamp_trialstart(i) & spikes_n<timestamp_trialstart(i)+20000);
            scatter(i,t/20,'bo')
        else
            t=sum(spikes_p>timestamp_trialstart(i) & spikes_p<timestamp_trialstart(i)+20000);
            scatter(i,t/20,'o','MarkerEdgeColor',[1,0.3,0.3])
            t=sum(spikes_n>timestamp_trialstart(i) & spikes_n<timestamp_trialstart(i)+20000);
            scatter(i,t/20,'o','MarkerEdgeColor',[0.3,0.3,1])
        end
    end
end
t1=scatter(-1,-1,'ro','filled'); t2=scatter(-1,-1,'bo','filled'); t3=scatter(-1,-1,'ko'); t4=scatter(-1,-1,'ko','filled'); 
t5=scatter(-1,-1,'o','filled','MarkerEdgeAlpha',0,'MarkerFaceColor',[0.6,0,0.6]);
t6=scatter(-1,-1,'o','filled','MarkerEdgeAlpha',0,'MarkerFaceColor',[1,0,1]);
legend([t1,t2,t3,t4,t5,t6],{'positives unit','negatives unit','failure','success','warm up','final state'},'Orientation','horizontal','NumColumns',2,'Box','off')
xlabel('trial'); ylabel('firing rate during trial or first 20s in failed trials')
ylim([0 30])
% line([0.5,0.5]+grading,[0 30],'color','k')
title([animal '-' session])

savefig(f,[pwd '\FIGS\s_firing_trial\' animal '-' session])
pause(2)
close(f)
end

