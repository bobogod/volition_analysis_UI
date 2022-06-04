function [labels,event_timing,event_marker]=st4_parse_eventdata_20210702(timestamp,events)
% labels=[timestamp' zeros(length(timestamp),9)]; % [time digs]

% eventdata.timestamp=eventdata.timestamp(14899:end,:); %data 2021-01-24
event_timing=timestamp;
event_marker=zeros(1,length(timestamp));
labels=["FlashOnset","BaselineOffset","TrialStart","HitTarget","PortReady","PortBackOnset","ValveOnset","PokeOnset","IROffset","IROnset","Frame"];
dig_len=128; %10000000
dig=events-dig_len;
dig=dec2bin(dig);

bncin_count=0;
baseline_count=0;
for i=1:length(dig)
    if i==1; told='xxxxxxx';
    else; told=dig(i-1,:);
    end
    tnew=dig(i,:);
    for j=1:length(tnew)
        if tnew(j)~=told(j)
            if tnew(j)=='1'
                switch length(tnew)-j
                    case 0 %valve onset
                        event_marker(i)=7;
                    case 1 % trial start/baseline off
                        if baseline_count==0
                            event_marker(i)=2;
                            baseline_count=1;
                        else
                            event_marker(i)=3;
                            baseline_count=0;
                        end
                    case 2 % poke in
                        event_marker(i)=8;
                    case 3 % hit target/reward/back
                        switch mod(bncin_count,3)
                            case 0
                                event_marker(i)=4;
                            case 1
                                event_marker(i)=5;
                            case 2
                                event_marker(i)=6;
                        end
                        bncin_count=mod(bncin_count+1,3);
                    case 4 % IR out
                        event_marker(i)=9;
                    case 5 % frame
                        event_marker(i)=11;
                    case 6 % flash on
                        event_marker(i)=1;
                end
            else
                switch length(tnew)-j
                    case 4 % IR in
                        event_marker(i)=10;
                end
            end
        end
    end
    %     if i>1 && tnew(end)=='1' && eventdata.timestamp(i-1,2)==1 %if valve on lasts for more than 1
    %         eventdata.timestamp(i,2)=0;
    %     end
    
end

t=[]; tt=[];
for i=1:length(event_marker)
    if event_marker(i)>0
        t=[t event_timing(i)];
        tt=[tt event_marker(i)];
    end
end
event_timing=t;
event_marker=tt;
