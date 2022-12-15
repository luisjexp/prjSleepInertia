function testpairs_plotsigpairs(T, run_names, sigpairs, axis_handle)
    r = sigpairs(:,1);
    c = sigpairs(:,2);
    rcl = sub2ind(size(T), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(T(rcl)),    'UniformOutput',    false);


    set(axis_handle, 'PositionConstraint', 'outerposition', 'Xtick', 1:5, 'XTickLabel', run_names, 'Ytick', 1:5, 'YTickLabel', run_names)               
    imagesc(axis_handle, T); hold on    
    text(axis_handle, r',c',str(:), 'color', 'r')
    plot(axis_handle,r, c, 'r*', 'MarkerSize',10)
    title(axis_handle, 'T statistics')
    
    axis square
    