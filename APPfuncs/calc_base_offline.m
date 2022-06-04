function [mean_base,std_base]=calc_base_offline(Data)
mean_base=[];
std_base=[];

[timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2];
negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2];
totaltime=Data.Meta.Nev.DataDurationSec;
xt=25:50:totaltime*1000-1;
spikes=Data.UnitsOnline;
index_u=find(spikes.SpikeNotes(:,1)==positives(1) & spikes.SpikeNotes(:,2)==positives(2));
index_u=spikes.SpikeNotes(index_u,3);
spikes_pos=Data.UnitsOffline.SpikeTimes{index_u};
spikes=Data.UnitsOnline;
index_u=find(spikes.SpikeNotes(:,1)==negatives(1) & spikes.SpikeNotes(:,2)==negatives(2));
index_u=spikes.SpikeNotes(index_u,3);
spikes_neg=Data.UnitsOffline.SpikeTimes{index_u};
ch_pos=movmean(hist(spikes_pos,xt)/0.05,3);
ch_neg=movmean(hist(spikes_neg,xt)/0.05,3);


for i=1:length(grading)
    pos_base=[];
    neg_base=[];
    t_first=grading(i)-2;
    for j=t_first:grading(i)
        t=ch_pos(xt>timestamp_baselinestart(j) & xt<timestamp_baselinestart(j)+3000);
        pos_base=[pos_base t];
        t=ch_neg(xt>timestamp_baselinestart(j) & xt<timestamp_baselinestart(j)+3000);
        neg_base=[neg_base t];
    end
    mean_base=[mean_base,[mean(pos_base);mean(neg_base)]];
    std_base=[std_base,[std(pos_base);std(neg_base)]];
end

end

