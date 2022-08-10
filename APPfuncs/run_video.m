function run_video(animal,session,Data,path)
PathName=[path '\' animal '\' session '\'];
if ~exist([PathName 'video_clips'],'dir')
	mkdir([PathName 'video_clips']);
end

%% initialize spike data
positives=[Data.Meta.Rule.Channels(2) Data.Meta.Rule.Units(2)-2]; 
negatives=[Data.Meta.Rule.Channels(6) Data.Meta.Rule.Units(6)-2]; 
others=[];
for i=1:length(Data.UnitsOnline.SpikeNotes(:,1))
    if Data.UnitsOnline.SpikeNotes(i,3)>0
        if ~(Data.UnitsOnline.SpikeNotes(i,1)==positives(1) && Data.UnitsOnline.SpikeNotes(i,2)==positives(2))
            if ~(Data.UnitsOnline.SpikeNotes(i,1)==negatives(1) && Data.UnitsOnline.SpikeNotes(i,2)==negatives(2))
                others=[others;Data.UnitsOnline.SpikeNotes(i,1:2)];
            end
        end
    end
end
units=[positives;negatives;others];
OFFLINE=1
LEFT=-2000; RIGHT=2000; %display baseline-2s~hit+2s data


%% align video and blackrock using events
AllFrameTimesInB=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==find(Data.Behavior.Labels=="Frame"));
VideoIndex=[]; VideoTimesInB=[];
count=0; tflag=0; flag_record=0;
tt=[];

for i=1:length(AllFrameTimesInB)
    if ~tflag && sum(AllFrameTimesInB>AllFrameTimesInB(i) & AllFrameTimesInB<AllFrameTimesInB(i)+80000)>3980 %at least record 80s 3980frames
        tflag=1;
        flag_record=flag_record+44999;
    end     
    if tflag
        count=count+1;
        if count<=flag_record
            VideoIndex=[VideoIndex Data.Video.SideAviIndex(count)];
            VideoTimesInB=[VideoTimesInB AllFrameTimesInB(i)];
        else
            count=count-1;
        end
    end
    if i<length(AllFrameTimesInB) && AllFrameTimesInB(i+1)-AllFrameTimesInB(i)>500
        tflag=0;
    end
end

%% check LED
LEDInB=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==find(Data.Behavior.Labels=="FlashOnset"));

%% get data
[timestamp_trialstart,timestamp_hittarget,timestamp_baselinestart,timestamp_portready,timestamp_portback,grading] = get_timestamps_new(Data);
timestamp_trialstart=timestamp_trialstart(grading);
timestamp_hittarget=timestamp_hittarget(grading);
timestamp_baselinestart=timestamp_baselinestart(grading);
position=Data.Behavior.Position;
max_weight=100*floor(max(Data.Behavior.Weight)/800)*0.75;

