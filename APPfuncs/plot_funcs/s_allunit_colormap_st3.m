function s_allunit_colormap_st3(animal,session,Data)
%% initialization
units=[];
for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
    if Data.UnitsOnline.SpikeNotes(i,3)>0
        units=[units; Data.UnitsOnline.SpikeNotes(i,1:2)];
    end
end
OFFLINE=1;
align_tags={'BASELINEON','TRIALSTART','HITTARGET'};

f=figure('Units','inches','Position',[1,1,7.3,5],'Color',[1,1,1]);
color=RdYlBu; color=color(end:-1:1,:);
drawnow
hs=[];

psth_data=[];
bootci_input=struct('Align',[],'CH',[],'U',[],'Firing',[]);
for i=1:3
    for j=1:length(units(:,1))
        bootci_input((i-1)*length(units(:,1))+j)=struct('Align',align_tags{i},'CH',units(j,1),'U',units(j,2),'Firing',[]);
    end
end

for align_index=1:3
    psth_data_t=psth_data;
    psth_data=struct('Align',[],'CH',[],'U',[],'Baselineon',[],'Trialstart',[],'Hittarget',[],'Spiketime',[]);
    
    %% event data
    align_tag=align_tags{align_index};
    t1=tic();
    totaltime=Data.Meta.Nev.DataDurationSec;
    x=1:1:totaltime*1000-1;
    [timestamp_trialstart,timestamp_hittarget,timestamp_portready,timestamp_portback] = get_timestamps_st3(Data);
    wait_time=unique(cell2mat(Data.Behavior.RuleEvents(5,2:end)),'stable')*1000;
    timestamp_baselinestart=timestamp_trialstart-wait_time;
    
    if strcmp(align_tag,'TRIALSTART')
        xmin=-3000; xmax=7000;
        timestamp_align=timestamp_trialstart; %define which to align
    elseif strcmp(align_tag,'HITTARGET')
        xmin=-7000; xmax=3000;
        timestamp_align=timestamp_hittarget;
    elseif strcmp(align_tag,'BASELINEON')
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
            bootci_input((align_index-1)*length(units(:,1))+iii).Firing=[bootci_input((align_index-1)*length(units(:,1))+iii).Firing,bootci_t];
        end
    end
    disp(['record raster time=' num2str(toc(t1)) 's'])
    t1=tic();
    
    %% plot
    axes('Position',[-0.2+0.28*align_index,0.1,0.27,0.35]);
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
    if align_index==1; ylabel('Neuron'); end
    
    set(struct(h).NodeChildren(1), 'visible', 0);
    if align_index~=length(align_tags); set(struct(h).NodeChildren(2), 'visible', 0); end
    set(struct(h).NodeChildren(end), 'XTickLabelRotation', 0, 'box', 0);
    
end

%% plot waveforms (and calc firing rate)
firing_rate=[];
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
end

%% plot firing rate
axes('Position',[0.07 0.5 0.88 0.35-0.9*4/(5*length(units(:,1))-1)])
b=bar(firing_rate);
b.BarWidth=0.3
xlim([0.8,length(units(:,1))+0.2])
xticklabels([])
ylabel('mean firing rate (Hz)')
set(gca,'box',0,'TickLength',[0.001,0.001])

tt=suptitle([ animal '-' session]);
set(tt,'FontSize',12);


for i=1:length(hs)
    if i~=length(hs); hs(i).ColorbarVisible=0; end
    set(struct(hs(i)).NodeChildren(1), 'Visible', 0);    
    set(struct(hs(i)).NodeChildren(end), 'XTickLabelRotation', 0, 'box', 0);
end

saveas(gcf,[pwd '\FIGS\s_allunit_colormap_st3\'  animal '-' session])
saveas(gcf,[pwd '\FIGS\s_allunit_colormap_st3\'  animal '-' session '.png'])
% pause(5)
% close(gcf)
% save([pwd '\FIGS\m_psth_st3\'  animal '-' session '.mat'],'bootci_input','psth_data');
end

