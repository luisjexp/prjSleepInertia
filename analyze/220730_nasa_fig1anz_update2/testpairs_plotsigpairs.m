function testpairs_plotsigpairs(T, run_names, sigpairs, axis_handle)
% testpairs_plotsigpairs(T, run_names, sigpairs, axis_handle)

    r = sigpairs(:,1);
    c = sigpairs(:,2);
    rcl = sub2ind(size(T), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(T(rcl)),    'UniformOutput',    false);


    set(axis_handle, 'PositionConstraint', 'outerposition')               
    imagesc(axis_handle, T); hold on    
    text(axis_handle, r',c',str(:), 'color', 'r', 'FontSize', 8)
    plot(axis_handle,r, c, 'r*', 'MarkerSize',5)
    title(axis_handle, 'T statistics')
    
    axis square
    set(axis_handle, 'Xtick', 1:5, 'XTickLabel', run_names, 'Ytick', 1:5, 'YTickLabel', run_names)               

    