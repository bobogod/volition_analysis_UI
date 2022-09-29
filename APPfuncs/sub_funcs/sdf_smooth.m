function fout = sdf_smooth(tspk,spike_timestamp,kernel_width)
% sampling rate set to 1ms
spktimes=round(spike_timestamp);

spkmat = sparse(1, length(tspk));

[~, indspks] = intersect(tspk, spktimes);
spkmat(indspks)=1;

fout=sdf(tspk/1000, spkmat, kernel_width);
xout=tspk;

end

