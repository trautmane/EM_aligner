function resp = set_renderer_stack_state_loading(rc)
% Changes the state of a Renderer collection to loading
% Dependency: Eric T.'s manage-stack.sh
% rc is a Renderer collection struct
%
% Author: Khaled Khairy. Janelia Research Campus. 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verbose = 0;
check_input(rc);

str1 = sprintf('PROJECT_PARAMS="--baseDataUrl %s --owner %s --project %s";', rc.baseURL, rc.owner, rc.project); 
str3 = sprintf('TARGET_STACK="%s";', rc.stack);
str13 = sprintf('/groups/flyTEM/flyTEM/render/bin/manage-stack.sh ${PROJECT_PARAMS} --action SET_STATE --stackState LOADING --stack ${TARGET_STACK}');
strcmd = [str1 str3 str13];


try
    [a, resp] = system(strcmd);
catch err_cmd_exec
    kk_disp_err(err_cmd_exec);
    error(['Error executing: ' strcmd]);
end

if strfind(resp, 'caught exception'),
    disp(resp);
    error('renderer_stack_state_complete: server-side error reported');
end


if verbose,
    disp(strcmd);
    disp(a);
    disp(resp);
end

%%
function check_input(rc)
if ~isfield(rc, 'baseURL'), disp_usage; error('baseURL not provided');end
if ~isfield(rc, 'owner'), disp_usage; error('owner not provided');end
if ~isfield(rc, 'project'), disp_usage; error('project not provided');end
if ~isfield(rc, 'stack'), disp_usage; error('stack not provided');end


%%
function disp_usage()
disp('Usage:');
disp('Provide an input struct with fields: baseURL, owner, project, stack');