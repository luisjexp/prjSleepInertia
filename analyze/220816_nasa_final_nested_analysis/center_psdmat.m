function psd_centered = center_psdmat(psd_mat)

n_chan = size(psd_mat,1);
n_sub = size(psd_mat,3);
n_freq = size(psd_mat,2);
psd_centered = zeros(n_chan,n_freq,n_sub);

for i = 1:n_chan
    for j = 1:n_sub
        % baseline
        pow(1:n_freq) = psd_mat(i,1:n_freq,j);
        if std(pow)~=0
            pow = (pow-mean(pow))/std(pow);
            psd_centered(i,:,j) = pow;
            clear pow
        else 
            pow = 0;
            psd_centered(i,1:n_freq,j) = 0;
            clear pow
        end
    
        
    end
end




end