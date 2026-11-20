function FigHandle = showConstraintsRegion(X,Y,solid_idx)
    % Constraints region
    xv = X; yv = Y;
    constraints_index = constraints_fun(xv,yv,[],[],[]);
    
    ind1 = find(constraints_index==1);
    ind2 = find(constraints_index==0);
    ind3 = intersect(ind2, solid_idx);
    constraints_index(ind3) = 2;
    
    
    % Display restricted region
    FigHandle = figure; hold on
    set(FigHandle, 'Position', [100, 250, 900, 350]);
    
    plot(xv(solid_idx),yv(solid_idx),'ro','MarkerFaceColor','r');
    plot(xv(ind1),yv(ind1),'bo','MarkerFaceColor','b');
    plot(xv(ind2),yv(ind2),'o','color',rgb('grey'),'MarkerFaceColor',rgb('grey'));
    plot(xv(ind3),yv(ind3),'ro','MarkerFaceColor','r');
    
    axis equal
    axis off;
    
    set(gca,'xtick',[],'xticklabel',[]);
    set(gca,'ytick',[],'yticklabel',[]);
    xlim([-0.25 0.45]);
    ylim([0 0.25]);
end
