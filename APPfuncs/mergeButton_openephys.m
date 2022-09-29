function [allData,Behavior,Meta,Video,Online,Offline,ST]=mergeButton_openephys(path,args,OtherInformation)
%   mergeButton by bo, 20220830
%   2 input arguments
%   path: path of session data folder
%   args:     [event,online,offline,SU/MU,analog,video]
clear dir
openephys_data=load_open_ephys(path); %no continuous data on PC
f=dir([path,'ST*_*.mat']);  rulepath=[path, f.name];
Rule=load(rulepath);


Data=struct();
Data.Behavior=struct();
Data.Meta=struct();
Data.Video=struct();
Data.UnitsOnline=struct();
Data.UnitsOffline=struct();

%% Meta and Behavior Data
if args{1}
    Data.Meta.Rule=struct();
    Data.Meta.Rule.Channels=Rule.savedata.config.channels;
    Data.Meta.Rule.Units=Rule.savedata.config.units;
    Data.Meta.Rule.Mainconfig=Rule.savedata.mainconfig;
    Data.Meta.Rule.SmoothWeights=Rule.savedata.ruleconfig.ruleweights;
    if Rule.savedata.ruleconfig.IRstep==0
        Data.Meta.Rule.Train.IRtime=Rule.savedata.ruleconfig.IRtime;
    end
    
    Data.Meta.Nev=openephys_data.continuous.Header;
    Data.Meta.Nev.DataDurationSec=length(openephys_data.continuous.Timestamps)/openephys_data.continuous.Header.sample_rate;

    Data.Meta.Other=OtherInformation;
    
    if contains(rulepath,'ST3')
        ST='ST3';
%         [Data.Behavior.Labels,Data.Behavior.EventTimings,Data.Behavior.EventMarkers]=st3_parse_eventdata_20210702(nev.Data.SerialDigitalIO.TimeStampSec,nev.Data.SerialDigitalIO.UnparsedData);
        [Data.Behavior.Labels,Data.Behavior.EventTimings,Data.Behavior.EventMarkers]=st3_parse_eventdata_openephys(openephys_data.event.Timestamps,openephys_data.event.Data);
    else
        ST='ST4';
        [Data.Behavior.Labels,Data.Behavior.EventTimings,Data.Behavior.EventMarkers]=st4_parse_eventdata_openephys(openephys_data.event.Timestamps,openephys_data.event.Data);
    end
    Data.Behavior.EventTimings=Data.Behavior.EventTimings*1000; %ms
    Data.Behavior.LabelMarkers=1:length(Data.Behavior.Labels);
    
    Data.Behavior.RuleEvents={};%Rule.savedata.ruledata.rule1;
end

%% analog data
if args{5}
    % position
    Data.Behavior.Position=movmean(openephys_data.continuous.Data(4,:),300); %100ms smooth
    if length(Data.Behavior.Position)>10000000; Data.Behavior.Position=Data.Behavior.Position(1:30:end); end
    
    %weight
    t=openephys_data.continuous.Data(5,:);
    t=movmean(t,300);
    Data.Behavior.Weight=t(1:30:end); %10ms smooth
end

%% online data
if args{2}
    t0=openephys_data.continuous.Timestamps(1);
    Data.UnitsOnline.Definition=["channel id","unit id","offline index"];
    Data.UnitsOnline.SpikeNotes=[];
    Data.UnitsOnline.SpikeTimes={};
    Data.UnitsOnline.SpikeWaves={};
    
    for channelt=1:length(openephys_data.spike.SortedIndexes)
        t=unique(openephys_data.spike.SortedIndexes{channelt});
        for unitt=1:length(t)
            tt=openephys_data.spike.Timestamps{channelt}(openephys_data.spike.SortedIndexes{channelt}==t(unitt));
            ttt=openephys_data.spike.Waveforms{channelt}(openephys_data.spike.SortedIndexes{channelt}==t(unitt),:);
            Data.UnitsOnline.SpikeNotes=[Data.UnitsOnline.SpikeNotes; channelt, t(unitt), 0];
            Data.UnitsOnline.SpikeTimes{end+1}=tt*1000; %ms
            Data.UnitsOnline.SpikeWaves{end+1}=ttt;
        end
    end
end

