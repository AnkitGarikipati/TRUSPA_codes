# USPA_codes

Installation/Operation Manual for Combined Ultrasound/Photoacoustic Imaging Simulations using NIRFAST and kWave MATLAB toolboxes

About this Manual

- Purpose
This document provides detailed instructions regarding the installation and operation of the NIRFAST optics and k-Wave acoustics toolboxes (MATLAB), for the purpose of simulating combined ultrasound (US) and photoacoustic (PA) imaging. 

- Related Documentation 
A working knowledge and an up-to-date installation of MATLAB, particularly matrix/array operations, is presumed. Extensive documentation regarding MATLAB programming and its built-in functions/toolboxes can be found at https://www.mathworks.com/help/matlab/. 






1) Installation

1.1) NIRFAST Toolbox 
The NIRFAST toolbox can be installed at http://www.dartmouth.edu/~nir/nirfast/. For the purposes of US+PA simulations, only the “NIRFAST-Matlab” installation is required. This manual is based on the latest release, version 9.1 – released 3/28/2018. 
If newer releases of NIRFAST-Matlab are made available, and this manual has not yet been accordingly updated, all prior versions of the toolbox can be found at https://github.com/nirfast-admin/NIRFAST/releases. 
Unzip the download file and extracting to a desired location. In MATLAB, add the NIRFAST folder and all subfolders to the MATLAB path. Detailed instructions for doing so can be found here: https://www.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html. 
Important: The NIRFAST folder has multiple subfolders, remember to add the subfolders to the path as well.

1.2) k-Wave Toolbox
The k-Wave toolbox can be installed at http://www.k-wave.org/download.php. After unzipping the file, detailed installation instructions can either be found in the readme.txt file, or at http://www.k-wave.org/installation.php. 



2) Using the toolboxes

2.1) Basic Sequence of Events
There are “5?” number of steps needed to simulate a combined US+PA image using the NIRFAST and k-Wave toolboxes:
Step 	Function Call
1. Creating a bitmap to represent the in-silico tissue phantom being imaged.
	N/A
2. Creating an optical absorber, source, and detector mesh.
	Built-in “nirfast” command
3.  Defining the optical absorber characteristics, based on the tissue phantom.
	adding_bkgnd_char(…) & adding_frgnd_char(…) 
4. Simulate the light propagation and calculate the fluence and subsequent pressure (generated from PA effect) for each absorber. 	optics_forwardsolver(…)
5. Simulate the propagation of the resultant pressure wavefronts from the PA effect, as well as simulate the US imaging of the tissue phantom. This creates the final combined US+PA image?
	US_backsolver(…)
2.2) Creating the tissue phantom bitmap
Creating the in-silico tissue phantom bitmap is the first step in simulating combined US+PA imaging. 
The bitmap has two purposes:
1.	Define the geometry of the in-silico tissue phantom.
2.	Labelling the specific tissues in the phantom by assigning a specific pixel intensity to each tissue type. These intensity labels will be used later to identify each of the constituent tissues as well as define their optical characteristics. 
The image on the left shows a 600x600 8-bit prostate phantom bitmap. In it, the geometry of the tissue types is defined (rectum at bottom, prostate roughly central, etc.), as well as the associated intensity labels (prostate intensity = 
100, bladder intensity = 150, etc.). 
The bitmap can be created in any image design software (MS Paint, Adobe Illustrator/Photoshop, etc.). The example bitmap shown on the previous page was made with MS Paint. 
 For a more realistic bitmap, see https://field-ii.dk/examples/ftp_files/kidney/kidney_cut.bmp. In this example, the kidney bitmap is an actual tissue sample. 
2.3) Creating the optical mesh
The next step in the entire simulation process is creating the optical mesh using NIRFAST. 
In the MATLAB command window, enter the command, “nirfast”, exactly as shown (no quotation marks). 
After, the mesh creator window will pop-up. Follow the steps shown below. 














Make sure the size of the bitmap (in mm) corresponds to the size of the bitmap (in px). Ex: 600x600 bitmap corresponds to 60x60 (mm) mesh. Node distance of .1 mm results in 600x600 nodes, thus one node/absorber corresponds to one pixel. 
The mesh size can be a scale factor of the bitmap size, as long as the node distance value allows for 1 node/absorber for each pixel.


Will get 8 rpt files: 


