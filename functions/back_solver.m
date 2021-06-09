function [] = back_solver(phantom, root, acoustics_struct, wv_vect)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


    [rows, cols] = size(phantom_image);
    phantom_map = phantom_image;

    sound_speed_mat = zeros(rows, cols); %creates a zero matrix 601 x 601 for the sounds in each point of the medium
    density_mat = zeros(rows, cols);

    pixel_intensities = acoustics_struct.pixel_intensities;
    densities = acoustics_struct.densities;
    sound_speeds = acoustics_struct.sound_speeds;

    for i = pixel_intensities
        density_mat(phantom_map(phantom_map == 1)) = densities(i);
        sound_speed_mat(phantom_map(phantom_map == 1)) = sound_speeds(i);
    end
    
    
    for i = 1:rows
        for j = 1:cols
            % FIX
            density_mat(i,j) = randsample(linspace(0.997,1.003,41),1) * 1000;
            sound_speed_mat(i,j) = 2;
        end
    end

    figure;imshow(density_mat,[]);
    figure;imshow(sound_speed_mat,[]);

    save('density_mat.mat', 'density_mat');
    save('sound_speed_mat.mat', 'sound_speed_mat');

    % Root = '/gpfs/scratch/avg5966/phantom32'; 
    Root = root;
    n_wave = 1;
    n_sources = 500;%no. of detectors
    % wv_vect = [800];
    
    
    for i = 1:n_wave
        load(strcat('NIRdata',num2str(wv_vect(i)),'.mat'));%loading initial pressure generated from nirfast simulations (forward solver)

        figure;
        subplot(1,2,1);
        surf(NIRdata.x,NIRdata.y,NIRdata.ps2,'EdgeColor','none')%plotting ps at x , y to visualize
        NIRdata.y=NIRdata.y-30; %since we want it to move from -30 to 30
        NIR_size=size(NIRdata.x);

    %     PML_size = 40;          % size of the PML in grid points (perfectly matched layer used to prevent the reflections of the waves)
        PML_size = 150;          % added by T 31dec
        Nx = NIR_size(2);  % number of grid points in the x (row) direction (no. of pixels in the x direction)
        Ny = NIR_size(1);  % number of grid points in the y (column) direction (" " for y)
        dx = 0.1e-3;            % grid point spacing in the x direction [m]
        dy = 0.1e-3;            % grid point spacing in the y direction [m]
        kgrid = makeGrid(Nx, dx, Ny, dy); %defining the grid in k-wave, grid is same as mesh. 
        %subplot(1,2,2);
        %surf(kgrid.x,kgrid.y,zeros(size(kgrid.x))); %plot, initially puts 0 values (??)
        A = interp2(NIRdata.x/1000,NIRdata.y/1000,NIRdata.ps2,kgrid.x,kgrid.y,'linear'); % Initial pressure input to k-wave - p0, initial pressure mapped to k-grid
        figure(3);
        %subplot(1,2,2);
        h31=surf(kgrid.x,kgrid.y,A);
        set(h31, 'edgecolor','none')
        % define the properties of the propagation medium   
        medium.sound_speed = imrotate(sound_speed_mat,270);  % [m/s] imrotate used to move bottom side of mesh to the left in grid
        medium.density = imrotate(density_mat,270);      % [kg/m^3]
        % Define initial pressure distribution in the domain
        source.p0=A; %stores the initial pressures in A to source.p0 source is the structure
        % smooth the initial pressure distribution and restore the magnitude
        source.p0 = smooth(kgrid, source.p0, true);
        % define a binary line sensor
        sensor.mask = zeros(Nx, Ny); 
        %sensor.mask(:, 1) = 1;
        sensor.mask = makeLine(Nx, Ny, [((Nx-1)/2-128) 1], [((Nx-1)/2+127) 1]);%changed from (-64:63) to (-128:127)defines where the transducers are.
        sensor.mask(173:2:427,1)=0;
    %     sensor.mask = makeLine(Nx, Ny, [((Nx-1)/2-128) 50], [((Nx-1)/2+127) 50]);%changed from (-64:63) to (-128:127)defines where the transducers are.
    %     sensor.mask(173:2:427,50)=0; % added by T Jan5 2021   
        % create the time array
        [kgrid.t_array, dt] = makeTime(kgrid, medium.sound_speed); 
        % set the input arguements: force the PML to be outside the computational
        % grid; switch off p0 smoothing within kspaceFirstOrder2D
    %     input_args = {'PMLInside', false, 'PMLSize', PML_size, 'PlotPML', false, 'Smooth', false};
        input_args = {'PMLInside', false, 'PMLSize', PML_size, 'PlotPML', false, 'Smooth', false, 'RecordMovie', true, 'MovieName', 'wave_propagation', 'MovieArgs', {'FrameRate', 10}};
        %     sensor.frequency_response = [1e6, 100];
        % run the simulation
    %     sensor_data_temp1 = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});
        sensor_data_temp1 = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:},'DataCast','gpuArray-single');% mimics propagation and records the pressures at the transducers defined in ln80
        sensor_data_temp1 = gather(sensor_data_temp1);
        save(strcat('sensor_data',num2str(wv_vect(i)),'.mat'),'sensor_data_temp1');
        sensor.time_reversal_boundary_data = sensor_data_temp1;
        PA_Image = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:},'DataCast','gpuArray-single');
        PA_Image = gather(PA_Image);
        log_image = JW_LogCompress(PA_Image, 40); % added by T 29dec
        figure; imshow(imrotate(PA_Image, 90), []); % added by T 29dec
        %figure; imshow(imrotate(20*log10(PA_Image), 90), []); % added by T 29dec
        figure; imshow(imrotate(log_image, 90), []); % added by T 29dec
    end
end

