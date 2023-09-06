function output_image = convert_dicom_to_uint8(dcm_img,dcm_info)

window_center = dcm_info.WindowCenter;
window_width = dcm_info.WindowWidth;
rescale_slope = dcm_info.RescaleSlope;
rescale_intercept = dcm_info.RescaleIntercept;

output_image = zeros(size(dcm_img));
new_image = zeros(size(dcm_img));
max_pixel_intensity = 255;

for i = 1:size(dcm_img,1)
    for j = 1:size(dcm_img,2)
        new_image(i, j) = dcm_img(i, j) * rescale_slope + rescale_intercept;
        if (new_image(i, j) < (window_center - window_width / 2))
            output_image(i, j) = 0;
        else
            if (new_image(i, j) > (window_center + window_width / 2))
                output_image(i, j) = max_pixel_intensity;
            else
                output_image (i, j) = (max_pixel_intensity / window_width) * (new_image(i, j) + window_width / 2 - window_center);
            end
        end
    end
end
output_image = uint8(output_image);

end
