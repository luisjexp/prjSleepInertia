function [fullname] = gfn(ntwprop_or_variable_name)
    arguments
        ntwprop_or_variable_name
    end
    
    switch upper(ntwprop_or_variable_name)
        case 'GPSD'
            fullname = 'Power';
        case 'CLUST' 
            fullname = 'Clustering';
        case 'DEG'
            fullname = 'Degree (unweighted)';
        case 'DEG_W'
            fullname = 'Degree (weighted)';            
        case 'BETW'
            fullname = 'Betweeness';                        
        case 'PATHL'
            fullname = 'Path Length';            
    end



end