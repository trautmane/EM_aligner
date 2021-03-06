function [obj,err,R, A, b, B, d, W, K, Lm, xout, LL2, U2, tB, td, invalid] = ...
    solve_affine_explicit_region(obj, opts)
% Returns the matrix solution for a contiguous regionusing an affine transform
%

%% default options are set here
% lsq_options.verbose         = 1;
lsq_options.solver          = 'backslash';%'cgs';%'tfqmr';%'gmres';%'pcg';%'bicgstab';%''symmlq';%minres';%'lsqlin';% ;%'lsqr';%'bicgstab' bicg tfqmr backslash
lsq_options.constraint      ='explicit';%'none';% 'similarity';% 'trivial';%
lsq_options.pdegree         = 1;
lsq_options.constraint_only = 0;
lsq_options.lidfix          = 0;
lsq_options.tfix            = 0;
lsq_options.constrain_edges = 1;

lsq_options.translation_fac = 1e0;
lsq_options.lambda          = 1e1;
lsq_options.edge_lambda     = 1e5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lsq_options.verbose         = 1;
lsq_options.dw              = [1 1 1 1 1 1];

% needed if iterative methods are used
lsq_options.ilu_droptol     = 1e-7;
lsq_options.use_ilu         = 0;
lsq_options.ilu_type        = 'ilutp';%'crout'; %'nofill';%%;
lsq_options.ilu_udiag       = 1;
lsq_options.L2              = [];
lsq_options.U2              = [];
lsq_options.A               = [];
lsq_options.b               = [];
lsq_options.B               = [];
lsq_options.d               = [];
lsq_options.tB              = [];
lsq_options.td              = [];
lsq_options.W               = [];
lsq_options.dw              = [];
lsq_options.restart         = 10;
lsq_options.tol             = 1e-10;
lsq_options.maxit           = 15000;
% needed only for trivial constraint
deg                                 = 180;
lsq_options.Rtfix           =  [cosd(deg) -sind(deg) 0; sind(deg) cosd(deg) 0; 0 0 1];
lsq_options.verbose         = 1;
lsq_options.debug           = 0;
lsq_options.LARGE           = 1e2;
lsq_options.nmax            = inf;
lsq_options.use_Tfac        = 0;
lsq_options.use_spmd        = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% override options provided in opts
if nargin>1,
    
    if isfield(opts, 'translation_fac'), lsq_options.translation_fac = ...
            opts.translation_fac;end
    if isfield(opts, 'solver'), lsq_options.solver = opts.solver;end
    if isfield(opts, 'pastix'), lsq_options.pastix = opts.pastix;end
    if isfield(opts, 'lambda'), lsq_options.lambda = opts.lambda;end
    if isfield(opts, 'edge_lambda'), lsq_options.edge_lambda = opts.edge_lambda;end
    if isfield(opts, 'constrain_edges'), lsq_options.constrain_edges = ...
            opts.constrain_edges;end
    if isfield(opts, 'lidfix'), lsq_options.lidfix = opts.lidfix; end
    if isfield(opts, 'tfix'), lsq_options.tfix = opts.tfix; end
    if isfield(opts, 'distributed'), lsq_options.distributed = ...
            opts.distributed; end
    if isfield(opts, 'pastix')
        if isfield(opts.pastix, 'ncpus'), split =  opts.pastix.ncpus;
        end
    end
    
end
%% solve
split = 0;
disp('----- WARNING: Overriding matrix split at generation');
if split==0
    [obj,err, R, A, b, B, d, W, K, Lm, xout, LL2, U2, tB, td, invalid] = ...
        alignTEM_solver(obj, [],  lsq_options);
    
elseif split
    %% split up generation of K matrix and Lm (vector)
    % % Remember:
    % K   = A'*W*A + lambda*(tB')*tB;
    % Lm  = A'*W*b + lambda*(tB')*td;
    % Can we just produce subsets (by column) of A and use that to calculate K
    % and Lm?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Splitting matrix generation');
    ncoeff = numel(obj.tiles) * 6;    
    tiles_per_worker = round(ncoeff/6./split);
    disp(['tiles_per_worker=' num2str(tiles_per_worker)]);
    c = zeros(split,2);
    for ix=1:split
        col_min = 1 + 6*(ix-1)*tiles_per_worker;
        if ix < split
            col_max = col_min   + 6*tiles_per_worker-1;
        else
            col_max = ncoeff;
        end
        c(ix,:) = [col_min col_max];
    end

    %%  generate vector d and matrix B
    d = zeros(ncoeff,1);
    pos = 0;
    for tix = 1:numel(obj.tiles)
       d(pos+1:pos+tdim) = obj.tiles(tix).tform.T(1:6);
       pos = pos + tdim;
    end
    tBd = ones(ncoeff,1);
    B = sparse(1:ncoeff, 1:ncoeff, tBd, ncoeff, ncoeff);

end


























