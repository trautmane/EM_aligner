function [L] = add_translation_peggs(L, peg_npoints, peg_weight)
%%% add one really large tile that encompasses the entire box and add weak point-match peggs
n = peg_npoints; % number of fictitious points
fac = peg_weight; % weight of these points

L = get_bounding_box(L); % [xmin xmax ymin ymax];
L = update_XY(L);
t = tile;
t.id = -888;
t.H = L.box(4)-L.box(3);
t.W = L.box(2)-L.box(1);

[L, P, Pix, pcell] = update_XY(L, n); % generate points for each tile and "peg" onto the large tile

%% generate new point-match entries
tvalid = unique(L.pm.adj(:));
if ~isempty(tvalid)
    M = cell(numel(tvalid),2);
    W = cell(numel(tvalid),1);
    adj = zeros(numel(tvalid),2);
    largetileix = numel(L.tiles) + 1;
    np = zeros(1, numel(tvalid));
    for ix = 1:numel(tvalid)
        p = pcell{tvalid(ix)};
        M{ix,1} = -p;
        M{ix,2} =  0*p;
        adj(ix,:) = [tvalid(ix) largetileix];
        np(ix) = n;
        W{ix} = ones(1,n) * fac;
    end
    L.pm.M = [L.pm.M;M];
    L.pm.adj = [L.pm.adj;adj];
    L.pm.W = [L.pm.W;W];
    L.pm.np = [L.pm.np;np'];
end
L.tiles(end+1) = t;
