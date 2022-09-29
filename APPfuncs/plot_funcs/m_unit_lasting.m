function m_unit_lasting(animal,DataPaths)
%   plot how many spikes can be sorted out, by bo, 20220418
%   

grid=[];
for i=1:length(DataPaths)
    disp(i)
    grid=[grid;zeros(1,16)];
    tData=load(DataPaths{i}); tData=tData.Data;
    if sum(tData.UnitsOffline.SpikeNotes(:,4))==0        
        for j=1:length(tData.UnitsOffline.SpikeNotes(:,1))
            if tData.UnitsOffline.SpikeNotes(j,3)>0
                grid(end,tData.UnitsOffline.SpikeNotes(j,1))=grid(end,tData.UnitsOffline.SpikeNotes(j,1))+1;
            end
        end
    else
        for j=1:length(tData.UnitsOffline.SpikeNotes(:,1))
            if tData.UnitsOffline.SpikeNotes(j,4)==1
                grid(end,tData.UnitsOffline.SpikeNotes(j,1))=grid(end,tData.UnitsOffline.SpikeNotes(j,1))+1;
            end
        end
    end
end
ygrid={};
for i=1:length(DataPaths); ygrid{end+1}=DataPaths{i}(end-27:end-20); end
f=figure;
h=heatmap(f,grid);
h.YDisplayLabels=ygrid;
h.XLabel='CH';
h.ColorbarVisible=0;
f.Color='w';
title(['Single Units of ' animal]);
savefig(f,[pwd '\FIGS\m_unit_lasting\' animal '-' ygrid{1} '-' ygrid{end}])
end

