function [T, X, Y, solid_idx] = load_data(data_folder)
%LOAD_DATA Join the demo temperature blocks on their shared TALL-3D mesh.
    mesh = load(fullfile(data_folder,'mesh.mat'),'xmesh','ymesh','solid_idx');
    blocks = dir(fullfile(data_folder,'block_*.mat'));
    temperature_blocks = cell(1,numel(blocks));
    for i = 1:numel(blocks)
        block = load(fullfile(data_folder,blocks(i).name),'temperature');
        temperature_blocks{i} = block.temperature;
    end
    T.field = cat(2,temperature_blocks{:});  % Mesh nodes by snapshots
    X = mesh.xmesh(:);
    Y = mesh.ymesh(:);
    solid_idx = mesh.solid_idx(:);
end
