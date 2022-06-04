Data={};
p_old=0;
[FileName,PathName]=uigetfile({'*.mat','.mat'},"load data file");
while FileName
    p_old=PathName;
    t=load([PathName,FileName]);
    Data{end+1}=t.Data;
    [FileName,PathName]=uigetfile({'*.mat','.mat'},"load data file");
end
PathName=p_old;