function m_success_rate_all(animal,DataPaths)
dates={};
sts=[];
success_rate=[];
change_unit=[];
prev_pos=[0,0]; prev_neg=[0,0];
for i=1:length(DataPaths)
    sprintf("%.1f%%",i/length(DataPaths)*100)
    t=load(DataPaths{i}).Data;  
    if DataPaths{i}(end-16)=='4'
        sts=[sts 4];
        [timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(t);
        timestamp_trialstart=timestamp_trialstart(grading);  timestamp_hittarget=timestamp_hittarget(grading); timestamp_baselinestart=timestamp_baselinestart(grading);
        if isempty(timestamp_hittarget)
            success_rate=[success_rate 0];
        else
            success_rate=[success_rate sum(timestamp_hittarget>0)/length(timestamp_hittarget)];
        end
    else
        sts=[sts 3];
        [timestamp_trialstart,timestamp_hittarget,timestamp_portready,timestamp_portback] = get_timestamps_st3(t);
        success_rate=[success_rate 1];
    end
    if length(t.Meta.Rule.Channels)==2
        pos=[t.Meta.Rule.Channels(1) t.Meta.Rule.Units(1)];
        neg=[t.Meta.Rule.Channels(2) t.Meta.Rule.Units(2)];
    else
        pos=[t.Meta.Rule.Channels(2) t.Meta.Rule.Units(2)-2];
        neg=[t.Meta.Rule.Channels(6) t.Meta.Rule.Units(6)-2];
    end
    if ~(prev_pos(1)==pos(1) && prev_neg(1)==neg(1) && prev_pos(2)==pos(2) && prev_neg(2)==neg(2))
        if prev_pos(1)>0
        change_unit=[change_unit i-0.5];
        end
    end
    prev_pos=pos; prev_neg=neg;
    dates{end+1}=DataPaths{i}(end-23:end-20);    
end
f=figure;
f.Color=[1 1 1];
ax=axes();
hold(ax,'on');
% rectangle('Position',[0.5 0.05 3 0.9],'FaceColor',[1,0.9,0.9],'EdgeColor',[1,0.9,0.9]);
% rectangle('Position',[3.5 0.05 4 0.9],'FaceColor',[0.9,1,0.9],'EdgeColor',[0.9,1,0.9]);
% rectangle('Position',[7.5 0.05 6 0.9],'FaceColor',[0.85,1,0.85],'EdgeColor',[0.85,1,0.85]);
% rectangle('Position',[13.5 0.05 6 0.9],'FaceColor',[0.9,0.9,1],'EdgeColor',[0.9,0.9,1]);
plot(1:length(dates),success_rate,'k')
for i=1:length(dates)
    if sts(i)==3
        scatter(i,success_rate(i),'bo','filled')
    else
        scatter(i,success_rate(i),'ko','filled')
    end
end
set(gca,'XTick',1:length(dates))
set(gca,'XTickLabel',dates)
% text(1.5,0.2,{'+CH8U3';'-CH12U3'});
% text(5,0.2,{'+CH4U3';'-CH12U3'});
% text(10,0.2,{'+CH4U1';'-CH12U1'});
% text(16,0.2,{'+CH5U1';'-CH12U1'});
% scatter([2 9 15],success_rate([2 9 15]),'ok')
ylabel('success rate')
set(gca,'XTickLabelRotation',45)
switch_unit=scatter(gca,change_unit,0.96*ones(1,length(change_unit)),'kv','filled');

% 
% line(gca,[6.5,6.5],[0,1],'color','k','linestyle','--')
% line(gca,[14.5,14.5],[0,1],'color','k','linestyle','--')
% line(gca,[15.5,15.5],[0,1],'color','k','linestyle','--')
% line(gca,[18.5,18.5],[0,1],'color','k','linestyle','--')
% scatter(gca,6.5,0.96,'kv','filled')
% scatter(gca,9.5,0.96,'kv','filled')
% scatter(gca,13.5,0.96,'kv','filled')
% scatter(gca,15.5,0.96,'kv','filled')
% switch_unit=scatter(gca,22.5,0.96,'kv','filled');
% legend(switch_unit,'change unit','box','off')
% text(13,0.65,["no load cell";"max"],'FontSize',12)
% text(16,0.65,["load cell";"max"],'FontSize',12)
% text(19.2,0.65,["load cell";"min"],'FontSize',12)
% text(6,0.65,["load cell";"max"],'FontSize',12)
% text(11.3,0.65,'st3','FontSize',12,'Color','b')

legend(switch_unit,'change unit','box','off')

title([animal ' (warm up data removed)'],'FontSize',12)
savefig(f,[pwd '\FIGS\m_success_rate_all\' animal '-' dates{1} '-' dates{end}])
end

