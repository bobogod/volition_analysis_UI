function m_drink_time(animal,DataPaths)
valve_time_feedback=[];
valve_time_nofeedback=[];
for index=1:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    [timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
    timestamp_hittarget=timestamp_hittarget(grading); 
    timestamp_valveon=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==7);
    
    for i=1:length(timestamp_hittarget)
        if timestamp_hittarget(i)>0
            t=find(timestamp_valveon>timestamp_hittarget(i));
            if ~isempty(t)
                t=t(1);
                if t-timestamp_hittarget(i)<5000
                    if contains(DataPaths{index},'nofeedback')
                        valve_time_nofeedback=[valve_time_nofeedback timestamp_valveon(t)-timestamp_hittarget(i)];
                    else
                        valve_time_feedback=[valve_time_feedback timestamp_valveon(t)-timestamp_hittarget(i)];
                    end
                end
            end
        end
    end
end
f=figure; f.Color='w'; hold on
scatter(0*valve_time_feedback+1,valve_time_feedback,5,'ko','filled')
scatter(0*valve_time_nofeedback+2,valve_time_nofeedback,5,'ko','filled')
violin({valve_time_feedback,valve_time_nofeedback},'xlabel',{'feedback','no feedback'},'mc',[],'medc','k','facealpha',0,'edgecolor','k')
% plot([0.8 1.2],[1,1]*median(valve_time_feedback),'g-','linewidth',2)
% plot([1.8 2.2],[1,1]*median(valve_time_nofeedback),'g-','linewidth',2)
% xlim([0,3])
ylim([0,5000])
% xticklabels({'','','feedback','','no feedback','',''})
ylabel('movement time, ms')
ax=gca(); ax.Box=0;
[p,h]=ranksum(valve_time_feedback,valve_time_nofeedback);
text(0.5,4000,['p=' num2str(p)])
end