%% offline data
if args{3}
    Data.UnitsOffline.Definition=["channel id","cluster id","online index","unclassified/SU/MU(0/1/2)"];
    Data.UnitsOffline.SpikeNotes=[];
    Data.UnitsOffline.SpikeTimes={};
    Data.UnitsOffline.SpikeWaves={};
    
    f=dir([path,'times_chdat_meansub*.mat']);
    f={f.name};
    new_spike_codes=0;
    if isempty(f)
        f=dir([path,'times_chdat*.mat']);
        f={f.name};
        new_spike_codes=1;
    end
    for i=1:length(f)
        FileName=f{i};
        if new_spike_codes
            channelt=str2num(FileName(12:end-4));
        else
            channelt=str2num(FileName(20:end-4));
        end
        load([path FileName]);
        for cluster=0:max(cluster_class(:,1))
            tspikes=(cluster_class(cluster_class(:,1)==cluster,2))';
%             t=tspikes(tspikes<nev.MetaTags.DataDurationSec*1000);
            t=tspikes(tspikes<openephys_data.spike.Timestamps{channelt}(end)*1000);
            tt=spikes(cluster_class(:,1)==cluster,:);
            Data.UnitsOffline.SpikeNotes=[Data.UnitsOffline.SpikeNotes; channelt, cluster, 0, 0];
            Data.UnitsOffline.SpikeTimes{end+1}=t+t0;
            Data.UnitsOffline.SpikeWaves{end+1}=tt;
        end
    end
end

%% offline vs online
if args{3} && args{2}
    %auto-check by cross-correlation of online vs offline spike trains
    %calc cross-corr, only calc units of same channel
    t_online=[]; offline_labels={}; online_labels={};
    for i=1:length(Data.UnitsOffline.SpikeNotes(:,1))
        for j=1:length(Data.UnitsOnline.SpikeNotes(:,1))
            if Data.UnitsOffline.SpikeNotes(i,1)==Data.UnitsOnline.SpikeNotes(j,1)
                t_online=[t_online j];
            end
        end
    end
    t_online=unique(t_online);
    cross_corr_onoff=NaN(length(Data.UnitsOffline.SpikeNotes),length(t_online));
    for i=1:length(Data.UnitsOffline.SpikeNotes)
        for j=1:length(t_online)
            if Data.UnitsOffline.SpikeNotes(i,1)==Data.UnitsOnline.SpikeNotes(t_online(j),1) && Data.UnitsOffline.SpikeNotes(i,2)~=0 && Data.UnitsOnline.SpikeNotes(t_online(j),2)~=0
                %calc p(a in b)
                online_spikes_t=Data.UnitsOnline.SpikeTimes{t_online(j)};
                offline_spikes_t=Data.UnitsOffline.SpikeTimes{i};
                if length(offline_spikes_t)/range(offline_spikes_t)*1000>40 || length(offline_spikes_t)>3*length(online_spikes_t) %speed up
                    cross_corr_onoff(i,j)=0;
                else
                    tt1=tic;
                    count_same=0;
                    for ii=1:length(offline_spikes_t)
                        tt=min(abs(offline_spikes_t(ii)-online_spikes_t));
                        if tt<1  %1ms threshold
                            count_same=count_same+1;
                        end
                    end
                    p_off_in_on=count_same/length(offline_spikes_t);
                    count_same=0;
                    for ii=1:length(online_spikes_t)
                        tt=min(abs(online_spikes_t(ii)-offline_spikes_t));
                        if tt<1  %1ms threshold
                            count_same=count_same+1;
                        end
                    end
                    p_on_in_off=count_same/length(online_spikes_t);
                    cross_corr_onoff(i,j)=p_on_in_off*p_off_in_on;
                    toc(tt1)
                end
                if length(offline_spikes_t)/range(offline_spikes_t)*1000>30 && cross_corr_onoff(i,j)<0.5 
                    %some fast-spiking neurons may be missed
                    cross_corr_onoff(i,j)=0;
                end
                %             cross_corr_onoff(i,j)=xcorr(Data.UnitsOffline.SpikeTimes{i},Data.UnitsOnline.SpikeTimes{t_online(j)},0);
            end
        end
    end
    % Criteria: ①offline unit is not a noise unit ②max(p_on_in_off*p_off_in_on) ③p_on_in_off*p_off_in_on>0.1
    for i=1:length(t_online)
        %     cross_corr_onoff(:,i)=(cross_corr_onoff(:,i)-nanmean(cross_corr_onoff(:,i)))/nanstd(cross_corr_onoff(:,i));
        t=cross_corr_onoff(:,i); tt=find(t==max(t));
        if cross_corr_onoff(tt,i)>0.1 %set by experience
            if Data.UnitsOffline.SpikeNotes(tt,3)>0
                ttt=find(t_online==Data.UnitsOffline.SpikeNotes(tt,3));
                if cross_corr_onoff(tt,i)>cross_corr_onoff(tt,ttt)
                    Data.UnitsOnline.SpikeNotes(Data.UnitsOffline.SpikeNotes(tt,3),3)=0;
                    Data.UnitsOffline.SpikeNotes(tt,3)=t_online(i);
                    Data.UnitsOnline.SpikeNotes(t_online(i),3)=tt;
                end
            else
                Data.UnitsOffline.SpikeNotes(tt,3)=t_online(i);
                Data.UnitsOnline.SpikeNotes(t_online(i),3)=tt;
            end
        end
    end
    for i=1:length(Data.UnitsOffline.SpikeNotes); offline_labels{end+1}=['CH' num2str(Data.UnitsOffline.SpikeNotes(i,1)) 'C' num2str(Data.UnitsOffline.SpikeNotes(i,2))]; end
    for i=t_online; online_labels{end+1}=['CH' num2str(Data.UnitsOnline.SpikeNotes(i,1)) 'U' num2str(Data.UnitsOnline.SpikeNotes(i,2))]; end
    flinshi=figure;
    h=heatmap(flinshi,cross_corr_onoff);
    h.XDisplayLabels=online_labels;
    h.YDisplayLabels=offline_labels;
    saveas(flinshi,[path 'online_offline.fig'])
    close(flinshi)
