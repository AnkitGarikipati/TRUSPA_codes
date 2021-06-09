% This is a main script to run combined US+PA simulations using the
% NIRFAST optical imaging and k-Wave acoustics toolboxes

% Necessary: need phantom bitmap/image (see operation manual)

%% User provided parameters 

phantom_string = "phantom.png"; % SPECIFY: phantom file name, as a string

% SPECIFY: optical characteristics for each tissue type, add as many
% structs as necessary
% make tissue1 as the background/most prominent tissue type
tissue1.pixel_intensity = 100;
tissue1.region = 1;
tissue1.sa = 0.001;
tissue1.sp = 0.66;
tissue1.ri = 1.3;
tissue1.c = 3e11/1.3;

tissue2.pixel_intensity = 200;
tissue2.region = 2;
tissue2.sa = 0.001;
tissue2.sp = 0.66;
tissue2.ri = 1.3;
tissue2.c = 3e11/1.3;

%CREATE: list with all the tissue characteristic structs
tissues_list = [tissue1, tissue2]; 

mesh_name = "mesh.rpt"; % mesh name
bkgrnd_pxl_intesity = 100; % SPECIFY: pxl intensity of background/most prominent tissue type

% SPEFCIFY: root (filepath)
root = 'C/blah/blah';

% SPECIFY: wavelengths form (800 nm, 789 nm, etc)
wv_vect = [800, 789];

% SPECIFY: acoustics struct
acoustics.pixel_intensities = [100, 200];
acoustics.densities = [1200, 1300];
acoustics.sound_speeds = [1537, 1540];

    
%% 

phantom_image = load_phantom(phantom_string); % load phantom image

[] = phantom_characteristics(tissues_list, phantom_image, mesh_name, bkgrnd_pxl_intesity);

[] = forward_solver(phantom_image, root, wv_vect);

[] = back_solver(phantom_image, root, acoustics, wv_vect);







