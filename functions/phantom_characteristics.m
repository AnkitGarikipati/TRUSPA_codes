function [] = phantom_characteristics(tissues_list, phantom_image, mesh_name, bckgrnd_pxl_intensity)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[rows, cols] = size(phantom_image); % phantom image should be same dimensions as mesh 
phantom_map = size(phantom_image); 
phantom_map(1:rows, 1:cols) = phantom_image;

% phantom_map(rows+1,1:cols) = phantom_image(rows,:);
% phantom_map(1:rows,cols+1) = phantom_image(:,cols);
% phantom_map(rows+1,cols+1) = phantom_image(rows,cols);

mesh_spec = load_mesh(mesh_name);
x_dim = cols; % -30 mm to +30mm lateral direction
y_dim = rows; % 0mm to +60mm depth dimension
mesh_resolution = 0.1; % mesh resolution is .1mm
map_x = zeros(1,mesh_dim);map_y = zeros(1,mesh_dim); % creating a map for the absorbers
map_x(1,:) = -(x_dim/2):0.1:(x_dim/2); % 
map_y(1,:) = 0:mesh_resolution:y_dim; % 
map_y = fliplr(map_y); % flip because of inverted coordinates for MATLAB matrix?

mesh_anom = mesh_spec;
mesh_back = mesh_spec;



for i = 1:length(mesh_spec.nodes) % looping through all the nodes/absorbers
    x_cord = mesh_spec.nodes(i,1); % getting x and y-coords of the node/absorber
    y_cord = mesh_spec.nodes(i,2);

    col_ind = find(abs(map_x-x_cord)<0.01); % find indices in locations where there is a diff between actual value (x_cord) and map_x
    row_ind = find(abs(map_y-y_cord)<0.01);

    map_val = phantom_map(row_ind,col_ind); % getting the corresponding pixel value from the phantom bitmap

    % depending on the value of the bitmap at the absorber coordinates, will assign the
    % appropriate optical properties, ex: if pixel value at (200,200) is
    % 255, that absorber will be designated as bone, and be assigned the
    % optical properties for bone 
    
    % map_val = 200
    
    for tissue = tissue_list
        if map_val ~= tissue.pixel_intensity
            continue
        end
        
        % background mesh
        if tissue.pixel_intesity == bckgrnd_pxl_intensity
            mesh_back.region(i,1) = 1;
            mesh_back.sa(i,1) = tissue.sa;
            mesh_back.sp(i,1) = tissue.sp;
            mesh_back.ri(i,1) = tissue.ri;
            mesh_back.c(i,1) = tissue.c;
            
            for j=1:len(tissues_list)
                if tissues_list(j).region ~= tissue.region
                    mesh_back.conc(i,j) = 0;
                else
                    mesh_anom.conc(i,j) = 1;
                end
            end
        end
        
        if map_val == tissue.pixel_intensity
            mesh_anom.region(i,1) = tissue.region;
            mesh_anom.sa(i,1) = tissue.sa;
            mesh_anom.sp(i,1) = tissue.sp;
            mesh_anom.ri(i,1) = tissue.ri;
            mesh_anom.c(i,1) = tissue.c;
            
            for j=1:len(tissues_list)
                if tissues_list(j).region ~= tissue.region
                    mesh_anom.conc(i,j) = 0;
                else
                    mesh_anom.conc(i,j) = 1;
                end
            end
        end
    end
    
end

    
plotmesh(mesh_anom,'spec');
save_mesh(mesh_anom,'mesh_anom');

end

