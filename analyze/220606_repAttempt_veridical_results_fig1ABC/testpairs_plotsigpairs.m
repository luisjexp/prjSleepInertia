function testpairs_plotsigpairs(P, run_names, sigpairs)


    imagesc(P); hold on
    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names, 'Ytick', 1:5, 'YTickLabel', run_names)    
    r = sigpairs(:,1);
    c = sigpairs(:,2);
    rcl = sub2ind(size(P), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(P(rcl)),    'UniformOutput',    false);
    text(r',c',str(:), 'color', 'r')
    plot(r, c, 'r*', 'MarkerSize',10)
    title('T statistics')
    axis square
    