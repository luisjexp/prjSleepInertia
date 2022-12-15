function compare_data(x_her, x_me, varargin)

    visualize_comparison(x_her,x_me)        

    % added later to compare dimension by dimension
    if nargin == 3
        sz = size(x_her);
        compare_dimension = varargin{1};

           
        num_compare = sz(compare_dimension);        
        for i = 1:num_compare
            
        switch compare_dimension
            case {upper('first'), 1}
            case {upper('second'), 2}
            case {upper('third') ,3}   
            x = x_her(:,:,i);
            y = x_me(:,:,i);
        end

            nexttile;            
            visualize_comparison(x,y) 
        end


    end

    function visualize_comparison(her,me)
        hold on;
        
        scatter(her(:), me(:))        
        [mn, mx] = bounds( [her(:);me(:)]); 


        if mn~=mx
            line([mn mx],[mn mx])
            axis square equal
            xlim([mn,mx])
            ylim([mn,mx])             
        end
        

   
        allequal_and_sameloc = all(her(:) == me(:));
        allequal = ismember(her(:), me(:));
        
        if allequal
            
            if allequal_and_sameloc
                rslt = sprintf('Perfect match\nAll values are equal and same position');
            else
                rslt = sprintf('Problem in matching: All values are equal\nBUT NOT in the same position');
            end
        else
            rslt = 'Failure to match; not all values are equal';
        end
        text(.05,.9, rslt, 'units', 'normalized', 'FontSize',7);
        axis square equal    
    
    end



end