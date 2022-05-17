function image_values = rgb2values(image, colormap, modality)

switch modality
    case 'CBF'
        maxV = 60;
        minV = 0;
    case 'CBV'
        maxV = 4;
        minV = 0;
    case 'MTT'
        maxV = 12;
        minV = 0;
    case 'TTP'
        maxV = 25;
        minV = 0;
    case 'DLY'
        maxV = 10;
        minV = 0;
    case 'scale'
        maxV = 1;
        minV = 0;
    case 'gray' %Colormaps that have look-up-table 0-255
        maxV = 255;
        minV = 0;
    case 101 %Colormaps that have look-up table 0-100
        maxV = 100;
        minV = 0;
    case 201 %Colormaps that have look-up table 0-200
        maxV = 200;
        minV = 0;
    case 401 %Colormaps that have look-up table 0-400 ie. Rainbow_4
        maxV = 400;
        minV = 0;
    otherwise
        ME = MException('MyComponent:noSuchModality', ...
            'modality %s not found',modality);
        throw(ME)
end
        
Red = image(:,:,1);
Green = image(:, :, 2);
Blue = image(:, :, 3);

colormap_Red = (colormap(:,1)*256);
colormap_Green = (colormap(:,2)*256);
colormap_Blue = (colormap(:,3)*256);

dims = size(image); x = dims(2) ;y = dims(1);

image_values = zeros(y,x);

scaler = size(colormap,1)-1;

for i = 1:y
    for j = 1:x
        if Red(j,i) == 0 && Green(j,i) == 0 && Blue(j,i) == 0 %Meant to increase performance
            image_values(j,i) = 0;
        else
            try
                image_values(j,i) = ((find(colormap_Red == Red(j,i) & colormap_Green == Green(j,i) & colormap_Blue == Blue(j,i)) - 1)/scaler)*(maxV-minV) + minV;
            catch
                values = [colormap_Red - double(Red(j,i))*ones(scaler + 1,1), colormap_Green - double(Green(j,i))*ones(scaler + 1,1), colormap_Blue - double(Blue(j,i))*ones(scaler + 1,1)]';
                [~, closestValue] = min(vecnorm(values));
                image_values(j,i) = (closestValue-1)/scaler*(maxV-minV) + minV;
            end
        end
    end
end
end
