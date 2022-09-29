path='G:\lab\volitional-BCI\Data';
% animal='Norman';
% session={'20220913SAL','20220915DCZ','20220916SAL','20220918DCZ','20220919SAL','20220921DCZ','20220922SAL','20220923DCZ'};
animal='Ray';
session={'20220913SAL','20220916SAL','20220918DCZ','20220919SAL','20220921DCZ','20220922SAL','20220923DCZ'};
% animal='Emma';
% session={'20220913','20220915','20220916','20220913DCZ','20220915DCZ','20220916DCZ','20220918','20220918SAL'};

%% load data
behavior=struct();
behavior_DCZ=struct();
behavior_SAL=struct();

for i=1:length(session)
    isDCZ=length(strfind(session{i},'DCZ'));
    isSAL=length(strfind(session{i},'SAL'));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    f=dir([path,'\',animal,'\',session{i},'\*BODATA*.mat']);
    if ~isempty(f) %contains ephys data
        datapath=[path,'\',animal,'\',session{i},'\',f.name];
        Data=load(datapath).Data;
        if isDCZ
            behavior_DCZ(end+1).load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10)/1000;
            behavior_DCZ(end).load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9)/1000;
            behavior_DCZ(end).timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3)/1000;
            behavior_DCZ(end).timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4)/1000;
        elseif isSAL
            behavior_SAL(end+1).load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10)/1000;
            behavior_SAL(end).load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9)/1000;
            behavior_SAL(end).timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3)/1000;
            behavior_SAL(end).timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4)/1000;
        else
            behavior(end+1).load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10)/1000;
            behavior(end).load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9)/1000;
            behavior(end).timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3)/1000;
            behavior(end).timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4)/1000;
        end
    else %ruledata only
        f=dir([path,'\',animal,'\',session{i},'\ST*_*.mat']);  rulepath=[path,'\',animal,'\',session{i},'\',f.name];
        Rule=load(rulepath).savedata.ruledata.rule1;
        lt=1;
        t=Rule(1,2:end);
        for j=1:length(t)
            if isempty(t{j})
                lt=j;
                break
            end
        end
        Rule=cell2mat(Rule(:,2:lt));
        if isDCZ
            behavior_DCZ(end+1).load_cell_onset={};
            behavior_DCZ(end).load_cell_offset={};
            behavior_DCZ(end).timestamp_hittarget=Rule(1,Rule(4,:)==1.1 | Rule(4,:)==1.2)';
            behavior_DCZ(end).timestamp_trialstart=Rule(1,Rule(4,:)==0)';
            if length(behavior_DCZ(end).timestamp_trialstart)>length(behavior_DCZ(end).timestamp_hittarget)
                behavior_DCZ(end).timestamp_trialstart=behavior_DCZ(end).timestamp_trialstart(1:length(behavior_DCZ(end).timestamp_hittarget))
            end
        elseif isSAL
            behavior_SAL(end+1).load_cell_onset={};
            behavior_SAL(end).load_cell_offset={};
            behavior_SAL(end).timestamp_hittarget=Rule(1,Rule(4,:)==1.1 | Rule(4,:)==1.2)';
            behavior_SAL(end).timestamp_trialstart=Rule(1,Rule(4,:)==0)';
            if length(behavior_SAL(end).timestamp_trialstart)>length(behavior_SAL(end).timestamp_hittarget)
                behavior_SAL(end).timestamp_trialstart=behavior_SAL(end).timestamp_trialstart(1:length(behavior_SAL(end).timestamp_hittarget))
            end
        else
            behavior(end+1).load_cell_onset={};
            behavior(end).load_cell_offset={};
            behavior(end).timestamp_hittarget=Rule(1,Rule(4,:)==1.1 | Rule(4,:)==1.2)';
            behavior(end).timestamp_trialstart=Rule(1,Rule(4,:)==0)';
            if length(behavior(end).timestamp_trialstart)>length(behavior(end).timestamp_hittarget)
                behavior(end).timestamp_trialstart=behavior(end).timestamp_trialstart(1:length(behavior(end).timestamp_hittarget))
            end
        end
    end
    
    
end
behavior=behavior(2:end);
behavior_DCZ=behavior_DCZ(2:end);
behavior_SAL=behavior_SAL(2:end);

% before DCZ
box_onset=[];
% datains=[];
% for index=1:length(behavior)
%     if ~isempty(behavior(index).load_cell_onset)
%         for i=1:length(behavior(index).timestamp_hittarget)
%             t=sum(behavior(index).load_cell_onset>behavior(index).timestamp_trialstart(i) & ...
%                 behavior(index).load_cell_onset<behavior(index).timestamp_hittarget(i));
%             box_onset=[box_onset t];
%         end
%     end
%     datains=[datains;(behavior(index).timestamp_hittarget-behavior(index).timestamp_trialstart)];
% end
% [dataout,indrmv]=rmoutliers_custome(datains);
% [pdf,~]=ksdensity(dataout,0:0.05:30,'Function','pdf','Bandwidth',0.5);
% [cdf,~]=ksdensity(dataout,0:0.05:30,'Function','cdf','Bandwidth',0.5);
% pdf(pdf<0)=0;

%% DCZ
box_onset_DCZ=[];
datains_DCZ=[];
for index=1:length(behavior_DCZ)
    if ~isempty(behavior_DCZ(index).load_cell_onset)
        for i=1:length(behavior_DCZ(index).timestamp_hittarget)
            t=sum(behavior_DCZ(index).load_cell_onset>behavior_DCZ(index).timestamp_trialstart(i) & ...
                behavior_DCZ(index).load_cell_onset<behavior_DCZ(index).timestamp_hittarget(i));
            box_onset_DCZ=[box_onset_DCZ t];
        end
    end
    datains_DCZ=[datains_DCZ;(behavior_DCZ(index).timestamp_hittarget-behavior_DCZ(index).timestamp_trialstart)];
end
[dataout,indrmv]=rmoutliers_custome(datains_DCZ);
[pdf_DCZ,~]=ksdensity(dataout,0:0.05:30,'Function','pdf','Bandwidth',0.5);
[cdf_DCZ,~]=ksdensity(dataout,0:0.05:30,'Function','cdf','Bandwidth',0.5);
pdf_DCZ(pdf_DCZ<0)=0;


%% saline
box_onset_SAL=[];
datains_SAL=[];
for index=1:length(behavior_SAL)
    if ~isempty(behavior_SAL(index).load_cell_onset)
        for i=1:length(behavior_SAL(index).timestamp_hittarget)
            t=sum(behavior_SAL(index).load_cell_onset>behavior_SAL(index).timestamp_trialstart(i) & ...
                behavior_SAL(index).load_cell_onset<behavior_SAL(index).timestamp_hittarget(i));
            box_onset_SAL=[box_onset_SAL t];
        end
    end
    datains_SAL=[datains_SAL;(behavior_SAL(index).timestamp_hittarget-behavior_SAL(index).timestamp_trialstart)];
end
[dataout,indrmv]=rmoutliers_custome(datains_SAL);
[pdf_SAL,~]=ksdensity(dataout,0:0.05:30,'Function','pdf','Bandwidth',0.5);
[cdf_SAL,a,b]=ksdensity(dataout,0:0.05:30,'Function','cdf','Bandwidth',0.5);
pdf_SAL(pdf_SAL<0)=0;


f=figure('Units','inches','Position',[1,1,7.3,3],'Color',[1,1,1]);

axes('Position',[0.07,0.2,0.25,0.6])
% bar(0:29,hist_onset/sum(hist_onset),'EdgeAlpha',0,'FaceColor',[0.2,0.2,0.2],'FaceAlpha',0.6)
% hold on
% bar(0:29,hist_onset_SAL/sum(hist_onset_SAL),'EdgeAlpha',0,'FaceColor',[0.2,0.2,0.6]+0.3,'FaceAlpha',0.6)
% bar(0:29,hist_onset_DCZ/sum(hist_onset_DCZ),'EdgeAlpha',0,'FaceColor',[0.8510,0.3765,0.1569],'FaceAlpha',0.6)
boxplot([box_onset,box_onset_SAL,box_onset_DCZ],[1+0*box_onset,2+0*box_onset_SAL,3+0*box_onset_DCZ],'Symbol','','Colors',[0.5,0.5,0.9;0.8510,0.3765,0.1569],'BoxStyle','filled')
% hold on
% boxplot(box_onset_SAL','Colors',[0.5,0.5,0.9],'PlotStyle','compact')
% boxplot(box_onset_DCZ','Colors',[0.8510,0.3765,0.1569],'PlotStyle','compact')
ylabel('Number of load cell onset')
set(gca,'box',0)
ylim([-2 16])

axes('Position',[0.38,0.2,0.25,0.6])
% plot(0:0.05:30,pdf,'LineWidth',1,'Color',[0.2,0.2,0.2])
hold on
plot(0:0.05:30,pdf_SAL,'LineWidth',1,'Color',[0.2,0.2,0.6]+0.3)
plot(0:0.05:30,pdf_DCZ,'LineWidth',1,'Color',[0.8510,0.3765,0.1569])
ylabel('PDF')
xlabel('T_{hit target} - T_{trial start}')
ylim([0 0.5])
yticklabels({'0','','','','','0.5'})
set(gca,'box',0)

axes('Position',[0.69,0.2,0.25,0.6])
% plot(0:0.05:30,cdf,'LineWidth',1,'Color',[0.2,0.2,0.2])
hold on
plot(0:0.05:30,cdf_SAL,'LineWidth',1,'Color',[0.2,0.2,0.6]+0.3)
plot(0:0.05:30,cdf_DCZ,'LineWidth',1,'Color',[0.8510,0.3765,0.1569])
ylabel('CDF')
xlabel('T_{hit target} - T_{trial start}')
ylim([0 1])
yticklabels({'0','','','','','1'})
set(gca,'box',0)
legend({'Saline','DCZ'},'Box',0,'Location','best')

st=suptitle([animal '-' session{1} '-' session{end}]);
set(st,'fontsize',12)




saveas(gcf,[pwd '\FIGS\m_behavior_DCZ_st3\'  animal '-' session{1} '-' session{end}])
saveas(gcf,[pwd '\FIGS\m_behavior_DCZ_st3\'  animal '-' session{1} '-' session{end} '.png'])
% % pause(5)
% % close(gcf)




function [dataout,indrmv] = rmoutliers_custome(datain); %From YJN
[data2575] = prctile(datain, [25, 75]);
interq = data2575(2) - data2575(1);
c=2;
indrmv = find(datain>data2575(2)+interq*c | datain<data2575(1)-interq*c);
dataout = datain;
dataout(indrmv) = [];
end
