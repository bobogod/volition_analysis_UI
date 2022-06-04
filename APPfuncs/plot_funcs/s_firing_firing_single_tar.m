function s_firing_firing_single_tar(animal,session,Data)
%% initialize
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
units=[positives;negatives;others];
OFFLINE=1; SELECT=Data.Behavior.RuleEvents{13,2};
if ~isempty(others); colors=Set1(length(units(:,1))); colors=colors(3:end,:); end




%% figure initialization
f=figure;f.Color=[1,1,1];
colormap(f,"gray");
colorbar();
f.Children(1).Ticks=[0.1,0.9];
f.Children(1).Limits=[0.1,0.9];

%% position
position=Data.Behavior.Position;
timestamp_position=1:length(position);

%% behavior data
[timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
timestamp_trialstart=timestamp_trialstart(grading);   timestamp_hittarget=timestamp_hittarget(grading);   timestamp_baselinestart=timestamp_baselinestart(grading);

%% calc firing rate for each unit
hold on
scts=zeros(1,length(units(:,1)));
ps=[];
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
    
    %% plot
    if i==1
        color=[1 0 0];
    elseif i==2
        color=[0 0 1];
    else
        color=colors(i-2,:);
    end
    
    count=0;
    pre_unit=[]; post_unit=[];
    for j=1:length(pre_total)
        c=j/length(pre_total)*[1,1,1]*0.6+color*0.4;
        pre_unit=[pre_unit pre_total(j)];
        post_unit=[post_unit post_total(j)];
        scatter(pre_total(j),post_total(j),30,'MarkerFaceColor',c,'MarkerEdgeAlpha',0);
    end
    scts(i)=scatter(-1,-1,'MarkerFaceColor',[1,1,1]*0.3+color*0.7,'MarkerEdgeAlpha',0);
    
    %% ttest
    [~,ps(i),~,~]=ttest(pre_unit,post_unit);
end

%% other lines and legends and ...
% scatter(ax5,pre_total,post_total,'r');
line([0,45],[0,45],'color',[0,0,0]);
xlabel('firing rate during baseline','FontSize',12);
ylabel('firing rate during trial','FontSize',12);
for i=3:length(units(:,1))
    text(35,5+5*i,sprintf("p(oth)=%.2f",ps(i)),'FontSize',12);
end
text(35,10,sprintf("p(pos)=%.2f",ps(1)),'FontSize',12);
text(35,15,sprintf("p(neg)=%.2f",ps(2)),'FontSize',12);

text(35,5,sprintf("n=%d",length(pre_total)),'FontSize',12);
xlim([0 45])
ylim([0 45])
    f.Children(1).TickLabels=["1",num2str(length(pre_total))];
    f.Children(1).FontSize=10;
st={};
for i=1:length(units(:,1))
    st{end+1}=['CH' num2str(units(i,1)) 'U' num2str(units(i,2))];
end
legend(scts,st,'box','off')
title(strcat(animal,"-",session,"-",SELECT));
axis equal
xlim([0 45])
set(gca,'XTick',get(gca,'YTick'))

savefig(f,[pwd '\FIGS\s_firing_firing_single_tar\' animal '-' session])
pause(5)
close(f)
end