%% video processing
for tcount=1:length(timestamp_hittarget)
    %make sure the trial is entirely filmed
    t1=find(VideoTimesInB<timestamp_baselinestart(tcount)+LEFT);
    t2=find(VideoTimesInB>timestamp_baselinestart(tcount)+LEFT);
    if timestamp_hittarget(tcount)>0
        t3=find(VideoTimesInB<timestamp_hittarget(tcount)+RIGHT);
        t4=find(VideoTimesInB>timestamp_hittarget(tcount)+RIGHT);
    else
        t3=find(VideoTimesInB<timestamp_trialstart(tcount)+20000+RIGHT);
        t4=find(VideoTimesInB>timestamp_trialstart(tcount)+20000+RIGHT);
    end

    if ~isempty(t1) && ~isempty(t2) && ~isempty(t3) && ~isempty(t4) && VideoTimesInB(t2(1))-VideoTimesInB(t1(end))<500 && VideoTimesInB(t4(1))-VideoTimesInB(t3(end))<500 && VideoIndex(t3(end))==VideoIndex(t2(1))

        if timestamp_hittarget(tcount)>0
            i_first=find(VideoTimesInB<timestamp_baselinestart(tcount));
            if ~isempty(i_first); i_first=i_first(end)-100; end
            i_last=find(VideoTimesInB>timestamp_hittarget(tcount));
            if ~isempty(i_last); i_last=i_last(1)+100; end
        else
            i_first=find(VideoTimesInB<timestamp_baselinestart(tcount));
            if ~isempty(i_first); i_first=i_first(end)-100; end
            i_last=find(VideoTimesInB>timestamp_trialstart(tcount)+20000);
            if ~isempty(i_last); i_last=i_last(1)+100; end
        end

        if ~(isempty(i_first) || isempty(i_last))
            
            if timestamp_hittarget(tcount)>0
                tt=floor(timestamp_hittarget(tcount));
                pos=mean(position(tt+2000:tt+2500));
                if pos<1000
                    SELECT='hit min';
                else
                    SELECT='hit max';
                end
            else
                SELECT='failed';
            end

            F=struct('cdata', [], 'colormap', []);
            count=1;
            close all
            
            VideoInfo=struct();
            
            
            %% something unchanged across frames
            %a bug here
            if timestamp_hittarget(tcount)>0
                tflash=LEDInB(LEDInB>timestamp_baselinestart(tcount)+LEFT & LEDInB<timestamp_hittarget(tcount)+RIGHT);
                t=find((VideoTimesInB>timestamp_baselinestart(tcount)+LEFT & VideoTimesInB<timestamp_hittarget(tcount)+RIGHT));
            else
                tflash=LEDInB(LEDInB>timestamp_baselinestart(tcount)+LEFT & LEDInB<timestamp_trialstart(tcount)+20000+RIGHT);
                t=find((VideoTimesInB>timestamp_baselinestart(tcount)+LEFT & VideoTimesInB<timestamp_trialstart(tcount)+20000+RIGHT));
            end

            FlashFromVideo=[];
            for iii=t(1)-1:t(end)+1
                if Data.Video.LEDRGBinVideo(iii)>125 && Data.Video.LEDRGBinVideo(iii-1)<125
                    FlashFromVideo=[FlashFromVideo VideoTimesInB(iii)];
                end
            end
            tttt=[];
            for iii=1:length(FlashFromVideo)
                for jjj=1:length(tflash)
                    if abs(FlashFromVideo(iii)-tflash(jjj))<100
                        tttt=[tttt FlashFromVideo(iii)-tflash(jjj)];
                    end
                end
            end
            %                 FlashFromVideo=FlashFromVideo(1:min(length(FlashFromVideo),length(tflash)));
            %                 tflash=tflash(1:min(length(FlashFromVideo),length(tflash)));
            delta=mean(tttt);
            
            
            %% fig properties
            f=figure(12);f.Color=[1,1,1]; f.Renderer='opengl'; clf
            set(f, 'units', 'centimeters', 'position', [3 1 23 16])
            colormap('gray')
            %% cam configuration            
            %top cam
            ha2= axes; cla
            set(ha2, 'units', 'centimeters', 'position', [11.5 7.5 10 8], 'nextplot', 'add', 'xlim',[0 1280], 'ylim', [0 1024], 'ydir','reverse')
            axis off
            set(ha2,'XDir','reverse')
            hold (ha2,'on');
            
            %side cam
            ha4= axes; cla
            set(ha4, 'units', 'centimeters', 'position', [1.5 7.5 10 8], 'nextplot', 'add', 'xlim',[0 1280], 'ylim', [0 1024], 'ydir','reverse')
            axis off
            hold(ha4,'on')
            
            text0=text(30,40,animal,'color', [246 233 35]/255, 'fontsize', 10);
            text1=text(30,90,session, 'color', [246 233 35]/255, 'fontsize', 10);
            text2=text(30,135,['trial index=',num2str(grading(tcount))],'color', [246 233 35]/255, 'fontsize', 10);
            text3=text(30,225,SELECT, 'color', [246 233 35]/255, 'fontsize', 10);
                        
            %% event plot       
            ha5=axes; cla
            set(ha5, 'units', 'centimeters', 'position', [1.5 7 20 0.4]);
            hold(ha5,'on')
            axis off
            rectangle(ha5,'Position',[0,-0.8,3000,1.6],'facecolor',[0.85,1,0.7],'edgecolor',[0.85,1,0.7]);

            %event of prev/next trial
            if tcount>1
                rectangle(ha5,'Position',[timestamp_baselinestart(tcount-1)-timestamp_baselinestart(tcount),-0.8,3000,1.6],'facecolor',[0.85,1,0.7],'edgecolor',[0.85,1,0.7]);
                if timestamp_hittarget(tcount-1)>0
                    rectangle(ha5,'Position',[timestamp_trialstart(tcount-1)-timestamp_baselinestart(tcount),-0.8,timestamp_hittarget(tcount-1)-timestamp_trialstart(tcount-1),1.6],...
                        'facecolor',[0.7,1,0.85],'edgecolor',[0.7,1,0.85]);
                else
                    rectangle(ha5,'Position',[timestamp_trialstart(tcount-1)-timestamp_baselinestart(tcount),-0.8,20000,1.6],...
                        'facecolor',[0.7,1,0.85],'edgecolor',[0.7,1,0.85]);
                end
            end
            if tcount<length(timestamp_hittarget)
                rectangle(ha5,'Position',[timestamp_baselinestart(tcount+1)-timestamp_baselinestart(tcount),-0.8,3000,1.6],'facecolor',[0.85,1,0.7],'edgecolor',[0.85,1,0.7]);
                if timestamp_hittarget(tcount+1)>0
                    rectangle(ha5,'Position',[timestamp_trialstart(tcount+1)-timestamp_baselinestart(tcount),-0.8,timestamp_hittarget(tcount+1)-timestamp_trialstart(tcount),1.6],...
                        'facecolor',[0.7,1,0.85],'edgecolor',[0.7,1,0.85]);
                else
                    rectangle(ha5,'Position',[timestamp_trialstart(tcount+1)-timestamp_baselinestart(tcount),-0.8,20000,1.6],...
                        'facecolor',[0.7,1,0.85],'edgecolor',[0.7,1,0.85]);
                end
            end

            %event for current trial
            if timestamp_hittarget(tcount)>0
                rectangle(ha5,'Position',[timestamp_trialstart(tcount)-timestamp_baselinestart(tcount),-0.8,timestamp_hittarget(tcount)-timestamp_trialstart(tcount),1.6],...
                    'facecolor',[0.7,1,0.85],'edgecolor',[0.7,1,0.85]);
                xlim([LEFT timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)+RIGHT]);
            else
                rectangle(ha5,'Position',[timestamp_trialstart(tcount)-timestamp_baselinestart(tcount),-0.8,20000,1.6],...
                    'facecolor',[0.7,1,0.85],'edgecolor',[0.7,1,0.85]);
                xlim([LEFT timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000+RIGHT]);
            end
            ylim([-1 1])
            
            
            % flash event
            ha3=axes; cla
            set(ha3, 'units', 'centimeters', 'position', [1.5 5.3 20 1.6],'ytick',[]);
            hold(ha3,'on')
            
