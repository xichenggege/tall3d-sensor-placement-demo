function fun = plot_library
%plot_libary Summary of this function goes here
% Collection of all plotting used in this work
    
    fun.preview_general = @preview_general;   % Contour plot general
    fun.preview_rawdata = @preview_rawdata;   % preview for rawdata
    fun.preview_redBlue = @preview_redBlue;   % preview mean value use redBlue
    fun.preview_general_redBlue = @preview_general_redBlue; % preview general value use redBlue
    fun.preview_sensor  = @preview_sensor;    % preview mean value use redBlue
    fun.preview_TCgrid  = @preview_TCgrid;    % preview TC grid results
    fun.pod_mode_selection = @pod_mode_selection; % Preview singular value and cum variance vs modes
    fun.sensor_compare = @sensor_compare;     % Preview sensor nmse reconstruction error with noise
    fun.plotSensor     = @plotSensor;     % Preview sensor nmse reconstruction error with noise
    fun.scatterContf   = @scatterContf;
    fun.setupFigure    = @setupFigure;

    % color and symbol
    co=[0.4102    0.4102    0.4102
        0.4660    0.6740    0.1880;
        0.4940    0.1840    0.5560;
        0.9290    0.6940    0.1250;
        0.8500    0.3250    0.0980;
        0.0000    0.4470    0.7410;
        0.6350    0.0780    0.1840;
        0.3010    0.7450    0.9330;
        0.5000    0.5000    0.0000;
        0.7266    0.3320    0.5242;
        0.0000    0.0000    0.0000;
        0.6350    0.4780    0.1840;
        0.0000    0.5430    0.5430];
    co2 = [rgb('red');rgb('green');rgb('blue');rgb('black')];
    
    % mark symbol for plot
    mark = char('-s','-o','->','-d','-h','-x','-|','-^','-p',':','-.');

    function [] = scatterContf(X,Y,Z,zlimit,subtitle)

        scatter(X,Y,10,Z,'filled');
        % contour setup
        colormap jet;
        colorbar('location','EastOutside');
        shading flat;
        caxis(zlimit);

        set(gcf,'PaperPositionMode','auto');
        set(gca,'fontsize',18,'fontname','times');    
        
    end

    
    function [] = preview_rawdata(videoObject,displaySpace,xF,zF,T,Um,GS_Head,GS_LRR,saveFolder)
        open(videoObject);
        for j=1:displaySpace:numel(GS_Head)  % 160~9860s          
            FigHandle = figure;
            set(FigHandle, 'Position', [100, 250, 900, 600]);
        
            for figNum = 1:2
                subplot(1,2,figNum)
                if ismember(figNum,[1]) % CFD temperature full
                    yp = reshape(T(:,j),size(xF));
                    varMin=1.0*min(yp,[],'all');
                    varMax=max(yp,[],'all') - 5;
                    if varMin > varMax
                        varMin = varMax - 3;
                    end
                    lines=linspace(varMin,varMax,21);
                    lines(end) = lines(end) + 2;
                    [~,b]=contourf(xF,zF,yp,lines); hold on;
                    title('T (degC)','fontsize',15);
                    clim([varMin varMax]);
        
                elseif ismember(figNum,[2]) % CFD velocity full
                    yp = reshape(Um(:,j),size(xF));
                    varMin=0.0;
                    varMax=0.2*max(yp,[],'all');
                    lines=linspace(varMin,varMax,21);
                    [~,b]=contourf(xF,zF,yp,lines); hold on;
                    title('Vm (m/s)','fontsize',15);
                    clim([varMin varMax]);
                end   
                plotSparger;
                setupFigure(b,[0 1.6],[2 5.4]);    
            end
        
            % Global title
            titlePlot=sprintf('GS(Head)=%.1f, GS(LRR)=%.1f kg/m2s',GS_Head(j),GS_LRR(j));
            sgtitle(titlePlot,'fontsize',15);
            % Record figure
            F= getframe(gcf);
            writeVideo(videoObject,F);
            exportgraphics(FigHandle,sprintf('%s//snap_train_id_%d.png',saveFolder,j));
            close all
        end
        close(videoObject);
    end

    function [] = preview_redBlue(videoObject,displaySpace,xF,zF,T,Um,GS_Head,GS_LRR,saveFolder)
        % redBlue color map
        cmap = redblue(20);
        cmap(10:11,:)=1;
        open(videoObject);
        for j=1:displaySpace:numel(GS_Head)  % 160~9860s          
            FigHandle = figure;
            set(FigHandle, 'Position', [100, 250,1200, 800]);
        
            for figNum = 1:2
                subplot(1,2,figNum)
                if ismember(figNum,[1]) % CFD temperature full     
                    yp = reshape(T(:,j),size(xF));
                    subtitleName  = 'T (degC)';
                    contourFactor = 1.0;
        
                    ind = find(zF>2.5 & zF<4.8);
                    varMax = max(yp(ind))*contourFactor;
                    varMin = min(yp(ind))*contourFactor;
                    lines  = linspace(varMin,varMax,21);
                    lines(1) = lines(1)*0.1;
                    lines(end) = lines(end)*10;
                    [~,b] = contourf(xF,zF,yp,lines,'LineColor','none'); shading flat
                    clim([varMin varMax]);
        
                elseif ismember(figNum,[2]) % CFD velocity full
                    yp = reshape(Um(:,j),size(xF));
                    subtitleName  = 'V (m/s)';
                    contourFactor = 0.1; 
                    varMax = max(abs(yp(ind)))*contourFactor;
                    varMin = -varMax;
                    lines  = linspace(varMin,varMax,21);
                    lines(1) = lines(1)*10;
                    lines(end) = lines(end)*10;
                    [~,b] = contourf(xF,zF,yp,lines,'LineColor','none'); shading flat
                    clim([varMin varMax]);
                end  
                plotSparger;
                setupFigure(b,[0 1.6],[2 5.4]);     
            end
                
            % Global title
            titlePlot=sprintf('GS(Head)=%.1f, GS(LRR)=%.1f kg/m2s',GS_Head(j),GS_LRR(j));
            sgtitle(titlePlot,'fontsize',15);
            % Record figure
            F= getframe(gcf);
            writeVideo(videoObject,F);
            exportgraphics(FigHandle,sprintf('%s//snap_train_id_%d.png',saveFolder,j));
            close all
        end
        close(videoObject);
    end

    function [] = preview_sensor(xmesh,ymesh,field,sensors,if_label) 
            % Plot       
            field = reshape(field,size(xmesh));
            % For contour maps
            varMin=min(field,[],'all');
            varMax=max(field,[],'all');
            if varMax<varMin
                varMax = varMin + 5;
            end
            lines=linspace(varMin,varMax,21);
            [~,b]=contourf(xmesh,ymesh,field,lines); hold on;
            clim([varMin varMax]);

            set(b,'EdgeColor','none');
            colormap jet; 
            colorbar('location','EastOutside');
            shading flat;
            % Plot sensors
            plotSensor(xmesh(:),ymesh(:),sensors,if_label)
            setupFigure([0 150],[-40 40]); 
    end

    function [] = preview_general(xmesh,ymesh,field)
            varMin=min(field,[],'all');
            varMax=max(field,[],'all');
            lines=linspace(varMin,varMax,21);
            [~,b]=contourf(xmesh,ymesh,field,lines); hold on;
            clim([varMin varMax]);

            set(b,'EdgeColor','none');
            colormap jet; 
            colorbar('location','EastOutside');
            shading flat;
            setupFigure([0 2.5],[-0.8 0.8]);   
    end

    function [] = preview_general_redBlue(xmesh,ymesh,field)
        % redBlue color map
        cmap = redblue(20);
        cmap(10:11,:)=1;

        contourFactor = 1.0;
        varMax = max(field,[],'all')*contourFactor;
        varMin = min(field,[],'all')*contourFactor;
        lines  = linspace(varMin,varMax,21);
        lines(1) = lines(1)*0.1;
        lines(end) = lines(end)*10;
        [~,b] = contourf(xmesh,ymesh,field,lines,'LineColor','none'); shading flat
        clim([varMin varMax]);
        
        set(b,'EdgeColor','none');
        colormap(cmap); 
        colorbar('location','EastOutside');
        shading flat;
        setupFigure([0 2.5],[-0.8 0.8]);    
    end

    
    function [FigHandle] = pod_mode_selection(xp,yp1,yp2,numModes,xlimit,ylimit1,ylimit2) 
        FigHandle = figure; 
        set(FigHandle, 'Position', [100, 250, 650, 450]);
        yyaxis left
        semilogy(xp,yp1,'-o','lineWidth',1.5);
        xlim(xlimit);
        ylim(ylimit1);
        set(gca,'fontsize',18,'fontname','times');
        ylabel('Normalized singular values [-]','fontsize',22,'fontname','times');
        
        yyaxis right
        hold on
        plot(xp,yp2,'-d','lineWidth',1.5);
        plot([xp(numModes) xp(numModes)],[0,1],'--r','lineWidth',2.5);
        xlim(xlimit);
        ylim(ylimit2);
        ylabel('Cumulative variance [-]','fontsize',20,'fontname','times');
        xlabel('Number of modes [-]','fontsize',20,'fontname','times');
    end

    function [] = sensor_compare(xp,yp,yp_std,legName,xlimit,ylimit,saveName) 
        FigHandle = figure; hold on
        set(FigHandle, 'Position', [100, 250, 800, 600]);
        for k = 1:numel(yp(1,:))
            if k>3
                ph(4)=plot(xp',yp(:,k),'d',...
                    'MarkerSize',8,'MarkerEdgeColor',co2(4,:),'MarkerFaceColor',co2(4,:));
                % errorbar(xp',yp(:,k),yp_std(:,k),'d','color',co2(4,:),...
                %     'MarkerSize',8,'MarkerEdgeColor',co2(4,:),'MarkerFaceColor',co2(4,:));
            else
                ph(k)=plot(xp',yp(:,k),'o',...
                    'MarkerSize',8,'MarkerEdgeColor',co2(k,:),'MarkerFaceColor',co2(k,:));
                % errorbar(xp',yp(:,k),yp_std(:,k),'o','color',co(k,:),...
                %     'MarkerSize',8,'MarkerEdgeColor',co(k,:),'MarkerFaceColor',co(k,:));
            end
        end
        set(gca, 'YScale', 'log');
        grid on;
        xlim(xlimit);
        ylim(ylimit);
        set(gca,'ytick',[1e-5 1e-4 1e-3 1e-2 1e-1 1 10]);
        set(gca,'fontsize',24,'fontname','times');
        legend(ph,legName,'fontsize',24,'fontname','times','location','best','numColumns',2);
        legend boxoff
        ylabel('NMSE [-]','fontsize',24,'fontname','times','Interpreter','latex');
        xlabel('Noise variance $\sigma^{2}$ [K]','fontsize',24,'fontname','times','Interpreter','latex');
        exportgraphics(FigHandle,saveName);
    end

    function [] = preview_TCgrid(xF,zF,field,saveName)
            FigHandle = figure; hold on
            set(FigHandle, 'Position', [100, 250, 800, 600]);
            varMin=min(field,[],'all');
            varMax=max(field,[],'all');
            lines=linspace(varMin,varMax,11);
            [~,b]=contourf(xF,zF,field,lines); hold on;
            clim([varMin varMax]);
            plotSparger;
            if_label=false;
            plotSensor(xF(:),zF(:),[1:1:numel(xF(:))],if_label);
            setupFigure(b,[0 1.03],[2.35 3.3]);   
            exportgraphics(FigHandle,saveName);
    end

    function [] = setupFigure(xlimit,ylimit)         
            axis equal          
            xlabel('$x\ [m]$','interpreter','latex','fontsize',24,'fontname','times');
            ylabel('$y\ [m]$','interpreter','latex','fontsize',24,'fontname','times');
            set(gcf,'PaperPositionMode','auto');
            set(gca,'fontsize',22,'fontname','times');
            xlim(xlimit); ylim(ylimit);
    end

    function [] = plotSensor(xFb_,zFb_,sensors,if_label) % Plot sensors
        for i = 1:numel(sensors)
            plot(xFb_(sensors(i)),zFb_(sensors(i)),'r*','MarkerSize',8);
            if if_label
                text(xFb_(sensors(i))+0.02,zFb_(sensors(i))+0.02,sprintf('#%d',i),'color','r','FontSize',18);
            end
        end
    end

end

