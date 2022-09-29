function data = load_open_ephys(varargin)
if isempty(varargin)
    path=pwd();
else
    path=varargin{1};
end
data=struct();

t=dir([path '\Record Node 101']);
for i=3:length({t.name})
    if ~isempty(strfind(t(i).name,'experiment'))        
        tt=dir([path '\Record Node 101\' t(i).name]);
        for j=3:length({tt.name})
            if ~isempty(strfind(tt(j).name,'recording'))  
                continuous_path=[path '\Record Node 101\' t(i).name '\' tt(j).name '\structure.oebin'];
                break
            end
        end
        break
    end
end
data.continuous=load_open_ephys_binary(continuous_path,'continuous',1);
data.event=load_open_ephys_binary(continuous_path,'events',1);


t=dir(strcat(path,'\Record Node 128'));
for i=3:length({t.name})
    if ~isempty(strfind(t(i).name,'experiment'))        
        tt=dir([path '\Record Node 128\' t(i).name]);
        for j=3:length({tt.name})
            if ~isempty(strfind(tt(j).name,'recording'))  
                spike_path=[path '\Record Node 128\' t(i).name '\' tt(j).name '\structure.oebin'];
                break
            end
        end
        break
    end
end
data.spike=load_open_ephys_binary(spike_path,'spikes',1);

end