end

%% SU/MU
if args{4}
    f=fopen([path 'spike_config.txt']);
    st=fgetl(f);
    while ~feof(f)
        st=fgetl(f);
        t=split(st);
        for i=1:length(Data.UnitsOffline.SpikeNotes(:,1))
            if Data.UnitsOffline.SpikeNotes(i,1)==str2double(t{1}) && Data.UnitsOffline.SpikeNotes(i,2)==str2double(t{2})-1 %jsimpleclust ui starts at 1
                switch t{3}
                    case 'S'
                        Data.UnitsOffline.SpikeNotes(i,4)=1;
                    case 'M'
                        Data.UnitsOffline.SpikeNotes(i,4)=2;
                end
            end
        end
    end
end

%% video
if args{6}
    Data.Video.SideAviFile={};
    Data.Video.TopAviFile={};
    Data.Video.SideAviIndex=[];
    Data.Video.TopAviIndex=[];
    Data.Video.SideFrameIndex=[];
    Data.Video.TopFrameIndex=[];
    Data.Video.Side_tFrame=[];
    Data.Video.Top_tFrame=[];
    Data.Video.LEDRGBinVideo=[];
    
    side_avidir=dir([path,'Cam_00E60034525*.avi']);
    side_avidir={side_avidir.name};
    top_avidir=dir([path,'Cam_00E60034527*.avi']);
    if isempty(top_avidir)
        top_avidir=dir([path,'Cam_00E60034522*.avi']); %other side cam
    end
    top_avidir={top_avidir.name};
    
    for i=1:length(side_avidir)
        % side
        Data.Video.SideAviFile{end+1}=side_avidir{i};
        filev=[path,side_avidir{i}];
        vidObj = VideoReader(filev);
        if mod(vidObj.NumFrames,100)==0
            nFs=vidObj.NumFrames-1;
        else
            nFs=vidObj.NumFrames;
        end
        Data.Video.SideAviIndex=[Data.Video.SideAviIndex i*ones(1,nFs)];
        filev=[path,side_avidir{i}(1:end-4),'.txt'];
        fr=load(filev);
        fr=fr(1:end-1);
        if length(fr)/2>nFs;  fr=[fr(1:nFs);fr(length(fr)-nFs:end-1)]; end
        for j=1:length(fr)/2
            Data.Video.Side_tFrame=[Data.Video.Side_tFrame fr(j)];
            Data.Video.SideFrameIndex=[Data.Video.SideFrameIndex fr(j+length(fr)/2)];
        end
        
        % top
        Data.Video.TopAviFile{end+1}=top_avidir{i};
        filev=[path,top_avidir{i}];
        vidObj = VideoReader(filev);
        if mod(vidObj.NumFrames,100)==0
            nFs=vidObj.NumFrames-1;
        else
            nFs=vidObj.NumFrames;
        end
        Data.Video.TopAviIndex=[Data.Video.TopAviIndex i*ones(1,nFs)];
        filev=[path,top_avidir{i}(1:end-4),'.txt'];
        fr=load(filev);
        fr=fr(1:end-1);
        if length(fr)/2>nFs;  fr=[fr(1:nFs);fr(length(fr)-nFs:end-1)]; end
        for j=1:length(fr)/2
            Data.Video.Top_tFrame=[Data.Video.Top_tFrame fr(j)];
            Data.Video.TopFrameIndex=[Data.Video.TopFrameIndex fr(j+length(fr)/2)];
        end
    end
    t=[Data.Video.SideAviIndex',Data.Video.SideFrameIndex',Data.Video.Side_tFrame'];
    tt=sortrows(t,3);
    Data.Video.SideAviIndex=tt(:,1)'; Data.Video.SideFrameIndex=tt(:,2)';  Data.Video.Side_tFrame=tt(:,3)';
    t=[Data.Video.TopAviIndex',Data.Video.TopFrameIndex',Data.Video.Top_tFrame'];
    tt=sortrows(t,3);
    Data.Video.TopAviIndex=tt(:,1)'; Data.Video.TopFrameIndex=tt(:,2)';  Data.Video.Top_tFrame=tt(:,3)';
    
    % extract light
%     filev=[path,side_avidir{1}];
%     vidObj = VideoReader(filev);
%     disp_frame = uint16(rgb2gray(read(vidObj,1)));
%     for i=1:101
%         vidframe =rgb2gray(read(vidObj,i));
%         %     disp_frame=(1-1/(floor(i/10)+1))*disp_frame+1/(floor(i/10)+1)*vidframe;
%         disp_frame=disp_frame+uint16(vidframe);
%     end
%     disp_frame=disp_frame*5;
%     roi_im=imshow(disp_frame,[]);
%     ROI=ginput(2);
%     ROI=round(ROI);
%     rectangle('Position',[min(ROI(:,1)),min(ROI(:,2)),abs(ROI(1,1)-ROI(2,1)),abs(ROI(1,2)-ROI(2,2))],'EdgeColor','r');
%     pause(1);
%     close(roi_im);
    ROI=[461,136;482,150]; %for Gary and Cocoa
    
    for j=1:length(side_avidir)
        filev=[path,side_avidir{j}];
        vidObj = VideoReader(filev);
        if mod(vidObj.NumFrames,100)==0
            nFs=vidObj.NumFrames-1; %reduce to 44999
        else
            nFs=vidObj.NumFrames;
        end
        
        % 提取亮灯帧数
        lightframe=zeros(1,nFs);
        gray=zeros(1,nFs);
        hwait=waitbar(0,['第 ' num2str(j) '/' num2str(length(side_avidir)) '个视频请等待>>>>>>>>']);
        count=0;
        
        for ii=1:nFs
            vidframes =rgb2gray(read(vidObj,ii));
            gray(ii)=mean(mean(vidframes(min(ROI(:,2)):max(ROI(:,2)),min(ROI(:,1)):max(ROI(:,1)))));
            count=count+1;
            if rem(fix(count*100/nFs),5)==0 && rem(fix((count-1)*100/nFs),5)~=0
                PerStr=fix(count*100/nFs);
                str=['第 ' num2str(j) '/' num2str(length(side_avidir)) '个正在运行中',num2str(PerStr),'%'];
                waitbar(count/nFs,hwait,str);
            end
        end
        
        close(hwait);
        
        for ii =2:nFs
            if gray(ii)>=200 && gray(ii)>2*gray(ii-1)
                lightframe(ii)=1;
            end
        end       
        Data.Video.LEDRGBinVideo=[Data.Video.LEDRGBinVideo gray];%lightframe];
    end
end

%% 
allData=Data;
Behavior=Data.Behavior;
Meta=Data.Meta;
Video=Data.Video;
Online=Data.UnitsOnline;
Offline=Data.UnitsOffline;
end

