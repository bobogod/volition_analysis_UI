function [labels,event_timing,event_marker]=st4_parse_eventdata_openephys(timestamp,events)
event_timing=timestamp;
event_marker=events;
labels=["FlashOnset","BaselineOffset","TrialStart","HitTarget","PortReady","PortBackOnset","ValveOnset","PokeOnset","IROffset","IROnset","Frame"];

event_marker(events==6)=11;
event_marker(events==5)=9;
event_marker(events==-5)=10; %get into IR zone
event_marker(events==3)=8;
event_marker(events==7)=1;
event_marker(events==1)=7;
event_timing=event_timing(event_marker>0);
event_marker=event_marker(event_marker>0);

count=0;
tindex=find(event_marker==4);
for i=1:length(tindex)
    event_marker(tindex(i))=4+count;
    count=mod(count+1,3);
end


count=0;
tindex=find(event_marker==2);
for i=1:length(tindex)
    event_marker(tindex(i))=2+count;
    count=mod(count+1,2);
end

end
