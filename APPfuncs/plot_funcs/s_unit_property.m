function s_unit_property(animal,session,Data)
%   unit_property for single session, by bo, 20220418
%   3 input arguments, 0 output arguments, 1 FIG saved
%   animal: animal name
%   session: date
%   Data: merged data for a single session
%%
colors={'m','c','y',[0.49,0.18,0.56]};
units=[];
for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
    if Data.UnitsOnline.SpikeNotes(i,3)>0
        units=[units; Data.UnitsOnline.SpikeNotes(i,1:2)];
    end
end



thiscolor = [0 0 0];
f=figure; f.Color='w';
% len=length(positives(:,1))+length(negatives(:,1))+length(others(:,1));
len=length(units(:,1));
ha=tight_subplot(1+len,4,[.01 .03],[.1 .1],[.1 .1],...
    zeros(4*(len)),ones(4*(len+1)));%[0,0,0,0,1,1],[1,1,1,1,1,1]);
color_select=Dark2(10);

%%
for i=1:length(units(:,1))
    spikes=Data.UnitsOnline; CHANNEL=units(i,1); UNIT=units(i,2);
    index_u=find(spikes.SpikeNotes(:,1)==CHANNEL & spikes.SpikeNotes(:,2)==UNIT);
    index_u_online=index_u;
    index_u=spikes.SpikeNotes(index_u,3);
%     index_u
    if index_u
        offline_spikes_t=Data.UnitsOffline.SpikeTimes{index_u}; 
        mean_firing_rate=length(offline_spikes_t)/Data.Meta.Nev.DataDurationSec;
    end
    if index_u % && mean_firing_rate<30        
        %% plot waveform
        axes(ha(i*4-3));hold on
        
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
        if i==1; title('offline waveform'); end
        
        %online
%         allwaves=Data.UnitsOnline.SpikeWaves{index_u_online};
%         allwaves=allwaves([1:46],:)';
%         if size(allwaves, 1)>10000
%             nplot = randperm(size(allwaves, 1), 10000);
%         else
%             nplot=[1:size(allwaves, 1)];
%         end;
%         wave2plot = allwaves(nplot, :);
%         plot([10:55], mean(allwaves, 1), 'color', colors{UNIT}, 'linewidth', 2)
        
        
        %axis properties
        axis([0 65 -1600 800])
        axis tight
        %     line([30 60], min(get(gca, 'ylim')), 'color', 'k', 'linewidth', 2.5)
        axis off
        xlim([0 64])
        text(0,0,{['CH',num2str(CHANNEL),'U',num2str(UNIT)],num2str(mean_firing_rate)},'HorizontalAlignment','right','FontSize',6.5)
        line([2,2],[-800 -400],'Color','k','LineWidth',1);
        text(3,-600,'100μv','HorizontalAlignment','left','FontSize',6);
        set (gca, 'ylim', [-1600 800])
        
        
        %% plot autocorrelation, 1ms bin
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
        axes(ha(i*4-2));hold on
        xlim([-25 25]);
        if median(c)>1
            set(gca,'xtick', [-50:10:50], 'ytick', [0 median(c)])
        else
            set(gca,'xtick', [-50:10:50], 'ytick', [0 1], 'ylim', [0 1])
        end
        hbar_off = bar(lags, c);
        set(hbar_off, 'facecolor', color_select(1,:),'FaceAlpha',0.5,'EdgeAlpha',0)
        if i==len;  xlabel('Lag(ms)'); set(gca,'xtickLabelMode','auto'); end
        if i==1; title(Data.Meta.Nev.DateTime(1:11)); end
        
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
        if i==len;  xlabel('Lag(ms)'); set(gca,'xtickLabelMode','auto'); end
        if i==1; title('auto correlation'); end

        
        %% cross-covariance between online and offline, 1ms bin
        [c, lags]=xcov(kutime2_on,kutime2_off,25,'normalized');
%         c(26)=0;
        axes(ha(i*4-1));hold on
        xlim([-25 25]);
        if median(c)>1
            set(gca,'xtick', [-50:10:50], 'ytick', [0 median(c)])
        else
            set(gca,'xtick', [-50:10:50], 'ytick', [0 1], 'ylim', [0 1])
        end
        hbar = bar(lags, c);
        set(hbar, 'facecolor','k','FaceAlpha',0.8,'EdgeAlpha',0)
        if i==len;  xlabel('Lag(ms)'); set(gca,'xtickLabelMode','auto'); end
        if i==1; title('cross-covariance'); end
        ylim([-0.05 0.05])
        yticks([-0.05,0.05])
        yticklabels({'-0.05','0.05'});
        
        
        %% online vs offline
%         xmin=[100000,300000,800000,1000000];
        axes(ha(i*4));hold on
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
        %     xticklabels({'offline in online','online in offline'})
        %     ylabel('percentage,%')
        xlim([0 100])
        plot([70 70],[0 3],'k--')
        text(5,1,'offline in online','HorizontalAlignment','left','FontSize',8)
        text(5,2,'online in offline','HorizontalAlignment','left','FontSize',8)
        if i==1; title('overlap'); end
        if i==len;  xticklabels(["0","50","100"]); xlabel('percentage, %'); yticklabels(''); text(72,0.2,'70','HorizontalAlignment','left','FontSize',6); else; axis off; end
    else
        axes(ha(i*4-3));hold on
        axis([0 65 -1600 800])
        axis tight
        %     line([30 60], min(get(gca, 'ylim')), 'color', 'k', 'linewidth', 2.5)
        axis off
        xlim([0 64])
        text(0,0,['CH',num2str(CHANNEL),'U',num2str(UNIT)],'HorizontalAlignment','right','FontSize',6.5)
        line([2,2],[-800 -400],'Color','k','LineWidth',1);
        text(3,-600,'100μv','HorizontalAlignment','left','FontSize',6);
        set (gca, 'ylim', [-1600 800])
        if i==1; title('offline waveform'); end
        axes(ha(i*4-2));
        if i==1; title('autocorrelation'); end
        axis off
        axes(ha(i*4-1));
        if i==1; title('cross-correlation'); end
        axis off
        axes(ha(i*4));
        if i==1; title('overlap'); end
        axis off
    end
end
axes(ha(len*4+1)); axis off; hold on
hb1=bar(0,1); set(hb1, 'facecolor',color_select(1,:),'FaceAlpha',0.5,'EdgeAlpha',0,'ShowBaseLine','off')
hb2=bar(0,1); set(hb2, 'facecolor',color_select(2,:),'FaceAlpha',0.5,'EdgeAlpha',0,'ShowBaseLine','off')
xlim([10,11]);
legend([hb1,hb2],{'offline','online'},'Location','west','Orientation','horizontal','box','off');
axes(ha(len*4+2)); axis off;
axes(ha(len*4+3)); axis off;
axes(ha(len*4+4)); axis off;
supt=suptitle(Data.Meta.Nev.DateTime(1:11));
set(supt,'FontSize',10)

savefig(f,[pwd '\FIGS\s_unit_property\' animal '-' session])
pause(5)
close(f)
end

