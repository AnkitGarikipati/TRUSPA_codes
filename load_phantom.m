function [phantom_image] = load_phantom(phantom_file_name)
%load_phantom: loads phantom image
% input: phantom image file name as a string, ex: "image.png"
% output: phantom image matrix

phantom_image = rgb2gray(imread(phantom_file_name));
end


% pxl_intensity = [64, 100, 150, 200, 255]
% den_list = [1300, 1200, 1105, 1234, 5555];
% den_map = zeros(size(phantom));
% for i in pxl/den_list
    % coords_i = phantom(phantom == i);
    % den_map(coords_i) = pxl(i);
    % 
% for i=1:601
    % for j=1:601
        