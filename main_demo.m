% -------------------------------------------------------------------------
%% Optimal sensor placement
% -------------------------------------------------------------------------
% Load the bundled demo temperature snapshots.
% Select sensors by QR pivoting, with and without spatial constraints.
% Export figures and save sensor indices and the training/test snapshot split.
% -------------------------------------------------------------------------
% Note that oversampling (p=44) takes time ! 
%  - The default uses the 44 demo sensor indices listed below.
% -------------------------------------------------------------------------
% By Xicheng Wang, xicheng@kth.se
% version 1.0 
% 2026-11-09
% -------------------------------------------------------------------------

clc; clear; close all;
rng('default');

%% Choose if you want to solve or load oversampled sensors
%   - solving takes time !
if_solve_oversample_sensor = false;

%%  Building libary and add block
% Load modules 
dataLoc = fileparts(mfilename('fullpath'));
addpath(fullfile(dataLoc,'Functions'));
plt  = plot_library;         % plot module

% Prepare save folder
saveFolder = fullfile(dataLoc,'Figures','demo');
mkdir(saveFolder);

outputFolder = fullfile(dataLoc,'Output','demo');
mkdir(outputFolder);

%% Load training data and prepare
data_folder = fullfile(dataLoc,'demo');
[T, X_, Y_, solid_idx] = load_data(data_folder);

%--------------------------------------------------------------------------
%% Part1: Optimal sensor placement for Temperature sensors
%--------------------------------------------------------------------------
% shuffle and seperate train and testing
caseNum     = numel(T.field(1,:));
split_ratio = 0.85;               % 85% training, 15% testing
caseInd     = randperm(caseNum);  % shuffle
trainInd    = caseInd(1:round(caseNum*split_ratio));
testInd     = setdiff(caseInd,trainInd);

[T.sub,T.mean]  = submean(T.field(:,trainInd));
if_oversmapled  = false;    % number sensor > optimal modes
cumVar_trunc    = 0.999;    % cumulative variance to be truncated

%--------------------------------------------------------------------------
% do SVD
%--------------------------------------------------------------------------
[T.u,T.s,T.v] = svd(T.sub,'econ');
% Plots the mode energies
ModeEnergies=diag(T.s.^2);

% cumulative variance
for i = 1:numel(ModeEnergies)
    T.cumVar(i) = sum(ModeEnergies(1:i))./sum(ModeEnergies);
end

% number of modes to be extracted
T.numModes = min(find(T.cumVar>=cumVar_trunc));

% Display: s ingular value, cum var VS modes
yp1 = diag(T.s)/max(diag(T.s)); yp2 = T.cumVar; xp = 1:numel(yp1);
saveName = fullfile(saveFolder,'T_POD_modes_selection.png');
FigHandle = plt.pod_mode_selection(xp,yp1,yp2,T.numModes,[0 50],[1e-4,1],[0.98 1]);
exportgraphics(FigHandle,saveName,'Resolution',450);

% Display mode selection and modes contours
mkdir(fullfile(saveFolder,'Mode'));
for i =1:T.numModes
    FigHandle = figure;
    set(FigHandle, 'Position', [100, 250, 900, 350]);

    field_ = T.u(:,i);
    zlimit = [min(field_),max(field_)];

    plt.scatterContf(X_,Y_,field_,zlimit);
    plt.setupFigure([-0.325,0.475],[0 0.25]); 
    title(sprintf('T mode %d',i),'fontsize',18,...
        'fontname','times','Interpreter','latex');
    exportgraphics(FigHandle,fullfile(saveFolder,'Mode',sprintf('T_mode_%d.png',i)));
end
close all

