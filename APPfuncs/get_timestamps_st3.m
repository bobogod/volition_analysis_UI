function [timestamp_trialstart,timestamp_hittarget,timestamp_portready,timestamp_portback] = get_timestamps_st3(Data)
t=find(Data.Behavior.Labels=="TrialStart")
timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==t)';

timestamp_hittarget=zeros(1,length(timestamp_trialstart));
timestamp_portready=zeros(1,length(timestamp_trialstart));
timestamp_portback=zeros(1,length(timestamp_trialstart));
for j=1:length(timestamp_trialstart)
    if j<length(timestamp_trialstart)
        t=find(Data.Behavior.EventTimings>timestamp_trialstart(j) & Data.Behavior.EventTimings<timestamp_trialstart(j+1));
    else
        t=find(Data.Behavior.EventTimings>timestamp_trialstart(j));
    end
    tt=Data.Behavior.EventTimings(t);
    t=Data.Behavior.EventMarkers(t);
    ttt_hit=find(Data.Behavior.Labels=="HitTarget");
    ttt_reward=find(Data.Behavior.Labels=="PortReady");
    ttt_back=find(Data.Behavior.Labels=="PortBackOnset");
    t_hit=find(t==ttt_hit);  t_reward=find(t==ttt_reward); t_back=find(t==ttt_back);
    if ~isempty(t_hit);  timestamp_hittarget(j)=tt(t_hit);  end
    if ~isempty(t_reward);  timestamp_portready(j)=tt(t_reward);  end
    if ~isempty(t_back);  timestamp_portback(j)=tt(t_back);  end
end

if length(timestamp_portback)<length(timestamp_portready); timestamp_portready=timestamp_portready(1:length(timestamp_portback)); end
if length(timestamp_portback)<length(timestamp_hittarget); timestamp_hittarget=timestamp_hittarget(1:length(timestamp_portback)); end
if length(timestamp_portback)<length(timestamp_trialstart); timestamp_trialstart=timestamp_trialstart(1:length(timestamp_portback)); end
% grading=get_grading(timestamp_trialstart,timestamp_hittarget);

end

