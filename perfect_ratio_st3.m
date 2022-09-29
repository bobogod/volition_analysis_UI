path='G:\lab\volitional-BCI\Data';
% animal='Norman';
% session={'20220913SAL','20220915DCZ','20220916SAL','20220918DCZ','20220919SAL','20220921DCZ','20220922SAL','20220923DCZ'};
% animal='Ray';
% session={'20220913SAL','20220916SAL','20220918DCZ','20220919SAL','20220921DCZ','20220922SAL','20220923DCZ'};
% animal='Emma';
% session={'20220913','20220913DCZ','20220915','20220915DCZ','20220916','20220916DCZ','20220918','20220918SAL'};

%% load data
behavior=struct();
for i=1:length(session)
    f=dir([path,'\',animal,'\',session{i},'\*BODATA*.mat']);
    if ~isempty(f) %contains ephys data
        datapath=[path,'\',animal,'\',session{i},'\',f.name];
        Data=load(datapath).Data;
        behavior(end+1).load_cell_onset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==10)/1000;
        behavior(end).load_cell_offset=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==9)/1000;
        behavior(end).timestamp_trialstart=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==3)/1000;
        behavior(end).timestamp_hittarget=Data.Behavior.EventTimings(Data.Behavior.EventMarkers==4)/1000;
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
        behavior(end+1).load_cell_onset={};
        behavior(end).load_cell_offset={};
        behavior(end).timestamp_hittarget=Rule(1,Rule(4,:)==1.1 | Rule(4,:)==1.2)';
        behavior(end).timestamp_trialstart=Rule(1,Rule(4,:)==0)';
        if length(behavior(end).timestamp_trialstart)>length(behavior(end).timestamp_hittarget)
            behavior(end).timestamp_trialstart=behavior(end).timestamp_trialstart(1:length(behavior(end).timestamp_hittarget))
        end
    end
    
end
behavior=behavior(2:end);

f=figure('Units','inches','Position',[1,1,7.3,3],'Color',[1,1,1]);
axes('Position',[0.1,0.2,0.8,0.6])
hold on

perfect_ratio=[];
for i=1:length(behavior)
    t=behavior(i).timestamp_hittarget-behavior(i).timestamp_trialstart;
%     perfect_ratio=[perfect_ratio sum(t<3.5)/length(t)];
    perfect_ratio=[perfect_ratio sum(t<5)/length(t)];
    isDCZ=length(strfind(session{i},'DCZ'));
    isSAL=length(strfind(session{i},'SAL'));  
    if isDCZ
        scatter(i,perfect_ratio(end),'MarkerFaceAlpha',0,'MarkerEdgeColor',[0.8510,0.3765,0.1569],'Marker','o','LineWidth',1.5);
    elseif isSAL
        scatter(i,perfect_ratio(end),'MarkerFaceAlpha',0,'MarkerEdgeColor',[0.5,0.5,0.9],'Marker','o','LineWidth',1.5);
    else
        scatter(i,perfect_ratio(end),'MarkerFaceAlpha',0,'MarkerEdgeColor',[0.2,0.2,0.2],'Marker','o','LineWidth',1.5);
    end
end




plot(1:length(perfect_ratio),perfect_ratio,'LineWidth',0.8,'Color',[0.2,0.2,0.2])
ylabel('below 5s ratio')
% xlabel('session')
ylim([0 1])
xlim([0.7,length(session)+0.3])
yticklabels({'0','','','','','1'})
xticklabels('');
for i=1:length(session)
    text(i,-0.01,session{i}(5:end),'VerticalAlignment','top','HorizontalAlignment','right','Rotation',30,'FontSize',8);
end
set(gca,'box',0)

st=suptitle([animal '-' session{1} '-' session{end}]);
set(st,'fontsize',12)




saveas(gcf,[pwd '\FIGS\m_perfect_ratio_st3\'  animal '-' session{1} '-' session{end}])
saveas(gcf,[pwd '\FIGS\m_perfect_ratio_st3\'  animal '-' session{1} '-' session{end} '.png'])
% % pause(5)
% % close(gcf)

