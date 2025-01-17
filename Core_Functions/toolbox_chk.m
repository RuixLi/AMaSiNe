function toolbox_chk
% Requires 3 matlab toolboxes ( Released later than 2017) :
% Computer vision system, image processing, parallel computing

warning('on')

matlab_version=ver;
toolbox_names={matlab_version(:).Name};
toolbox_Release={matlab_version(:).Release};

Index_matlab = find(strcmp(toolbox_names,'MATLAB'));
if ~isempty(Index_matlab)
    release_yr_matlab=str2double(regexp(toolbox_Release{Index_matlab},'\d+','match'));
    release_chk_matlab = release_yr_matlab >= 2017;
else
    release_chk_matlab = false;
end

if isempty(Index_matlab) ||  ~release_chk_matlab
    warning('MATLAB must be upgraded to version R2017a or above')
end

Index_vision = find(contains(toolbox_names,'Computer Vision'));
if ~isempty(Index_vision)
    release_yr_vision=str2double(regexp(toolbox_Release{Index_vision},'\d+','match'));
    release_chk_vision = release_yr_vision >= 2017;
else
    release_chk_vision = false;
end

if isempty(Index_vision) ||  ~release_chk_vision
    warning('Computer Vision System Toolbox must be installed or upgraded to version R2017a or above')
end

Index_image = find(strcmp(toolbox_names,'Image Processing Toolbox'));
if ~isempty(Index_image)
    release_yr_image=str2double(regexp(toolbox_Release{Index_image},'\d+','match'));
    release_chk_image = release_yr_image >= 2017;
else
    release_chk_image = false;
end

if isempty(Index_image) ||  ~release_chk_image
    warning('Image Processing Toolbox must be installed or upgraded to version R2017a or above')
end

Index_parallel = find(strcmp(toolbox_names,'Parallel Computing Toolbox'));
if ~isempty(Index_parallel)
    release_yr_parallel=str2double(regexp(toolbox_Release{Index_parallel},'\d+','match'));
    release_chk_parallel = release_yr_parallel >= 2017;
else
    release_chk_parallel = false;
end

if isempty(Index_parallel) ||  ~release_chk_parallel
    warning('Parallel Computing Toolbox must be installed or upgraded to version R2017a or above')
end

if release_chk_matlab+release_chk_vision+release_chk_image+release_chk_parallel<4
    error('Check the Warning Messages above')



end

