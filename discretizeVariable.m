function tmpVar = discretizeVariable(variable,minBinSize)  
tmpVar = variable;

    [N,Edges] = histcounts(tmpVar);
        lowNIdxs = [];
        lowNIdxs = find(N<minBinSize);
        if ~isempty(lowNIdxs)
            for l = 1:numel(lowNIdxs)
                tmpVar(tmpVar>=Edges(lowNIdxs(l)) & tmpVar<Edges(lowNIdxs(l)+1)) = nan; 
            end
        end
        [~,Edges] = histcounts(tmpVar);
        binWidth = mean(diff(Edges));
        for t = 1:numel(tmpVar)
            if isnan(tmpVar(t))
                continue
            end
            uppEdgeIdx = find(tmpVar(t)<=Edges,1);
            tmpVar(t) = Edges(uppEdgeIdx)-.5*binWidth;
        end 
end