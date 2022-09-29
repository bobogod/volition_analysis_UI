% 20220714 modified by bo
% no changes done for the detection and sorting part
% not available for segment-recordings

%% Read OpenEphys data
raw_data=load_open_ephys_binary('structure.oebin','continuous',1);
Fs=raw_data.Header.sample_rate;
AllChs=1:raw_data.Header.num_channels;

%% Extract Ephys data
data_avg = mean(raw_data.Data);
index = double(raw_data.Timestamps-raw_data.Timestamps(1))*1000/Fs;
for i=1:raw_data.Header.num_channels
    data = raw_data.Data(i, :)-data_avg;
    savefile = ['chdat' num2str(ii) '.mat'];
    save(savefile, 'data', 'index');
    disp([savefile ' saved'])
end


%% Spike detection and sorting
functional_channels = LiveChs;
pos_detection =[ ];  % for channel 13, use positive detection
tosort_list=[];

for i = 1:length(functional_channels)
    indx = find(LiveChs==functional_channels(i));
    tosort_list{1} = ['chdat' num2str(functional_channels(i)), '.mat'];
    param               =           set_parameters();
    param.sr           =           Fs;
    if ~isempty(find(pos_detection==functional_channels(i)))
        param.detection = 'pos';
    else
        param.detection = 'neg';
    end;
    
    param.detect_fmin               =       250;               % high pass filter for detection
    param.detect_fmax               =       8000;              % low pass filter for detection (default 1000)
    param.detect_order              =       4;                % filter order for detection
    param.sort_fmin                    =        250;                 % high pass filter for sorting
    param.sort_fmax                    =        5000;                % low pass filter for sorting (default 3000)
    param.segments_length        =          1;            % data will be precessing in segments of 15 seconds
    param.stdmin                         =          4;
    param.stdmax                        =       50;

    Get_spikes(tosort_list,'parallel',false,'par',param);
    Do_clustering(['chdat' num2str(functional_channels(i)), '_spikes.mat'])
end;