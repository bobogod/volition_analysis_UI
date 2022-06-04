function m_psth_single_tar(animal,DataPaths)
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
if ~isempty(others)
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
end
units=[positives;negatives;others]
OFFLINE=1;
align_tags={'TRIALSTART','HITTARGET'};
if ~isempty(others);  colors=Set1(length(units(:,1))); colors=colors(3:end,:); end


f=figure;f.Color=[1,1,1];
ha=tight_subplot(1+length(units(:,1)),2,[.01 .02],[.1 .1],[.1 .1],...
    [zeros(1,2*length(units(:,1))),1,1],ones(2*(length(units(:,1))+1)));%[0,0,0,0,1,1],[1,1,1,1,1,1]);
drawnow

psth_data=[];
bootci_input=struct('Align',[],'CH',[],'U',[],'Firing',[]);
for i=1:2
    for j=1:length(units(:,1))
        bootci_input((i-1)*length(units(:,1))+j)=struct('Align',align_tags{i},'CH',units(j,1),'U',units(j,2),'Firing',[]); 
    end
end

for align_index=1:2
    psth_data_t=psth_data;
    psth_data=struct('Align',[],'CH',[],'U',[],'Baselineon',[],'Trialstart',[],'Hittarget',[],'Spiketime',[]);
    
    %% record raster, single day
    align_tag=align_tags{align_index};
    for index=1:length(DataPaths)
        t1=tic();
        Data=load(DataPaths{index}).Data;
        totaltime=Data.Meta.Nev.DataDurationSec;
        x=1:1:totaltime*1000-1;
        [timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,~,~,grading] = get_timestamps_new(Data);
        timestamp_trialstart=timestamp_trialstart(grading);  timestamp_hittarget=timestamp_hittarget(grading); timestamp_baselinestart=timestamp_baselinestart(grading);
        
        %% event data
        if strcmp(align_tag,'TRIALSTART')
            xmin=-7000; xmax=10000;
            timestamp_align=timestamp_trialstart; %define which to align
        elseif strcmp(align_tag,'HITTARGET')
            xmin=-10000; xmax=7000;
            timestamp_align=timestamp_hittarget;
        end
        indext=find(timestamp_hittarget>0);
        disp(['load data time=' num2str(toc(t1)) 's'])
        t1=tic();
        
        %% record raster, units
        for iii=1:length(units(:,1)) %each unit
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
                bootci_t=[];
                
               %% store data
                for iiii=1:length(indext) %each trial
                    i=round(indext(iiii));
                    t=spikes_u;
                    align=timestamp_align(i);
                    t=t(t>align+xmin & t<align+xmax)-align; %spike lines to plot
                    tt=struct('Align',align_tag,'CH',units(iii,1),'U',units(iii,2),...
                        'Baselineon',timestamp_baselinestart(i)-align,'Trialstart',timestamp_trialstart(i)-align,...
                        'Hittarget',timestamp_hittarget(i)-align,'Spiketime',t);
                    psth_data(end+1)=tt;
                    
                    t_left=max(1,round(align+xmin));
                    t_right=min(round(align+xmax),length(CH_smooth));
                    
                    bootci_t=[bootci_t,[zeros(max(0,t_left-round(align+xmin)),1);CH_smooth(t_left:t_right)';zeros(max(0,t_right-length(CH_smooth)),1)]];
                end
                bootci_input((align_index-1)*length(units(:,1))+iii).Firing=[bootci_input((align_index-1)*length(units(:,1))+iii).Firing,bootci_t];   
            end
        end
        disp(['record raster time=' num2str(toc(t1)) 's'])
        t1=tic();
    end
    
    %% sort psth_data
    psth_data=psth_data(2:end);
    t=[];
    for j=1:length(units(:,1))
        t=[t psth_data([psth_data.CH]==units(j,1) & [psth_data.U]==units(j,2))];
    end
    psth_data=[psth_data_t t];
    
    %% sort by what?
    t=[];
    for ii=1:length(psth_data)
        if psth_data(ii).CH==positives(1) && psth_data(ii).U==positives(2) && strcmp(align_tag,psth_data(ii).Align)
            if strcmp(align_tag,'TRIALSTART')
                t=[t;psth_data(ii).Trialstart-psth_data(ii).Baselineon];
            else
                t=[t;psth_data(ii).Hittarget-psth_data(ii).Trialstart];
            end
        end
    end
    t=[t,(1:length(t))'];
    t=sortrows(t,1);
    indext=t(:,2);
    
    %% plot
    for haindex=1:length(units(:,1))
        axes(ha(haindex*2-2+align_index));
        set(gca,'FontSize',10);
        hold(gca,'on');
        xlim([xmin,xmax])
        ylim([0.4,length(indext)+0.6])
        if align_index==1
            yticks([1 length(indext)])
            ylabel(['CH' num2str(units(haindex,1)) 'U' num2str(units(haindex,2))],'Rotation',0,'FontSize',10);
        else
            yticks([])
            ylabel('')
        end
        
        if haindex<=length(positives(:,1)); c=[0.4,0.1,0.1];
        elseif haindex<=length(positives(:,1))+length(negatives(:,1)); c=[0.1,0.1,0.4];
        else; c=colors(haindex-length(positives(:,1))-length(negatives(:,1)),:); end

        %% plot spikes
        counts=0;
        for i=1:length(indext); counts=counts+length(psth_data(indext(i)+length(indext)*(haindex-1)+round(length(psth_data)/2*(align_index-1))).Spiketime); end            
        xpoints=nan(3,counts); ypoints=xpoints;
        counts=0;
        for i=1:length(indext)
            t=psth_data(indext(i)+length(indext)*(haindex-1)+length(psth_data)/2*(align_index-1)).Spiketime;
            xpoints(1:2,counts+1:counts+length(t))=[t;t];
            ypoints(1:2,counts+1:counts+length(t))=ones(2,length(t)).*[i-0.5;i+0.5];
            counts=counts+length(t);
        end
        xpoints=reshape(xpoints,1,counts*3); ypoints=reshape(ypoints,1,counts*3);
        plot(xpoints,ypoints,'color',c);
        
        %% plot events
        for i=1:length(indext)
            line([0,0]+psth_data(indext(i)+length(psth_data)/2*(align_index-1)).Baselineon,i+[-0.5 0.5],'color','c','linewidth',1);
            line([3000,3000]+psth_data(indext(i)+length(psth_data)/2*(align_index-1)).Baselineon,i+[-0.5 0.5],'color','c','linewidth',1);
            line([0,0]+psth_data(indext(i)+length(psth_data)/2*(align_index-1)).Trialstart,i+[-0.5 0.5],'color','g','linewidth',1);
            line([0,0]+psth_data(indext(i)+length(psth_data)/2*(align_index-1)).Hittarget,i+[-0.5 0.5],'color','m','linewidth',1);
        end
    end
    disp(['raster plot time=' num2str(toc(t1)) 's'])
    t1=tic();
    
    %% boot ci and firing rate
    axes(ha(haindex*2+align_index));
    set(gca,'FontSize',10);
    hold(gca,'on');
    xlim([xmin,xmax])
    ylim([0,30])
    boot_cycle=500;
    lines={};
    for i=1:length(units(:,1))
        if i<=length(positives(:,1)); c='r';
        elseif i<=length(positives(:,1))+length(negatives(:,1)); c='b';
        else; c=colors(i-length(positives(:,1))-length(negatives(:,1)),:); end
        t=bootci_input(i+round(length(bootci_input)/2*(align_index-1))).Firing;
        unit_95ci=bootci(boot_cycle,{@(x) mean(x),t'},'Alpha',0.05);
        lines{end+1}=shadedErrorBar(xmin:1:xmax,mean(t')',abs([unit_95ci(2,:)-mean(t'); unit_95ci(1,:)-mean(t')]),'lineprops',{'color',c});
    end
    disp(['bootci time=' num2str(toc(t1)) 's'])

    %% temp
    if strcmp(align_tag,'TRIALSTART')
        line([0,0],[0,55],'color','g','linewidth',1)
    elseif strcmp(align_tag,'HITTARGET')
        line([0,0],[0,55],'color','m','linewidth',1)
    end
    xlabel(ha(length(units(:,1))*2+align_index),['time aligned to ' lower(align_tag) '/ms'])
    
    %% hist of trial time
    if strcmp(align_tag,'TRIALSTART')
        hittime=[];
        for i=1:length(indext)
            hittime=[hittime psth_data(indext(i)).Hittarget];
        end
%         hittime=cell2mat(hittime);
    end
end

ylabel(ha(length(units(:,1))*2+1),'spikes/s','FontSize',10)
tt=suptitle([ animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)]);
set(tt,'FontSize',12);

hist_ax=axes('Position',[0.26,0.87,0.23,0.05]);%[0.33,0.86,0.16,0.05]);%[0.33,0.86,0.16,0.05]);
histogram(hittime,100,'FaceColor','k','FaceAlpha',1,'Normalization','probability')
xlim([0,10000])
set(hist_ax,'box','off')
set(hist_ax,'XTick',[])

saveas(gcf,[pwd '\FIGS\m_psth_single_tar\'  animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20)])
% pause(5)
% close(gcf)
debug_marker=1;
save([pwd '\FIGS\m_psth_single_tar\'  animal '-' DataPaths{1}(end-23:end-20) '-' DataPaths{end}(end-23:end-20) '.mat'],'bootci_input','psth_data');
end