%             if ~isempty(tflash)
%                 xx = [tflash; tflash]-timestamp_baselinestart(tcount);
%                 yy =ones(2,length(tflash)).*[2.9; 2.9+0.2]-0.5;
%                 plot(ha3,xx, yy, 'm*')
%             end
            
            %% spikes
             for iii=1:length(units(:,1))
                 spikes=Data.UnitsOnline;
                 index_u=find(spikes.SpikeNotes(:,1)==units(iii,1) & spikes.SpikeNotes(:,2)==units(iii,2));
                 if OFFLINE
                     index_u=spikes.SpikeNotes(index_u,3);
                     spikes=Data.UnitsOffline;
                 end
                 tspikes=spikes.SpikeTimes{index_u};
                 tspikes=tspikes(tspikes>VideoTimesInB(i_first)+LEFT & tspikes<VideoTimesInB(i_last)+RIGHT);
                 
                 if iii<=length(positives(:,1)); c='r';
                 elseif iii<=length(positives(:,1))+length(negatives(:,1)); c='b';
                 else; c='k'; end %colors(iii-length(positives(:,1))-length(negatives(:,1)),:); end
                 
                 if ~isempty(tspikes)
                     xx = [tspikes; tspikes]-timestamp_baselinestart(tcount);
                     yy =[1+2/length(units(:,1))*(length(units(:,1))-iii)+0.1; 1+2/length(units(:,1))*(length(units(:,1))-iii+1)-0.1]-0.5-0.1;
                     plot(ha3,xx, yy, 'color',c, 'linewidth', 0.5)
                 end
             end
             %     tflash=Data.SerialDigitalIO.ParsedData.timestamp;
             %     tflash=tflash(tflash(:,3)==1,1)*1000;
             
            %% position plot
             ha6=axes;cla
             set(ha6, 'units', 'centimeters', 'position', [1.5 3.4 20 1.7],'ytick',[]);
             t1=round(VideoTimesInB(i_first)+LEFT); t2=round(VideoTimesInB(i_last)+RIGHT);
             t=Data.Behavior.Position(t1:t2); t=t-min(t); t=t/max(t);
             if t(end)>t(1); t=(t-min(t))/(max(t)-min(t));
             else;           t=(t-max(t))/(max(t)-min(t)); end
             plot((t1:t2)-timestamp_baselinestart(tcount),t,'k','LineWidth',1.5);
             
             
            %% load_cell plot
             ha7=axes;cla
             set(ha7, 'units', 'centimeters', 'position', [1.5 1.3 20 2],'ytick',[]);
             t1=round(VideoTimesInB(i_first)+LEFT); t2=round(VideoTimesInB(i_last)+RIGHT);
             t=Data.Behavior.Weight(t1:t2); t=t-min(t); %t=t/max(t);
             plot((t1:t2)-timestamp_baselinestart(tcount),t/800*100,'k','LineWidth',1.5);
             
            %% other plots
             xlabel(ha7,'time/ms')
             ylabel(ha7,'load cell')
             ylabel(ha6,'port position')
             ylabel(ha3,'Neuron #')
             line(ha3,[0 0],[0 2.7],'color',[0.85,1,0.7]*0.85,'linewidth',0.5)
             line(ha3,[3000 3000],[0 2.7],'color',[0.85,1,0.7]*0.85,'linewidth',0.5)
             line(ha6,[0 0],[-1 2.7],'color',[0.85,1,0.7]*0.85,'linewidth',0.5)
             line(ha6,[3000 3000],[-1 2.7],'color',[0.85,1,0.7]*0.85,'linewidth',0.5)
             line(ha7,[0 0],[0 max_weight],'color',[0.85,1,0.7]*0.85,'linewidth',0.5)
             line(ha7,[3000 3000],[0 max_weight],'color',[0.85,1,0.7]*0.85,'linewidth',0.5)
             line(ha3,[1 1]*(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)),[0 2.7],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)             
             line(ha6,[1 1]*(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)),[-1 2.7],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)             
             line(ha7,[1 1]*(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)),[0 max_weight],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
             if timestamp_hittarget(tcount)>0
                 set(ha3,'xlim',[LEFT timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)+RIGHT],'ylim',[0 2.5],'ytick','','xtick','')
                 set(ha6,'xlim',[LEFT timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)+RIGHT],'ylim',[-1 1],'ytick','','box','off','XTickLabel',[])
                 set(ha7,'xlim',[LEFT timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)+RIGHT],'ylim',[0 max_weight],'ytick','','box','off')
                 line(ha3,[1 1]*(timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)),[0 2.7],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
                 line(ha6,[1 1]*(timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)),[-1 2.7],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
                 line(ha7,[1 1]*(timestamp_hittarget(tcount)-timestamp_baselinestart(tcount)),[0 max_weight],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
                 text(ha7,(timestamp_hittarget(tcount)-timestamp_baselinestart(tcount))+50,0.9*max_weight,'hit target','color',[0.7,1,0.85]*0.6,'fontsize',10)
             else
                 set(ha3,'xlim',[LEFT timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000+RIGHT],'ylim',[0 2.5],'ytick','','xtick','')
                 set(ha6,'xlim',[LEFT timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000+RIGHT],'ylim',[-1 1],'ytick','','box','off','XTickLabel',[])
                 set(ha7,'xlim',[LEFT timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000+RIGHT],'ylim',[0 max_weight],'ytick','','box','off')
                 line(ha3,[1 1]*(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000),[0 2.7],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
                 line(ha6,[1 1]*(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000),[-1 2.7],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
                 line(ha7,[1 1]*(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000),[0 max_weight],'color',[0.7,1,0.85]*0.85,'linewidth',0.5)
                 text(ha7,(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000)+50,0.9*max_weight,'hit target','color',[0.7,1,0.85]*0.6,'fontsize',10)
             end

             text(ha7,50,0.9*max_weight,'baseline onset','color',[0.85,1,0.7]*0.6,'fontsize',10)
             text(ha7,2950,0.9*max_weight,'offset','color',[0.85,1,0.7]*0.6,'fontsize',10,'HorizontalAlignment','right')
             text(ha7,(timestamp_trialstart(tcount)-timestamp_baselinestart(tcount))+50,0.9*max_weight,'trial start','color',[0.7,1,0.85]*0.6,'fontsize',10)
             
                             
                
            %% variables
            time_text=text(ha4,30,180,num2str(VideoTimesInB(i_first)-timestamp_baselinestart(tcount)-delta,'%.0fms'), 'color', [246 233 35]/255, 'fontsize', 10);
            
            v_index=-1;
            i=i_first;
            if v_index~=Data.Video.TopAviIndex(i)
                v_index=Data.Video.TopAviIndex(i)
                v_top=VideoReader([PathName Data.Video.TopAviFile{v_index}]);
                v_side=VideoReader([PathName Data.Video.SideAviFile{v_index}]);
            end            
            %there is a bug here
            im_top=read(v_top,mod([i_first,i_last],44999));
            im_side=read(v_side,mod([i_first,i_last],44999));
            imsc_side=imagesc(ha4,im_side(:,:,1,1)*1.5);
            imsc_top=imagesc(ha2,im_top(:,:,1,1)*1.5);
%             imsc_side=imagesc(ha4,histeq(im_side,64)-50);
%             imsc_top=imagesc(ha2,histeq(im_top,64)-50);            
            set(ha4,'child',[text0,text1,text2,text3,time_text,imsc_side])

            time_line_2=line(ha3,[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta),[0 2.5],'color','k');
            time_line_1=line(ha5,[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta),[-0.9 0.9],'color','k');
            time_line_3=line(ha6,[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta),[-1 1],'color','k');
            time_line_4=line(ha7,[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta),[0 max_weight],'color','k');
            
            drawnow limitrate
            pause(0.001)
            
            %% update frames
            v_index=-1;
            for i=i_first+1:i_last
                if v_index~=Data.Video.TopAviIndex(i)
                    v_index=Data.Video.TopAviIndex(i)
                    v_top=VideoReader([PathName Data.Video.TopAviFile{v_index}]);
                    v_side=VideoReader([PathName Data.Video.SideAviFile{v_index}]);
                end
                
                %there is a bug here
%                 im_top=read(v_top,mod(i,44999));
%                 im_side=read(v_side,mod(i,44999));
                imsc_top.CData=im_top(:,:,1,i-i_first+1)*1.5;
                imsc_side.CData=im_side(:,:,1,i-i_first+1)*1.5;
%                 imsc_top.CData=histeq(im_top,64)-50;
%                 imsc_side.CData=histeq(im_side,64)-50;
                
                time_text.String=num2str(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta,'%.0fms');
                time_line_1.XData=[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta);
                time_line_2.XData=[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta);
                time_line_3.XData=[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta);
                time_line_4.XData=[1,1]*(VideoTimesInB(i)-timestamp_baselinestart(tcount)-delta);
                drawnow limitrate
                F(count)=getframe(f);
                count=count+1;
            end
            
            if timestamp_hittarget(tcount)>0
                writerObj = VideoWriter([PathName 'video_clips\trial' num2str(grading(tcount),'%03d') '.avi']);
            else
                writerObj = VideoWriter([PathName 'video_clips\trial' num2str(grading(tcount),'%03d') '_fail.avi']);
            end
            writerObj.FrameRate = 20; % this is 2.5 x slower
            open(writerObj);
            % write the frames to the video
            for i=1:length(F)
                % convert the image to a frame
                frame = F(i) ;
                writeVideo(writerObj, frame);
            end
            % close the writer object
            close(writerObj);
            close all
            
            %save mat
            VideoInfo.AnimalName=animal;
            VideoInfo.Session=session;
            VideoInfo.EventAlign='BaselineOnset';
            VideoInfo.t_pre=LEFT; 
            if timestamp_hittarget(tcount)>0
                VideoInfo.t_post=RIGHT+timestamp_hittarget(tcount)-timestamp_baselinestart(tcount);
            else
                VideoInfo.t_post=RIGHT+timestamp_trialstart(tcount)-timestamp_baselinestart(tcount)+20000;
            end
            VideoInfo.Time=timestamp_baselinestart(tcount);
            VideoInfo.VideoFrameIndex=i_first:i_last;
            VideoInfo.VideoFrameTimeInB=VideoTimesInB(i_first:i_last);
            VideoInfo.Performance=SELECT;
            VideoInfo.AllOfflineUnits=Data.UnitsOffline;
            t1=round(VideoTimesInB(i_first)+LEFT); t2=round(VideoTimesInB(i_last)+RIGHT);
            VideoInfo.Weight=Data.Behavior.Weight(t1:t2);

            if timestamp_hittarget(tcount)>0
                save([PathName 'video_clips\videoinfo_trial' num2str(grading(tcount),'%03d') '.mat'],'VideoInfo');
            else
                save([PathName 'video_clips\videoinfo_trial' num2str(grading(tcount),'%03d') '_fail.mat'],'VideoInfo');
            end
        end
        
    end
end
end
