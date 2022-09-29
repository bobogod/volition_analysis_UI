function s_seperate_psth_st3(animal,session,Data)
%% initialization
units=[];
for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
    if Data.UnitsOnline.SpikeNotes(i,3)>0
        units=[units; Data.UnitsOnline.SpikeNotes(i,1:2)];
    end
end

OFFLINE=1;
colors={'m','c','y',[0.49,0.18,0.56]};
thiscolor = [0 0 0];
color_select=Dark2(10);

if ~isfolder([pwd '\FIGS\s_seperate_psth_st3\' animal '-' session])
    mkdir([pwd '\FIGS\s_seperate_psth_st3\' animal '-' session])
end


for i=1:length(units(:,1))
    f=figure(); f.Color=[1,1,1];
    
    spikes=Data.UnitsOnline; CHANNEL=units(i,1); UNIT=units(i,2);
    index_u=find(spikes.SpikeNotes(:,1)==CHANNEL & spikes.SpikeNotes(:,2)==UNIT);
    index_u_online=index_u;
    index_u=spikes.SpikeNotes(index_u,3);
    if index_u
        offline_spikes_t=Data.UnitsOffline.SpikeTimes{index_u};
        mean_firing_rate=length(offline_spikes_t)/offline_spikes_t(end)*1000;
    end
    
    if index_u && mean_firing_rate<30
        
        %% plot waveform
        axes('Position',[.05 .75 .15 .15])
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
        plot([1:64], mean(allwaves, 1), 'color', thiscolor, 'linewidth', 2)
        
        %axis properties
        axis([0 65 -1600 800])
        axis tight
        axis off
        xlim([0 64])
        %         text(0,0,{['CH',num2str(CHANNEL),'U',num2str(UNIT)],num2str(mean_firing_rate)},'HorizontalAlignment','right','FontSize',6.5)
        line([2,2],[-1400 -1400+512],'Color','k','LineWidth',1);
        text(3,-1000,'100μv','HorizontalAlignment','left','FontSize',6);
        set (gca, 'ylim', [-2000 800])
        
        %% plot autocorrelation, 1ms bin
        axes('Position',[.25 .75 .2 .15])
        hold on
        kutime = floor(Data.UnitsOnline.SpikeTimes{index_u_online});
        kutime2_on = zeros(1, round(max(kutime)));
        kutime2_on(kutime)=1;
        kutime = floor(Data.UnitsOffline.SpikeTimes{index_u});
        kutime2_off = zeros(1, round(max(kutime)));
        kutime2_off(kutime)=1;
        t=min(length(kutime2_on),length(kutime2_off));
        kutime2_off=kutime2_off(1:t); kutime2_on=kutime2_on(1:t);
        
        %offline
        [c, lags] = xcorr(kutime2_off, 25); % max lag 25 ms
        c(lags==0)=0;
        xlim([-25 25]);
        if median(c)>1
            set(gca,'xtick', [-50:10:50], 'ytick', [0 median(c)])
        else
            set(gca,'xtick', [-50:10:50], 'ytick', [0 1], 'ylim', [0 1])
        end
        hbar_off = bar(lags, c);
        set(hbar_off, 'facecolor', color_select(1,:),'FaceAlpha',0.5,'EdgeAlpha',0)
        
        %online
        [c, lags] = xcorr(kutime2_on, 25); % max lag 25 ms
        c(lags==0)=0;
        xlim([-25 25]);
        if median(c)>1
            set(gca,'xtick', [-50:10:50], 'ytick', [0 median(c)])
        else
            set(gca,'xtick', [-50:10:50], 'ytick', [0 1], 'ylim', [0 1])
        end
        hbar_on = bar(lags, c);
        set(hbar_on, 'facecolor',color_select(2,:),'FaceAlpha',0.5,'EdgeAlpha',0)
        xlabel('Lag(ms)'); set(gca,'xtickLabelMode','auto');
        
        %% cross-covariance between online and offline, 1ms bin
        axes('Position',[.5 .75 .2 .15])
        hold on
        [c, lags]=xcov(kutime2_on,kutime2_off,25,'normalized');
        
        xlim([-25 25]);
        if median(c)>1
            set(gca,'xtick', [-50:10:50], 'ytick', [0 median(c)])
        else
            set(gca,'xtick', [-50:10:50], 'ytick', [0 1], 'ylim', [0 1])
        end
        hbar = bar(lags, c);
        set(hbar, 'facecolor','k','FaceAlpha',0.8,'EdgeAlpha',0)
        xlabel('Lag(ms)'); set(gca,'xtickLabelMode','auto');
        ylim([-0.05 0.05])
        yticks([-0.05,0.05])
        yticklabels({'-0.05','0.05'});
        
        %% online vs offline
        %         xmin=[100000,300000,800000,1000000];
        axes('Position',[.75 .75 .2 .15])
        hold on
        %p(a|b) and p(b|a)
        online_spikes_t=Data.UnitsOnline.SpikeTimes{index_u_online};
        offline_spikes_t=Data.UnitsOffline.SpikeTimes{index_u};
        count_same=0;
        for ii=1:length(offline_spikes_t)
            tt=min(abs(offline_spikes_t(ii)-online_spikes_t));
            if tt<1  %1ms threshold
                count_same=count_same+1;
            end
        end
        p_off_in_on=count_same/length(offline_spikes_t)*100;
        count_same=0;
        for ii=1:length(online_spikes_t)
            tt=min(abs(online_spikes_t(ii)-offline_spikes_t));
            if tt<1  %1ms threshold
                count_same=count_same+1;
            end
        end
        p_on_in_off=count_same/length(online_spikes_t)*100;
        b=barh([p_on_in_off,p_off_in_on],'EdgeAlpha',0.5,'FaceAlpha',0.5);
        b.FaceColor = 'flat';
        b.CData(1,:) = color_select(1,:);
        b.CData(2,:) = color_select(2,:);
        xlim([0 100])
        plot([70 70],[0 3],'k--')
        text(5,1,'offline in online','HorizontalAlignment','left','FontSize',8)
        text(5,2,'online in offline','HorizontalAlignment','left','FontSize',8)
        xticklabels(["0","50","100"]);
        xlabel('percentage, %');
        yticklabels('');
        text(72,0.2,'70','HorizontalAlignment','left','FontSize',6);
        
        
        %% psth
        bootci_input=struct('Align',[],'CH',[],'U',[],'Firing',[]);
        for ii=1
            bootci_input(1)=struct('Align','TRIALSTART','CH',units(i,1),'U',units(i,2),'Firing',[]);
        end
        
        psth_data=struct('Align',[],'CH',[],'U',[],'Baselineon',[],'Trialstart',[],'Hittarget',[],'Spiketime',[]);
        
        % set up
        align_tag='TRIALSTART';
        t1=tic();
        totaltime=Data.Meta.Nev.DataDurationSec;
        x=1:1:totaltime*1000-1;
        [timestamp_trialstart,timestamp_hittarget,timestamp_portready,timestamp_portback] = get_timestamps_st3(Data);
        xmin=-5000; xmax=7000;
        timestamp_align=timestamp_trialstart; %define which to align
        indext=find(timestamp_hittarget>0);
        disp(['load data time=' num2str(toc(t1)) 's'])
        t1=tic();

        %% get spike data
        
        spikes_u=offline_spikes_t;
        CH_smooth=sdf_smooth(x,spikes_u,100)';
        bootci_t=[];
        
        % store data
        for iiii=1:length(indext) %each trial
            ii=round(indext(iiii));
            t=spikes_u;
            align=timestamp_align(ii);
            t=t(t>align+xmin & t<align+xmax)-align; %spike lines to plot
            tt=struct('Align',align_tag,'CH',units(i,1),'U',units(i,2),...
                'Baselineon',[],'Trialstart',timestamp_trialstart(ii)-align,...
                'Hittarget',timestamp_hittarget(ii)-align,'Spiketime',t);
            psth_data(end+1)=tt;
            
            t_left=max(1,round(align+xmin));
            t_right=min(round(align+xmax),length(CH_smooth));
            
            bootci_t=[bootci_t,[zeros(max(0,t_left-round(align+xmin)),1);CH_smooth(t_left:t_right)';zeros(max(0,t_right-length(CH_smooth)),1)]];
        end
        bootci_input(1).Firing=bootci_t;
        disp(['record raster time=' num2str(toc(t1)) 's'])
        t1=tic();
        psth_data=psth_data(2:end);
        
        %% sort by what?
        t=[];
        for ii=1:length(psth_data)
            t=[t;psth_data(ii).Hittarget-psth_data(ii).Trialstart];
        end
        t=[t,(1:length(t))'];
        t=sortrows(t,1);
        indext=t(:,2);
        
        %% plot
        axes('Position',[.07 .4 .86 .25]);
        set(gca,'FontSize',8);
        hold on;
        xlim([xmin,xmax])
        ylim([0.4,length(indext)+0.6])
        yticks([1 length(indext)])
        
        %% plot spikes
        counts=0;
        for ii=1:length(indext); counts=counts+length(psth_data(indext(ii)).Spiketime); end
        xpoints=nan(3,counts); ypoints=xpoints;
        counts=0;
        for ii=1:length(indext)
            t=psth_data(indext(ii)).Spiketime;
            xpoints(1:2,counts+1:counts+length(t))=[t;t];
            ypoints(1:2,counts+1:counts+length(t))=ones(2,length(t)).*[ii-0.5;ii+0.5];
            counts=counts+length(t);
        end
        xpoints=reshape(xpoints,1,counts*3); ypoints=reshape(ypoints,1,counts*3);
        plot(xpoints,ypoints,'color','k');
        
        %% plot events
        for ii=1:length(indext)
            line([0,0]+psth_data(indext(ii)).Trialstart,ii+[-0.5 0.5],'color','g','linewidth',1);
            line([0,0]+psth_data(indext(ii)).Hittarget,ii+[-0.5 0.5],'color','m','linewidth',1);
        end
        disp(['raster plot time=' num2str(toc(t1)) 's'])
        t1=tic();
        
        %% boot ci and firing rate
        axes('Position',[.07 .1 .86 .25]);
        set(gca,'FontSize',8);
        hold on;
        xlim([xmin,xmax])
        ylim([0,30])
        boot_cycle=500;
        t=bootci_input(1).Firing;
        unit_95ci=bootci(boot_cycle,{@(x) mean(x),t'},'Alpha',0.05);
        shadedErrorBar(xmin:1:xmax,mean(t')',abs([unit_95ci(2,:)-mean(t'); unit_95ci(1,:)-mean(t')]),'lineprops',{'color','k'});
        disp(['bootci time=' num2str(toc(t1)) 's'])
        
        line([0,0],[0,55],'color','g','linewidth',1)
        xlabel(['time aligned to ' lower(align_tag) '/ms'])
        
        % title
        axes('Position',[0.45,0.87,0.1,0.05])
        axis off
        title([animal '-' session '-CH' num2str(units(i,1)) 'U' num2str(units(i,2))],'fontsize',10)
        savefig(f,[pwd '\FIGS\s_seperate_psth_st3\' animal '-' session '\CH' num2str(units(i,1)) 'U' num2str(units(i,2))])
        saveas(f,[pwd '\FIGS\s_seperate_psth_st3\' animal '-' session '\CH' num2str(units(i,1)) 'U' num2str(units(i,2)) '.png'])
        
    end
    close(f)
end
end