The .rpt files contain the default spatial and optical characteristics of all the absorbers in the mesh. Each absorber’s location, chromophore concentration, scattering amplitude and scattering power is defined. 
Each absorber has a defined concentration of each of the chromophores (ex: 40% HbO, 10% deoxyHb, 50% Water). Based on the chromophore concentration distribution of the absorber, it’s scattering amplitude and power are also defined. While NIRFAST can pre-define these values, for most tissue phantoms 
NIRFAST has 6 default chromophores: HbO, deoxyHb, water, lipids, LuTex, and GDtex. It is important to note that these are only the default chromophores. While any of these pre-defined chromophores can be used if needed, they can also be used as placeholders for the chromophores in the tissue phantom. The optical mesh is created using any number/combination of these default chromophores, corresponding to the number of chromophores in the tissue sample. If 3 chromophores are defined in a tissue phantom (ex: bone, skin, soft tissue), any combination of 3 of the default chromophores can be chosen as placeholders. In the next 2 sections, defining the real chromophores and optical characteristics will be covered.
In addition to defining the characteristics of each absorber, the wavelength array must also be defined. The wavelength array provides the optical source wavelengths. In the above example, only 800 nm is used/defined, but a multiwavelength source can also be used.

Note: remember that optical characteristics come from literature
2.4) Defining the optical absorber characteristics
Using add_back.m, define the background tissue type, preferably the tissue type that would naturally surround the phantom being simulated. For example; the background tissue type could be soft tissue.
inputs: mesh size, rpt file, struct with scattering amplitude, scattering power, concentration, reflective index, and speed of light in background tissue
outputs: background mesh
While this may seem like an unnecessary step, it will used later in the pressure generation corrections. 
In the example above, soft tissue is the background. 

Using adding_blobs.m, define foreground characteristics. 
Inputs: mesh, mesh size, phantom bitmap, list of optical characteristic structs for each tissue type in bitmap (including pixel intensity values)
Outputs: foreground mesh
In the previous section, creating the optical mesh with the default chromophores was covered. There are two steps to defining the true characteristics of the phantom. 
The first step involves defining a background chromophore. Ideally, this will be the most prominent tissue in the phantom. For example, in the example bitmap shown previously, soft tissue was chosen as the background chromophore. 
In add_back.m, the optical mesh and the tissue bitmap are loaded. Then, for the entire mesh, every absorber is defined as having the optical characteristics of the background tissue/chromophore. This includes scattering amplitude/power, concentration, refractive index, and speed of light. 
The resulting mesh is entirely uniform and is saved as a separate mesh from the original. While it may seem redundant to create the background mesh, it will be used as a correction factor in the pressure calculations resulting from the simulated photoacoustic effect. 
The next step involves creating an optical mesh based on all the tissue types in the phantom. In adding_blobs.m, the original mesh and phantom are loaded. Using the pixel intensity tags of each of the tissue types, the corresponding absorber to each pixel will be defined with the tissue type’s characteristics. For example; if pixel (200,200) is soft tissue, absorber (200,200) will be defined as having the optical characteristics of soft tissue. This will be done for every pixel/absorber, and the new detailed mesh will be saved. 




2.5) Simulate the light propagation
Using running_forwardsolver.m:
Inputs: background mesh, foreground_mesh – both created in previous step, wavelength array
Outputs: struct with resultant photoacoustic pressure info for each absorber 
This script performs the finite element method (FEM) optical scattering simulation. Using the previously defined optical absorbers, we calculate the fluence properties of each. We can then calculate the resultant pressure/acoustic characteristics of each, based on the PA effect.
The calc_mua_mus() utilizes the mesh input and wavelength vector to calculate mua, mus, kappa and E values. In this script, the femdata_spectral() calculates the phase and amplitude data for a given spectral mesh at a given frequency (MHz) and wavelength. Following this, the fluence is calculated which along with mua_wv obtained from mua is used to provide us with the resultant pressure data. Fluence correction is applied to then obtained the corrected pressure data. Once this process is complete and the figures are generated, the script proceeds to export the nodal and scattered pressure data.

2.6) Simulate the propagation of the resultant pressure wavefronts
Inputs: phantom bitmap, mesh/bitmap size, list of structs with density/sound speed info for each tissue type, pressure data struct
Outputs: density/sound speed maps, simulated US+PA image 
back_solver_v2 simulates the acoustic behavior of the in-silico phantom, after a laser source has been "applied" unto it. Using the pressure data calculated from the optical simulation, we will simulate the behavior of the resultant acoustic wavefronts. 

The script loads the phantom bitmap and initializes sound speed and density matrices, both of which are dimensionally the same as the phantom bitmap. The sound speed values, which are fixed for each tissue type, are conferred to each pixel on the bitmap based on the greyscale value at that pixel. (include example?)

Density properties are imparted in a similar fashion. They key difference here is including tissue heterogeneity. In order to achieve this, density values for a given tissue type, based on its greyscale value in the phantom bitmap, is randomly picked from a range of values that varies marginally around the exact density value for a particular tissue. (include example?). In this way, when the script confers density values for a particular tissue type at a pixel location, it is not the same value that is being set each time. This is how tissue heterogeneity is achieved.

Once the density and acoustic properties are defined, the initial pressure map generated from the forward solver code is loaded. The k-grid is defined using the makeGrid() function.