%--------------------------------------------------------------------------
% Optimal sensor placement without constraints
%--------------------------------------------------------------------------
% Non-oversample, i.e. number of sensor = number of extracted modes
numSensor = T.numModes;
[~,~,sensors{1}]  = qr_pivote_udf(T.u(:,1:T.numModes)',[],[],[],[],[],numSensor);
optSensors{1}     = sensors{1}(1:numSensor);

%--------------------------------------------------------------------------
% Optimal sensor placement with constraints
%--------------------------------------------------------------------------
% Non-oversample, i.e. number of sensor = number of extracted modes
% Constraints for domain
constraints_type   = 'region-constraints';
constraints_radius = 10e-3;

[~,~,sensors{2}]   = qr_pivote_udf(T.u(:,1:T.numModes)',constraints_type,@constraints_fun,X_(:),Y_(:),constraints_radius,numSensor);
optSensors{2}      = sensors{2}(1:numSensor);

%--------------------------------------------------------------------------
% Optimal sensor placement with constraints, oversampling 
%  - Note: this might take a lot of time !
%--------------------------------------------------------------------------
% % Oversample, i.e. number of sensor > number of extracted modes

if if_solve_oversample_sensor 
    numSensors = 44;   % same number of TALL-3D axis-symmetry domain !
    X = T.u(:,1:numSensors)*T.u(:,1:numSensors)';   
    constraints_type   = 'region-constraints';
    constraints_radius = 8e-3;
    
    [~,~,sensors{3}]   = qr_pivote_udf(X,constraints_type,@constraints_fun,X_(:),Y_(:),constraints_radius,numSensors);
    optSensors{3}      = sensors{3}(1:numSensors);
    save(fullfile(outputFolder,'overSampled_sensors_demo_data.mat'),'optSensors');
else
    optSensors{3}      = [47234	 9072	13503	21776	13512	13522	13531	13544	14359	13558 ...
    	615	13581	47387	32786	24044	41845	13496	232	47300	6805	46545	34549	31017 ...
    	25216	18752	41782	17497	37346	7212	29672	47258	14859	29497	12332	9931 ...
    	13570	31267	34249	28144	41765	48059	29226	28152	47388];
end

%--------------------------------------------------------------------------
% TALL-3D sensor locations
%--------------------------------------------------------------------------
% refer to 'P. Kudinov TALL-3D setup for first series," SESAME progress report, D4.5, (2016).'
x_TC = [ones(4,1)*0.0; ...              % BP
    ones(10,1)*0.17; 0.18; 0.175;...    % CIP + CIP_xt + +CIP_G
    linspace(0.02,0.2,10)';...          % OLW
    linspace(0.0,0.2,9)';...            % IPT
    linspace(0.04,0.16,4)';...          % ILW
    0.069;...                           % ins_01_1530
    0.139;...                           % ins_01_1600
    -0.015;...                          % FL
    -0.25; 0.45];                       % Tin, Tout

y_TC = [linspace(0.025,0.1,4)'; ...   % BP
    linspace(0.005,0.095,10)'; 0.0919; 0;...     % CIP + CIP_xt +CIP_G
    ones(10,1)*0.15675;...            % OLW
    ones(9,1)*0.125;...               % IPT
    ones(4,1)*0.150;...               % ILW
    0.20;...                          % ins_01_1530
    0.20;...                          % ins_01_1600
    0.082;...                         % FL
     0; 0];                           % Tin, Tout

sensorPosIdx{1} = optSensors{1};   % optimal placement no constraints
sensorPosIdx{2} = optSensors{2};   % constrained placement with one sensor per retained mode
sensorPosIdx{3} = optSensors{3};   % optimal placement with constraints + 44 sensors
sensorPosIdx{4} = find_sensorInd(x_TC,y_TC,X_,Y_);

%--------------------------------------------------------------------------
% Random sensor placement
%--------------------------------------------------------------------------
constraints_index = constraints_fun(X_,Y_,[],[],[]);
p                 = numel(optSensors{2});
ind_available     = find(constraints_index~=1);
sensorIndex       = ind_available;

for i = [1:3]  % three random layouts sampled from the accessible nodes
    sensorPosIdx{4+i} = sensorIndex(randperm(numel(sensorIndex),p));
end

%--------------------------------------------------------------------------
% Display optimal sensor position
%--------------------------------------------------------------------------
titleName = [{'Optimal'}, {'Optimal constrained'}, {'Optimal constrained oversample'},...
    {'Tall-3D original'}, {'Random 1'}, {'Random 2'},{'Random 3'}];
for k = 1:numel(sensorPosIdx)
    FigHandle = showConstraintsRegion(X_,Y_,solid_idx);
    scatter(X_(sensorPosIdx{k}),Y_(sensorPosIdx{k}),15,'og','filled');
    title(titleName{k},'fontSize',20);
    exportgraphics(FigHandle,fullfile(saveFolder,sprintf('sensorInd_%d.png',k)));
end

%--------------------------------------------------------------------------
%% Part2: How to prove it is the optiaml position?
%--------------------------------------------------------------------------
% All are on testing dataset
% Reference case 
T_ref = T.field(:,testInd);
[~,numFeature] = size(T_ref);
% subtract mean
T.sub_test = T_ref - repmat(T.mean,[1,numFeature]);

% Sensor model: one fixed thermocouple bias plus independent reading errors.
noise_level = 0:0.2:2;   % dimensionless multiplier, lambda
a0 = 1;                  % reference bias half-width [K]
sigma0 = 0.25;           % reference reading-error standard deviation [K]
draw_noise = @(nSensors,nSnapshots) a0*(2*rand(nSensors,1)-1) ...
                                    + sigma0*randn(nSensors,nSnapshots);

% Shared nodes receive the same perturbations across layouts in each trial.
sensorArg = 1:7;
num_run = 10;
nodeLists = cellfun(@(idx) idx(:),sensorPosIdx,'UniformOutput',false);
sensorPool = unique(vertcat(nodeLists{:}));
noiseDraws = cell(1,num_run);
for nRun = 1:num_run
    noiseDraws{nRun} = draw_noise(numel(sensorPool),numFeature);
end

for i = 1:numel(sensorArg) % each case
    nmse = [];
    sensors = sensorPosIdx{sensorArg(i)};
    [~,noiseRows] = ismember(sensors,sensorPool);
    for nRun   = 1:num_run
        for k = 1:numel(noise_level)
            y = T.sub_test(sensors,:);
            y = y + noise_level(k)*noiseDraws{nRun}(noiseRows,:);

            % Coefficient space
            a        = T.u(sensors,1:T.numModes)\y;

            reconLS  = T.u(:,1:T.numModes)*a;
            T_pred   = reconLS + repmat(T.mean,[1,numel(reconLS(1,:))]);
           

            [nmse(k,nRun),~] = error_estimation(T_pred,T_ref);
        end
    end
    case_(i).TS2TF_nmse      = nmse;
    case_(i).TS2TF_nmse_mean = mean(nmse,2);
    case_(i).TS2TF_nmse_std  = std(nmse,[],2);
end
save(fullfile(outputFolder,'reconstruciton_error_noise_TS2TF.mat'),"case_");

%--------------------------------------------------------------------------
% NMSE with error -> Temperature reconstruction
%--------------------------------------------------------------------------
% color and symbol
co=[1 0 0;
    0 0 1;
     1 1 0;
    rgb('green');
    rgb('black')];

lgd_name     =[{sprintf('Optimal sensors p=%d',numSensor)};{sprintf('Optimal constrained sensors p=%d',numSensor)};...
    {'Optimal constrained sensors p=44'};{'TALL-3D sensors p=44'};...
    {sprintf('Random sensors p=%d',numSensor)}];

FigHandle = figure; hold on
set(FigHandle, 'Position', [150, 80, 800, 600]);

for i = 1:numel(sensorArg) % each case    
    % Plot mean + bound
    f_mean = case_(i).TS2TF_nmse_mean;
    fLow   = case_(i).TS2TF_nmse_mean - case_(i).TS2TF_nmse_std;
    fHigh  = case_(i).TS2TF_nmse_mean + case_(i).TS2TF_nmse_std;
    
    fy    = [fLow; flipud(fHigh)]';
    fx    = [noise_level fliplr(noise_level)]; 
    if ismember(i,[1 2 3 4]) 
        ph(i) = plot(noise_level,f_mean,'-o','color',co(i,:),'linewidth',3); hold on;
        fill(fx,fy,co(i,:),'FaceAlpha',0.2,'EdgeColor',co(i,:),'EdgeAlpha',0.05);
    else
        ph(5) = plot(noise_level,f_mean,'-o','color',co(5,:),'linewidth',3); hold on;
        fill(fx,fy,co(5,:),'FaceAlpha',0.2,'EdgeColor',co(5,:),'EdgeAlpha',0.05);
    end
end

set(gca,'ytick',[1e-4 1e-3 1e-2  1e-1 1e0]);
set(gca,'ylim',[1e-4 1]);
% set(gca,'xlim',[0 0.05]);
set(gca, 'YScale', 'log')
% figure properties
xlabel('Noise level $\lambda$ [-]','interpreter','latex','fontsize',24,'fontname','times');
ylabel('NMSE [-]','interpreter','latex','fontsize',24,'fontname','times');
set(gca,'fontsize',22,'fontname','times'); 
legend(ph,lgd_name,'Position',[0.312707888645444,0.588888894451989,0.514584222709113,0.2499999944369],...
    'fontsize',18,'interpreter','latex','NumColumns',1);
legend('boxoff');
% grid on

saveName = fullfile(saveFolder,'NMSE_effects_sensors_location.png');
exportgraphics(FigHandle,saveName,'Resolution',450);

%--------------------------------------------------------------------------
% Compare coefficient matrix a 
%--------------------------------------------------------------------------
saveFolder = fullfile(dataLoc,'Figures','demo','coefficient');
mkdir(saveFolder);

% using optimal sensors 
sensors  = sensorPosIdx{1};     
a = cell(1,numel(noise_level));
y_clean = T.sub_test(sensors,:);
y_noise = draw_noise(size(y_clean,1),size(y_clean,2));

for k = 1:numel(noise_level)
    y = y_clean + noise_level(k)*y_noise;
    
    % Coefficient space
    a{k}       = T.u(sensors,1:T.numModes)\y;   
end

a_ref = pinv(T.u(:,1:T.numModes))*T.sub_test(:,:);


for mode_idx = 1:8
    FigHandle = figure; hold on
    set(FigHandle, 'Position', [150, 80, 600, 600]);
    
    xp = a_ref(mode_idx,:); 
    yp = a{1}(mode_idx,:);
    
    plot(xp,yp,'ro');
    
    xlim([min(xp),max(xp)]);
    ylim([min(yp),max(yp)]);
    
    set(gca,'fontsize',16,'fontname','times'); 
    
    xlabel('$a$','interpreter','latex','fontsize',18,'fontname','times');
    ylabel('$\widehat{a}$','interpreter','latex','fontsize',18,'fontname','times');
    set(gca,'xtick',[],'xticklabel',[]);
    set(gca,'ytick',[],'yticklabel',[]);
    axis equal;
    
    saveName = fullfile(saveFolder,sprintf('optimal_a_pred_ref_mode_%d.png',mode_idx));
    exportgraphics(FigHandle,saveName,'Resolution',300);
end

%--------------------------------------------------------------------------
% using optimal sensors under constraints
%--------------------------------------------------------------------------
sensors  = sensorPosIdx{2};     
a = cell(1,numel(noise_level));
y_clean = T.sub(sensors,:);
y_noise = draw_noise(size(y_clean,1),size(y_clean,2));

for k = 1:numel(noise_level)
    y = y_clean + noise_level(k)*y_noise;
    
    % Coefficient space
    a{k}       = T.u(sensors,1:T.numModes)\y;   
end

a_ref = pinv(T.u(:,1:T.numModes))*T.sub(:,:);


for mode_idx = 1:8

    FigHandle = figure; hold on
    set(FigHandle, 'Position', [150, 80, 600, 600]);
    
    xp = a_ref(mode_idx,:); 
    yp = a{1}(mode_idx,:);
    
    plot(xp,yp,'ro');
    
    xlim([min(xp),max(xp)]);
    ylim([min(yp),max(yp)]);
    
    set(gca,'fontsize',16,'fontname','times'); 
    
    xlabel('$a$','interpreter','latex','fontsize',18,'fontname','times');
    ylabel('$\widehat{a}$','interpreter','latex','fontsize',18,'fontname','times');
    set(gca,'xtick',[],'xticklabel',[]);
    set(gca,'ytick',[],'yticklabel',[]);
    axis equal;
    
    saveName = fullfile(saveFolder,sprintf('optimal_constraints_a_pred_ref_mode_%d.png',mode_idx));
    exportgraphics(FigHandle,saveName,'Resolution',300);
end

% save
save(fullfile(outputFolder,'optSensors.mat'),'optSensors');
save(fullfile(outputFolder,'train_test_index.mat'),'trainInd','testInd');