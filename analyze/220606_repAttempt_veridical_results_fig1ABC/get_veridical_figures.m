function get_veridical_figures(dv_name, condition_name)

if strcmpi(dv_name, 'gpsd')
    if strcmpi(condition_name, 'control')
        jpeg_fname = 'GPSD_CONTROL.png';
    elseif strcmpi(condition_name, 'light')
        jpeg_fname = 'GPSD_LIGHT.png';
    end
elseif strcmpi(dv_name, 'pathlength')
    if strcmpi(condition_name, 'control')
        jpeg_fname = 'PATHL_CONTROL.png';
    elseif strcmpi(condition_name, 'light')
        jpeg_fname = 'PATHL_LIGHT.png';
    end 

elseif strcmpi(dv_name, 'clust')
    if strcmpi(condition_name, 'control')
        jpeg_fname = 'CLUST_CONTROL.png';
    elseif strcmpi(condition_name, 'light')
        jpeg_fname = 'CLUST_LIGHT.png';
    end     

end

gca
img = imread(jpeg_fname);
image(img);

end