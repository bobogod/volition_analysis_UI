function s_disp_baseline(animal,session,Data)
positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];

[timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);

%% load base
[mean_base,std_base]=load_base_new(Data);
first_target=Data.Behavior.RuleEvents{13,2};%"target":"min" or "max"
if first_target=='min'
    first_target=0;
else
    first_target=1;
end

%% position smooth
position=Data.Behavior.Position;

%% plot
f=figure;
ax=axes;
f.Color=[1,1,1];
hold(ax,'on')
rewards=0;
for i=1:length(timestamp_hittarget)
    if timestamp_hittarget(i)==0
        if mod(floor(rewards/2000),2)==first_target  
            scatter(ax,i,20,[],[0.3,0.3,0.7],'d');
        else
            scatter(ax,i,20,[],[0.7,0.3,0.3],'d');
        end
    else
        rewards=rewards+1;
        t=floor(timestamp_hittarget(i));
        pos=mean(position(t+2000:t+2500))
        if pos<1000 %10000 for 0702 data
            scatter(i,15,[],[0.3,0.3,0.7],'filled','d');
        else
            scatter(i,25,[],[0.7,0.3,0.3],'filled','d');
        end
    end
end


p1=plot(1:length(timestamp_trialstart),mean_base(1,:),'r');
p2=plot(1:length(timestamp_trialstart),std_base(1,:),'r--');
p3=plot(1:length(timestamp_trialstart),mean_base(2,:),'b');
p4=plot(1:length(timestamp_trialstart),std_base(2,:),'b--');
ylim([0 30])
xlabel('trial index','FontSize',13)
legend([p1,p2,p3,p4],{['CH',num2str(positives(1)),' mean'],['CH',num2str(positives(1)),' std'],['CH',num2str(negatives(1)),' mean'],['CH',num2str(negatives(1)),' std']},'box','off','FontSize',12);

title([animal '-' session])
savefig(f,[pwd '\FIGS\s_disp_baseline\' animal '-' session])
pause(1)
close(f)
end

