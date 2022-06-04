function m_firing_firing_single_tar(animal,DataPaths)
%% initialize
Data=load(DataPaths{1}).Data;
positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
others=[];
% for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
%     if Data.UnitsOnline.SpikeNotes(i,3)>0
%         if ~(Data.UnitsOnline.SpikeNotes(i,1)==positives(1) && Data.UnitsOnline.SpikeNotes(i,2)==positives(2))
%             if ~(Data.UnitsOnline.SpikeNotes(i,1)==negatives(1) && Data.UnitsOnline.SpikeNotes(i,2)==negatives(2))
%                 others=[others; Data.UnitsOnline.SpikeNotes(i,1:2)];
%             end
%         end
%     end
% end
% others_flag=ones(1,length(others(:,1)));
% for index=2:length(DataPaths)
%     Data=load(DataPaths{index}).Data;
%     for i=1:length(others_flag)
%         t=find(Data.UnitsOnline.SpikeNotes(:,1)==others(i,1) & Data.UnitsOnline.SpikeNotes(:,2)==others(i,2));
%         if isempty(t) || Data.UnitsOnline.SpikeNotes(t,3)==0
%             others_flag(i)=0;
%         end
%     end
% end
% others=others(find(others_flag),:);
units=[positives;negatives;others];
OFFLINE=1; SELECT=Data.Behavior.RuleEvents{13,2};
% colors=Set1(length(units(:,1))); colors=colors(3:end,:);




%% figure initialization
f=figure;f.Color=[1,1,1];
hold on

scts=zeros(1,length(units(:,1)));
ps=[];
pre_units=cell(1,length(units(:,1)));
for i=1:length(units(:,1)); pre_units{i}=[]; end
post_units=pre_units;

for index=1:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    %% position
    position=Data.Behavior.Position;
    timestamp_position=1:length(position);
    %% behavior data
    [timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
    timestamp_trialstart=timestamp_trialstart(grading);   timestamp_hittarget=timestamp_hittarget(grading);   timestamp_baselinestart=timestamp_baselinestart(grading);
    %% calc firing rate for each unit
    for i=1:length(units(:,1))
        spikes=Data.UnitsOnline;
        index_u=find(spikes.SpikeNotes(:,1)==units(i,1) & spikes.SpikeNotes(:,2)==units(i,2));
        if OFFLINE
            index_u=spikes.SpikeNotes(index_u,3);
            spikes=Data.UnitsOffline.SpikeTimes{index_u};
        end
        %% calculate firing rate pre & post trialstart
        pre_total=[];
        post_total=[];
        for j=1:length(timestamp_trialstart)
            if timestamp_hittarget(j)>0
                pre_sum=sum(spikes<timestamp_baselinestart(j)+3000 & spikes>timestamp_baselinestart(j));
                pre_total=[pre_total pre_sum/3];
                post_sum=sum(spikes<timestamp_hittarget(j) & spikes>timestamp_trialstart(j));
                post_total=[post_total post_sum*1000/(timestamp_hittarget(j)-timestamp_trialstart(j))];
            end
        end
        for j=1:length(pre_total)
            pre_units{i}=[pre_units{i} pre_total(j)];
            post_units{i}=[post_units{i} post_total(j)];
        end
    end
end

%% plot and calc p
for i=1:length(units(:,1))
    if i==1
        color=[1 0 0];
    elseif i==2
        color=[0 0 1];
    else
        color=colors(i-2,:);
    end
    
    scts(i)=scatter(pre_units{i},post_units{i},'MarkerFaceColor',[1,1,1]*0.3+color*0.7,'MarkerFaceAlpha',0.75,'MarkerEdgeAlpha',0);

    [~,ps(i),~,~]=ttest(pre_units{i},post_units{i});
end


%% other lines and legends and ...
% scatter(ax5,pre_total,post_total,'r');
line([0,45],[0,45],'color',[0,0,0]);
xlabel('firing rate during baseline','FontSize',12);
ylabel('firing rate during trial','FontSize',12);
for i=1:length(units(:,1))
    if i==1
        color=[1 0 0];
    elseif i==2
        color=[0 0 1];
    else
        color=colors(i-2,:);
    end
    text(35,7+3*i,sprintf("p=%.2f",ps(i)),'FontSize',12,'Color',[1,1,1]*0.3+color*0.7);
end

text(35,7,sprintf("n=%d",length(pre_units{1})),'FontSize',12);
xlim([0 45])
ylim([0 45])
st={};
for i=1:length(units(:,1))
    st{end+1}=['CH' num2str(units(i,1)) 'U' num2str(units(i,2))];
end
legend(scts,st,'box','off')
title([ animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)]);
axis equal
xlim([0 45])
set(gca,'XTick',get(gca,'YTick'))

savefig(f,[pwd '\FIGS\m_firing_firing_single_tar\' animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)])
close(f)
end

