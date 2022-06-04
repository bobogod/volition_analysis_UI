function m_psth_st3(animal,DataPaths)
% fast_import

%% initialization
Data=load(DataPaths{1}).Data;
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
others_flag=ones(1,length(others(:,1)));
for index=2:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    for i=1:length(others_flag)
        t=find(Data.UnitsOnline.SpikeNotes(:,1)==others(i,1) & Data.UnitsOnline.SpikeNotes(:,2)==others(i,2));
        if isempty(t) || Data.UnitsOnline.SpikeNotes(t,3)==0
            others_flag(i)=0;
        end
    end
end
others=others(find(others_flag),:);


units=[positives;negatives;others];
OFFLINE=1
SELECT="both";
colors=Set1(length(others(:,1)));
% selects=["min","max"];    
f=figure;f.Color=[1,1,1];
ha=tight_subplot(1+length(units(:,1)),1,[.01 .02],[.1 .1],[.1 .1],...
    [zeros(1,length(units(:,1))),1,1],ones((length(units(:,1))+1)));%[0,0,0,0,1,1],[1,1,1,1,1,1]);
xmin=-5000; xmax=10000;


% {{{spikes-align},{baselinestart-align,trialstart-align,hittarger-align}},{{spikes},{b-a,t-a,h-a}},...},{{{s},{ba,t-a,h-a}},{{},{}}}
% plots={unit,unit,unit}
% unit={{trial1},{trial2},{trial3}}
% trial={{spiketimes},{baselinestart-align,trialstart-align,hittarger-align}}
plots=cell(1,length(units(:,1)));
psths=plots;


%% record raster, days
for index=1:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    position=Data.Behavior.Position;
    totaltime=Data.Meta.Nev.DataDurationSec;
    x=1:1:totaltime*1000-1;
    
    %% event data
    [timestamp_trialstart,timestamp_hittarget,timestamp_portready,timestamp_portback] = get_timestamps_st3(Data);
    timestamp_align=timestamp_trialstart; %define which to align
    align_tag='TRIALSTART'
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
                    if (dir(end)==0 && SELECT=="min") || (dir(end)==1 && SELECT=="max") || (SELECT=="both")
                        align=timestamp_align(i);
                        if align+xmin>0 && align+xmax<length(CH_smooth)+1
                            t=spikes_u;
                            t=t(t>align+xmin & t<align+xmax)-align; %spike lines to plot
                            plots{iii}{end+1}={{t},{0,timestamp_trialstart(i)-align,timestamp_hittarget(i)-align}};
                            psths{iii}=[psths{iii},CH_smooth(round(align+xmin):round(align+xmax))'];
                        end
                    end
                end
            end
        end
    end
end

%% sort by trial lasting time
t=[];
for i=1:length(plots{1})
    t=[t;plots{1}{i}{2}{3}-plots{1}{i}{2}{2}];
end
t=[t,(1:length(t))'];
t=sortrows(t,1);
indext=t(:,2);

%% plot
for haindex=1:length(units(:,1))
    axes(ha(haindex));
    set(gca,'FontSize',10);
    hold(gca,'on');
    xlim([xmin,xmax])
    ylim([0.4,length(indext)+0.6])
    yticks([1 length(indext)])
    ylabel(['CH' num2str(units(haindex,1)) 'U' num2str(units(haindex,2))]);
    
    if haindex<=length(positives(:,1)); c=[0.4,0.1,0.1];
    elseif haindex<=length(positives(:,1))+length(negatives(:,1)); c=[0.1,0.1,0.4];
    else; c=colors(haindex-length(positives(:,1))-length(negatives(:,1)),:); end
    
    t_plot=plots{haindex};
    if ~isempty(t_plot)
        for i=1:length(indext)
            t=t_plot{indext(i)}{1}{1};
            for j=t;  line([j,j],i+[-0.5 0.5],'color',c); end
            %         line([0,0]+t_plot{indext(i)}{2}{1},i+[-0.5 0.5],'color','c','linewidth',1);
            %         line([3000,3000]+t_plot{indext(i)}{2}{1},i+[-0.5 0.5],'color','c','linewidth',1);
            line([0,0],i+[-0.5 0.5],'color','g','linewidth',1);
            line([0,0]+t_plot{indext(i)}{2}{3}-t_plot{indext(i)}{2}{2},i+[-0.5 0.5],'color','m','linewidth',1);
        end
    end
    
end

axes(ha(haindex+1));
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
line([0,0],[0,55],'color','g','linewidth',1)
ylabel(ha(length(units(:,1))+1),'spikes/s','FontSize',10)
xlabel(ha(length(units(:,1))+1),'time aligned to trialstart /ms')
% set(ha(8),'handlevisibility','off','visible','off');
% set(ha(10),'handlevisibility','off','visible','off');
tt=suptitle([ animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)]);
set(tt,'FontSize',12);
% lg.String=lg.String(1:end-1);


saveas(gcf,[pwd '\FIGS\m_psth_st3\'  animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)])
end
