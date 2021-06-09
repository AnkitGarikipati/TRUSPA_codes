function [phantom_image] = load_phantom(phantom_file_name)
%load_phantom: loads phantom image
% input: phantom image file name as a string, ex: "image.png"
% output: phantom image matrix

phantom_image = rgb2gray(imread(phantom_file_name));
end
