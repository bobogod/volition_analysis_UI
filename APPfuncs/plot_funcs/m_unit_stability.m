function m_unit_stability(animal,DataPaths)
% positives=[7,1];
% negatives=[8,1];
% others=[3,2;3,3;8,2;10,1];
% colors={'m','c','y',[0.49,0.18,0.56]};
% units=[9,1;9,3;10,1;14,2];
mean_waveforms=cell(1,length(DataPaths));
acgs=cell(1,length(DataPaths));

for index=1:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
    negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
    others=[];
    units=[positives;negatives;others]
    
    %     f=figure; f.Color='w';
    spikes=Data.UnitsOnline;
    index_u=find(spikes.SpikeNotes(:,1)==positives(1) & spikes.SpikeNotes(:,2)==positives(2));
    index_u=spikes.SpikeNotes(index_u,3);
    if index_u
        allwaves=Data.UnitsOffline.SpikeWaves{index_u};
        allwaves= allwaves(:, [1:64]);
        kutime = floor(Data.UnitsOffline.SpikeTimes{index_u});
        
        kutime2 = zeros(1, round(max(kutime)));
        kutime2(kutime)=1;
        [c, lags] = xcorr(kutime2, 25); % max lag 100 ms
        c(lags==0)=0;
        acgs{index}=zscore(c);
        
        mean_waveforms{index}=mean(allwaves, 1);
        %             plot([1:64],mean(allwaves, 1) , 'linewidth', 0.8,'color',[0.8,0,0]*(index/length(Data))+[0,0.8,0]*(1-index/length(Data)));
        %             hold on
    end
end
%     title(['CH',num2str(CHANNEL),'U',num2str(UNIT)])
%     ylim([-1200 600])


%% waveform similarity
all_corr=zeros(length(DataPaths),length(DataPaths));
xticklabels_my={};
for index=1:length(DataPaths)
    for index2=1:length(DataPaths)
        if ~isempty(mean_waveforms{index}) && ~isempty(mean_waveforms{index2})
            t=corrcoef(mean_waveforms{index},mean_waveforms{index2});
            all_corr(index,index2)=t(2,1);
        else
            all_corr(index,index2)=NaN;
        end
    end
    xticklabels_my{end+1}=DataPaths{index}(end-23:end-20);
end

figure
h=heatmap(all_corr,'colormap',autumn);
h.XDisplayLabels=xticklabels_my;
h.YDisplayLabels=xticklabels_my;
set(gcf,'Color','w')
title('positive unit - Pearson of Waveform')




%% autocorrelogram similarity 
all_distance=zeros(length(DataPaths),length(DataPaths));
for index=1:length(DataPaths)
    for index2=1:length(DataPaths)
        t1=acgs{index}; t2=acgs{index2};
        if ~isempty(t1) && ~isempty(t2)
            all_distance(index,index2)=((t1-t2)*(t1-t2)'/length(t1));
        else
            all_distance(index,index2)=NaN;
        end
    end
end
figure
h2=heatmap(all_distance,'colormap',flipud(autumn));
h2.XDisplayLabels=xticklabels_my;
h2.YDisplayLabels=xticklabels_my;
set(gcf,'Color','w')
title('positive unit - Distance of autocorrelogram')









%%%%%%%%% negative
mean_waveforms=cell(1,length(DataPaths));
acgs=cell(1,length(DataPaths));

for index=1:length(DataPaths)
    Data=load(DataPaths{index}).Data;
    positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
    negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
    others=[];
    units=[positives;negatives;others]
    
    %     f=figure; f.Color='w';
    spikes=Data.UnitsOnline;
    index_u=find(spikes.SpikeNotes(:,1)==negatives(1) & spikes.SpikeNotes(:,2)==negatives(2));
    index_u=spikes.SpikeNotes(index_u,3);
    if index_u
        allwaves=Data.UnitsOffline.SpikeWaves{index_u};
        allwaves= allwaves(:, [1:64]);
        kutime = floor(Data.UnitsOffline.SpikeTimes{index_u});
        
        kutime2 = zeros(1, round(max(kutime)));
        kutime2(kutime)=1;
        [c, lags] = xcorr(kutime2, 25); % max lag 100 ms
        c(lags==0)=0;
        acgs{index}=zscore(c);
        
        mean_waveforms{index}=mean(allwaves, 1);
        %             plot([1:64],mean(allwaves, 1) , 'linewidth', 0.8,'color',[0.8,0,0]*(index/length(Data))+[0,0.8,0]*(1-index/length(Data)));
        %             hold on
    end
end
%     title(['CH',num2str(CHANNEL),'U',num2str(UNIT)])
%     ylim([-1200 600])


%% waveform similarity
all_corr=zeros(length(DataPaths),length(DataPaths));
xticklabels_my={};
for index=1:length(DataPaths)
    for index2=1:length(DataPaths)
        if ~isempty(mean_waveforms{index}) && ~isempty(mean_waveforms{index2})
            t=corrcoef(mean_waveforms{index},mean_waveforms{index2});
            all_corr(index,index2)=t(2,1);
        else
            all_corr(index,index2)=NaN;
        end
    end
    xticklabels_my{end+1}=DataPaths{index}(end-23:end-20);
end

figure
h3=heatmap(all_corr,'colormap',autumn);
h3.XDisplayLabels=xticklabels_my;
h3.YDisplayLabels=xticklabels_my;
set(gcf,'Color','w')
title('negative unit - Pearson of Waveform')




%% autocorrelogram similarity 
all_distance=zeros(length(DataPaths),length(DataPaths));
for index=1:length(DataPaths)
    for index2=1:length(DataPaths)
        t1=acgs{index}; t2=acgs{index2};
        if ~isempty(t1) && ~isempty(t2)
            all_distance(index,index2)=((t1-t2)*(t1-t2)'/length(t1));
        else
            all_distance(index,index2)=NaN;
        end
    end
end
figure
h4=heatmap(all_distance,'colormap',flipud(autumn));
h4.XDisplayLabels=xticklabels_my;
h4.YDisplayLabels=xticklabels_my;
set(gcf,'Color','w')
title('negative unit - Distance of autocorrelogram')

end

