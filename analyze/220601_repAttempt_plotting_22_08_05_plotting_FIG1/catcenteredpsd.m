function her_pow_AorB = catcenteredpsd(my_centered_psd, desired_condition)
% this is needed to format the data in my table to match the format of the
% origical outputs (pow_A and pow_B) from the original
% extract_psdlight function. 
% the original outputs (powA and pow_B) are centered 4x23x251xN psd matrices
% ie four 3d centered matrices for each run,  
% 
% my table however has these in seperate cells. so this just concatenates
% the cells to match the original output.


her_pow_AorB = my_centered_psd {strcmp(my_centered_psd.condition, desired_condition),'centered_psd'}; % annoying, but to match her output, i need to concatenate my data from each run
her_pow_AorB = permute( cat(4, her_pow_AorB{:}), [4, 1, 2,3] ) ;

end