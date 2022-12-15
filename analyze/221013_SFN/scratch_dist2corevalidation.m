clear
DF = [dfmaster('cogtestlist','PVT'); getdist2core('PVT',0.8: 0.05 : 1.2)];


%% Validate Data Frame
ntwprop_set = unique(DF.ntwprop);

numprops = numel(ntwprop_set);
GC = [];

disp('')
for i = 1:numprops
    df = DF(DF.ntwprop == ntwprop_set(i),:);
    gc = groupsummary(DF,{'sbj','chan'});
    if i ==1
        GC = gc.GroupCount;
    end

    if GC ~= gc.GroupCount
        error('Luis: your df has an error')
    else
        fprintf('.')

    end
end

disp('Data frame is valid')

%%

