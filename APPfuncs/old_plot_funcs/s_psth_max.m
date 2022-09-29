function s_psth_max(animal,session,Data)
%% initialization
positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
others=[];
for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
    if Data.UnitsOnline.SpikeNotes(i,3)>0
        if ~(Data.UnitsOnline.SpikeNotes(i,1)==positives(1) && Data.UnitsOnline.SpikeNotes(i,2)==positives(2))
            if ~(Data.UnitsOnline.SpikeNotes(i,1)==negatives(1) && Data.UnitsOnline.SpikeNotes(i,2)==negatives(2))
                others=[others; Data.UnitsOnline.SpikeNotes(i,1:2)];
            end
        end
    end
end
units=[positives;negatives;others];
SELECT='max'; OFFLINE=1;
align_tags={'TRIALSTART','HITTARGET'};
% colors=viridis(length(others(:,1))+2); colors=colors(3:end,:);
if ~isempty(others);  colors=Set1(length(units(:,1))); colors=colors(3:end,:); end
% selects=["min","max"];
f=figure;f.Color=[1,1,1];
ha=tight_subplot(1+length(units(:,1)),2,[.01 .02],[.1 .1],[.1 .1],...
    [zeros(1,2*length(units(:,1))),1,1],ones(2*(length(units(:,1))+1)));%[0,0,0,0,1,1],[1,1,1,1,1,1]);
