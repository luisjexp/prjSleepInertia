function P = normpsd(psd_mat, chan, sbj_idx)


% psd = extracting_psd_light_copy_scratch(A_cond, B_cond);
% psd_mat = psd.baseline;

% normalizing power by mean power
num_chan = numel(chan);
f_ind1 = 1;
f_ind2 = 251;
n_f = f_ind2-f_ind1+1;
P = [];
for i = 1:num_chan
    for j = 1:length(sbj_idx)
        % baseline
        pow(1:n_f) = psd_mat(chan(i),f_ind1:f_ind2,j);
        if std(pow)~=0
            pow = (pow-mean(pow))/std(pow);
            P(i,:,j) = pow;
            clear pow
        else 
            pow = 0;
            P(i,1:n_f,j) = 0;
            clear pow

        end
    end 
    i
end
end