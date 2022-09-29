function m_DCZ_psth_st3(animal,DataPaths)
% input must come from single day

Data=load(DataPaths{1}).Data;
positives=[];
negatives=[];
others=[];
for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
    if Data.UnitsOnline.SpikeNotes(i,3)>0
        others=[others; Data.UnitsOnline.SpikeNotes(i,1:2)];
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

units=[positives;negatives;others]
OFFLINE=1;
align_tags={'BASELINE ONSET','TRIAL START','HIT TARGET'};
color=RdYlBu; color=color(end:-1:1,:);


f=figure('Units','inches','Position',[1,1,7.3,5.5],'Color',[1,1,1]);
drawnow
hs=[];

psth_data=[];
bootci_input=struct('Align',[],'CH',[],'U',[],'Firing',[]);
for i=1:3
    for j=1:length(units(:,1))
        bootci_input((i-1)*length(units(:,1))+j)=struct('Align',align_tags{i},'CH',units(j,1),'U',units(j,2),'Firing',[]);
    end
end
bootci_input_DCZ=bootci_input;

for align_index=1:3
    psth_data_t=psth_data;
    psth_data=struct('Align',[],'CH',[],'U',[],'Baselineon',[],'Trialstart',[],'Hittarget',[],'Spiketime',[]);
    psth_data_DCZ=psth_data;
    
    %% event data
    align_tag=align_tags{align_index};    
    for index=1:length(DataPaths)
        %% event data
        t1=tic();
        Data=load(DataPaths{index}).Data;
        isDCZ=length(strfind(DataPaths{index},'DCZ'));
        totaltime=Data.Meta.Nev.DataDurationSec;
        x=1:1:totaltime*1000-1;
        [timestamp_trialstart,timestamp_hittarget,timestamp_portready,timestamp_portback] = get_timestamps_st3(Data);
        wait_time=unique(cell2mat(Data.Behavior.RuleEvents(5,2:end)),'stable')*1000;
        timestamp_baselinestart=timestamp_trialstart-wait_time;
        
        if strcmp(align_tag,'TRIAL START')
            xmin=-3000; xmax=7000;
            timestamp_align=timestamp_trialstart; %define which to align
        elseif strcmp(align_tag,'HIT TARGET')
            xmin=-7000; xmax=3000;
            timestamp_align=timestamp_hittarget;
        elseif strcmp(align_tag,'BASELINE ONSET')
            xmin=-2000; xmax=8000;
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
                        'Baselineon',[],'Trialstart',timestamp_trialstart(i)-align,...
                        'Hittarget',timestamp_hittarget(i)-align,'Spiketime',t);
                    psth_data(end+1)=tt;
                    
                    t_left=max(1,round(align+xmin));
                    t_right=min(round(align+xmax),length(CH_smooth));
                    
                    bootci_t=[bootci_t,[zeros(max(0,t_left-round(align+xmin)),1);CH_smooth(t_left:t_right)';zeros(max(0,t_right-length(CH_smooth)),1)]];
                end
                if isDCZ
                    bootci_input_DCZ((align_index-1)*length(units(:,1))+iii).Firing=[bootci_input_DCZ((align_index-1)*length(units(:,1))+iii).Firing,bootci_t];
                else
                    bootci_input((align_index-1)*length(units(:,1))+iii).Firing=[bootci_input((align_index-1)*length(units(:,1))+iii).Firing,bootci_t];
                end
            end
        end
        disp(['record raster time=' num2str(toc(t1)) 's'])
        t1=tic();
    end
    
    %% no DCZ
    %% plot
    axes('Position',[-0.2+0.28*align_index,0.35,0.27,0.25]);
    heat_plot=[];
    for i=1:length(units(:,1))
        t=bootci_input((align_index-1)*length(units(:,1))+i).Firing;
        tt=movsum(t,100);
        tt=tt(50:100:end,:);
        heat_plot=[heat_plot;mean(tt')];
    end
    heat_plot=zscore(heat_plot')';
    
    %% sort
    if align_index==1
        unit_index=[];
        for i=1:length(units(:,1))
            [~,t]=max(heat_plot(i,:));
            if (length(t)>1); t=t(1); end
            unit_index=[unit_index t];
        end
        t=sortrows([unit_index;1:length(unit_index)]')';
        unit_index=t(2,:);
    end
    
    heat_plot=heat_plot(unit_index,:);
    
    heat_plot(:,-xmin/100)=nan;
    h=heatmap(heat_plot,'Colormap',color,"GridVisible",0);
    hs=[hs h];
    
    %% further plot
    xlabels={};
    for i=1:length(heat_plot(1,:))
        xlabels{end+1}='';
    end
    h.XDisplayLabels=xlabels;
    
    ylabels={};
    for i=1:length(heat_plot(:,1))
        ylabels{end+1}='';
    end
    if align_index==1; ylabels{1}='1'; ylabels{end}=num2str(length(heat_plot(:,1))); end
    h.YDisplayLabels=ylabels;
    
    h.ColorLimits=[-3,3];
    if align_index==1; ylabel('Neuron before DCZ'); end
    if align_index==length(align_tags)
        ylabel('zscored firing rate')
        set(struct(h).NodeChildren(end),'YAxisLocation','right');
    end
    
    h.ColorbarVisible=0;
    set(struct(h).NodeChildren(end), 'XTickLabelRotation', 0, 'box', 0);
    
    
    %% DCZ
    %% plot
    axes('Position',[-0.2+0.28*align_index,0.07,0.27,0.25]);
    heat_plot=[];
    for i=1:length(units(:,1))
        t=bootci_input_DCZ((align_index-1)*length(units(:,1))+i).Firing;
        tt=movsum(t,100);
        tt=tt(50:100:end,:);
        heat_plot=[heat_plot;mean(tt')];
    end
    heat_plot=zscore(heat_plot')';
    
%     %% sort
%     if align_index==1
%         unit_index=[];
%         for i=1:length(units(:,1))
%             [~,t]=max(heat_plot(i,:));
%             if (length(t)>1); t=t(1); end
%             unit_index=[unit_index t];
%         end
%         t=sortrows([unit_index;1:length(unit_index)]')';
%         unit_index=t(2,:);
%     end
    
    heat_plot=heat_plot(unit_index,:);
    
    heat_plot(:,-xmin/100)=nan;
    h=heatmap(heat_plot,'Colormap',color,"GridVisible",0);
    hs=[hs h];
    
    %% further plot
    xlabels={};
    for i=1:length(heat_plot(1,:))
        xlabels{end+1}='';
    end
    xlabels{-xmin/100}='0';  xlabels{7}=xmin;  xlabels{end-7}=xmax;
    h.XDisplayLabels=xlabels;
    
    ylabels={};
    for i=1:length(heat_plot(:,1))
        ylabels{end+1}='';
    end
    if align_index==1; ylabels{1}='1'; ylabels{end}=num2str(length(heat_plot(:,1))); end
    h.YDisplayLabels=ylabels;
    
    h.ColorLimits=[-3,3];
    xlabel(lower(align_tag))
    if align_index==1; ylabel('Neuron after DCZ'); end
    
    
    if align_index~=length(align_tags); h.ColorbarVisible=0; end
    set(struct(h).NodeChildren(1), 'visible', 0);
    set(struct(h).NodeChildren(end), 'XTickLabelRotation', 0, 'box', 0);
    
end

%% plot waveforms (pre-DCZ) and calc firing rate
for index=1:length(DataPaths)
    isDCZ=length(strfind(DataPaths{index},'DCZ'));
    if ~isDCZ
        Data=load(DataPaths{index}).Data;
    else
        Data_DCZ=load(DataPaths{index}).Data;
    end
end
firing_rate=[]; firing_rate_DCZ=[];
for i=1:length(units(:,1))
    index_u=unit_index(i);
    index_u_t=index_u;
    index_u=find(Data.UnitsOnline.SpikeNotes(:,1)==units(index_u,1) & Data.UnitsOnline.SpikeNotes(:,2)==units(index_u,2));
    index_u=Data.UnitsOnline.SpikeNotes(index_u,3);
    % 0.05 margin, [4x,1x,4x,1x,...4x] spacing
    axes('Position',[0.07+(i-1)*0.9*(5/(5*length(units(:,1))-1)) 0.9-0.9*4/(5*length(units(:,1))-1) 0.9*4/(5*length(units(:,1))-1) 0.9*4/(5*length(units(:,1))-1)])
    hold on
    allwaves=Data.UnitsOffline.SpikeWaves{index_u};
    allwaves= allwaves(:, [1:64]);
    if size(allwaves, 1)>100
        nplot = randperm(size(allwaves, 1), 100);
    else
        nplot=[1:size(allwaves, 1)];
    end;
    wave2plot = allwaves(nplot, :);
    plot([1:64], wave2plot, 'color', [0.8 .8 0.8]);
    plot([1:64], mean(allwaves, 1), 'color', 'k', 'linewidth', 2)
    axis([0 65 -1600 800])
    axis tight
    axis off
    xlim([0 64])
    if i==1
        line([2,2],[-1400 -1400+512],'Color','k','LineWidth',1);
    end
    text(32,-2100,['CH',num2str(units(index_u_t,1)),'U',num2str(units(index_u_t,2))],'HorizontalAlignment','center','VerticalAlignment','middle')
    set (gca, 'ylim', [-2000 800])
    
    offline_spikes_t=Data.UnitsOffline.SpikeTimes{index_u};
    mean_firing_rate=length(offline_spikes_t)/offline_spikes_t(end)*1000;
    firing_rate=[firing_rate mean_firing_rate];
    
    
    index_u=unit_index(i);
    index_u=find(Data_DCZ.UnitsOnline.SpikeNotes(:,1)==units(index_u,1) & Data_DCZ.UnitsOnline.SpikeNotes(:,2)==units(index_u,2));
    index_u=Data_DCZ.UnitsOnline.SpikeNotes(index_u,3);
    offline_spikes_t=Data_DCZ.UnitsOffline.SpikeTimes{index_u};
    mean_firing_rate=length(offline_spikes_t)/offline_spikes_t(end)*1000;
    firing_rate_DCZ=[firing_rate_DCZ mean_firing_rate];
end

%% plot firing rate
axes('Position',[0.07 0.62 0.9 0.25-0.9*4/(5*length(units(:,1))-1)])
b=bar([firing_rate',firing_rate_DCZ'],'grouped');
% b.BarWidth=0.3;
xlim([0.65,length(units(:,1))+0.35])
xticklabels([])
ylabel('mean firing rate (Hz)')
set(gca,'box',0,'TickLength',[0.001,0.001])
legend('before DCZ','after DCZ','Location','northwest','box',0)


if DataPaths{1}(end-20)~='Z'
    tt=suptitle([ animal '-' DataPaths{1}(end-27:end-20)]);
    set(tt,'FontSize',12);
    savefig(f,[pwd '\FIGS\m_DCZ_psth_st3\' animal '-' DataPaths{1}(end-27:end-20)])
    saveas(f,[pwd '\FIGS\m_DCZ_psth_st3\' animal '-' DataPaths{1}(end-27:end-20) '.png'])
end

end