position=Data.Behavior.Position;
totaltime=Data.Meta.Nev.DataDurationSec;
x=1:1:totaltime*1000-1;
[timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
timestamp_trialstart=timestamp_trialstart(grading);  timestamp_hittarget=timestamp_hittarget(grading); timestamp_baselinestart=timestamp_baselinestart(grading);
drawnow

for index=1:2
    % {{{spikes-align},{baselinestart-align,trialstart-align,hittarger-align}},{{spikes},{b-a,t-a,h-a}},...},{{{s},{ba,t-a,h-a}},{{},{}}}
    % plots={unit,unit,unit}
    % unit={{trial1},{trial2},{trial3}}
    % trial={{spiketimes},{baselinestart-align,trialstart-align,hittarger-align}}
    plots_max=cell(1,length(units(:,1))); plots_min=plots_max;
    psths=plots_max;
    
    %% record raster, single day
    align_tag=align_tags{index};
    
    %% event data
    if strcmp(align_tag,'TRIALSTART'); 
        xmin=-7000; xmax=5000;
        timestamp_align=timestamp_trialstart; %define which to align
    elseif strcmp(align_tag,'HITTARGET'); 
        xmin=-9000; xmax=3000;
        timestamp_align=timestamp_hittarget; 
    end
    indext=find(timestamp_hittarget>0);
    
    %% record raster, units
    for iii=1:length(units(:,1))
        %% get spike data
        spikes=Data.UnitsOnline;
        index_u=find(spikes.SpikeNotes(:,1)==units(iii,1) & spikes.SpikeNotes(:,2)==units(iii,2));
        if OFFLINE
            index_u=spikes.SpikeNotes(index_u,3);
            spikes=Data.UnitsOffline;
        end
        if index_u>0
            spikes_u=spikes.SpikeTimes{index_u};
            CH_smooth=sdf_smooth(x,spikes_u,100)';
            
            %%
            t_last=-1;
            i_last=-1;
            dir=[];
            for iiii=1:length(indext)
                i=round(indext(iiii));
                if timestamp_hittarget(i)>0
                    tt=floor(timestamp_hittarget(i));
                    pos=mean(position(tt+2000:tt+2500));
                    if pos<1000;   dir=[dir 0];    else;  dir=[dir 1];   end
                    if (dir(end)==0 && SELECT=="min") || (dir(end)==1 && SELECT=="max")
                        t=spikes_u;
                        align=timestamp_align(i);
                        t=t(t>align+xmin & t<align+xmax)-align; %spike lines to plot
                        if SELECT=="max";  plots_max{iii}{end+1}={{t},{timestamp_baselinestart(i)-align,timestamp_trialstart(i)-align,timestamp_hittarget(i)-align}}; end
                        if SELECT=="min";  plots_min{iii}{end+1}={{t},{timestamp_baselinestart(i)-align,timestamp_trialstart(i)-align,timestamp_hittarget(i)-align}}; end
                        t_left=max(1,round(align+xmin));
                        t_right=min(round(align+xmax),length(CH_smooth));
                        psths{iii}=[psths{iii},[zeros(max(0,t_left-round(align+xmin)),1);CH_smooth(t_left:t_right)';zeros(max(0,t_right-length(CH_smooth)),1)]];
                    end
                end
            end
        end
    end
    
    %% sort by what?
    t=[];
    if strcmp(align_tag,'TRIALSTART')
        for i=1:length(plots_max{2})
            t=[t;plots_max{2}{i}{2}{2}-plots_max{2}{i}{2}{1}];
        end
    elseif strcmp(align_tag,'HITTARGET')
        for i=1:length(plots_max{2})
            t=[t;plots_max{2}{i}{2}{3}-plots_max{2}{i}{2}{2}];
        end
    end
    t=[t,(1:length(t))'];
    t=sortrows(t,1);
    indext=t(:,2);
    
    %% plot
    plots=[plots_min',plots_max'];
    for haindex=1:length(units(:,1))
        ii=2; %max
        axes(ha(haindex*2-2+index));
        set(gca,'FontSize',10);
        hold(gca,'on');
        xlim([xmin,xmax])
        ylim([0.4,length(indext)+0.6])
        if index==1
            yticks([1 length(indext)])
            ylabel(['CH' num2str(units(haindex,1)) 'U' num2str(units(haindex,2))],'Rotation',0,'FontSize',10);
        else
            yticks([])
            ylabel('')
        end
        
        if haindex<=length(positives(:,1)); c=[0.4,0.1,0.1];
        elseif haindex<=length(positives(:,1))+length(negatives(:,1)); c=[0.1,0.1,0.4];
        else; c=colors(haindex-length(positives(:,1))-length(negatives(:,1)),:); end
        
        t_plot=plots{haindex,ii};
        if ~isempty(t_plot)
            for i=1:length(indext)
                t=t_plot{indext(i)}{1}{1};
                for j=t;  line([j,j],i+[-0.5 0.5],'color',c); end
                line([0,0]+t_plot{indext(i)}{2}{1},i+[-0.5 0.5],'color','c','linewidth',1);
                line([3000,3000]+t_plot{indext(i)}{2}{1},i+[-0.5 0.5],'color','c','linewidth',1);
                line([0,0]+t_plot{indext(i)}{2}{2},i+[-0.5 0.5],'color','g','linewidth',1);
                line([0,0]+t_plot{indext(i)}{2}{3},i+[-0.5 0.5],'color','m','linewidth',1);
            end
        end
    end
    
    axes(ha(haindex*2+index));
    set(gca,'FontSize',10);
    hold(gca,'on');
    xlim([xmin,xmax])
    ylim([0,30])
    boot_cycle=1000;
    lines={};
    for i=1:length(units(:,1))
        if i<=length(positives(:,1)); c='r';
        elseif i<=length(positives(:,1))+length(negatives(:,1)); c='b';
        else; c=colors(i-length(positives(:,1))-length(negatives(:,1)),:); end
        if ~isempty(psths{i})
            unit_95ci=bootci(boot_cycle,{@(x) mean(x),psths{i}'},'Alpha',0.05);
            lines{end+1}=shadedErrorBar(xmin:1:xmax,mean(psths{i}')',abs([unit_95ci(2,:)-mean(psths{i}'); unit_95ci(1,:)-mean(psths{i}')]),'lineprops',{'color',c});
        end
    end
    t=[]; names={}; for i=1:length(lines); t=[t lines{i}.mainLine]; names{end+1}=['CH',num2str(units(i,1)),'U',num2str(units(i,2))]; end
    % lg=legend(t,names,'box','off');
    % axes(ha(2*(length(positives(:,1))+length(negatives(:,1))+length(others(:,1)))+2))
    % p1=shadedErrorBar(xmin:1:xmax-1,mean(firing_heat_positive{iii*3+aligns-3}')',abs([positive_95ci(2,:)-mean(firing_heat_positive{iii*3+aligns-3}'); positive_95ci(1,:)-mean(firing_heat_positive{iii*3+aligns-3}')]),'lineprops','r');
    % p2=shadedErrorBar(xmin:1:xmax-1,mean(firing_heat_negative{iii*3+aligns-3}')',abs([negative_95ci(2,:)-mean(firing_heat_negative{iii*3+aligns-3}'); negative_95ci(1,:)-mean(firing_heat_negative{iii*3+aligns-3}')]),'lineprops','b');
    % if timestamp_align(1)==timestamp_hittarget(1);  line([0,0],[0,55],'color','m'); end

    %% temp
    if strcmp(align_tag,'TRIALSTART')
        line([0,0],[0,55],'color','g','linewidth',1)
    elseif strcmp(align_tag,'HITTARGET')
        line([0,0],[0,55],'color','m','linewidth',1)
    end  
    xlabel(ha(length(units(:,1))*2+index),['time aligned to ' lower(align_tag) '/ms'])
end

ylabel(ha(length(units(:,1))*2+1),'spikes/s','FontSize',10)
tt=suptitle([animal '-' session]);
set(tt,'FontSize',12);
saveas(gcf,[pwd '\FIGS\s_psth_max\' animal '-' session])
close(gcf)
end

