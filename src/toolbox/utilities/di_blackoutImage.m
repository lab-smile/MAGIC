function image = di_blackoutImage(path, instance_num, GType, age_PHI)
%DI_BLACKOUTIMAGE   Remove PHI present in DICOM dose summary image.
%   
% Calls to this function will remove PHI present in the pixel data of a
% DICOM dose summary image for a given DICOM CT series.
%----------------------------------------
% Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
%----------------------------------------
image = dicomread(path);

type2 = ~all(image(100,30,:)==image(80,60,:));

if length(size(image)) == 3
    if GType ~= 1
        if instance_num == 1
            sample_pix = image(240,30,:);
            
            flag = 0;
            for j = 240:size(image,1)
                for i = 30:size(image,2)
                    if ~all(image(j,i,:) == sample_pix)
                        flag = 1;
                        break;
                    end
                end
                if flag
                    break;
                end
            end
            start_y = j;
            
            image(100:140,205:950,1:3) = 0;
            image(140:180,390:950,1:3) = 0;
            image(180:220,410:950,1:3) = 0;
            
            image(start_y-10:start_y+70,200:600,1:3) = 0;
            
        else
            image(25:50,160:280,1:3) = 0;
            image(25:50,860:980,1:3) = 0;
            if type2
                image(65:100,255:700,1:3) = 0;
            end
        end
    else
        if instance_num == 1
            % vertical, then horizontal
            image(10:50,210:500,1:3) = 0;
            image(45:85,225:500,1:3) = 0;
            image(85:105,55:120,1:3) = 0;
            image(105:125,110:190,1:3) = 0;
            image(85:105,350:410,1:3) = 0;
            image(215:235,170:300,1:3) = 0;
            image(170:190,110:190,1:3) = 0;
            image(235:260,170:300,1:3) = 0;
            image(257:280,130:300,1:3) = 0;
            
            if age_PHI
                image(105:125,315:365,1:3) = 0;
            end
        else
            image(5:30,80:150,1:3) = 0;
            image(25:50,110:80,1:3) = 0;
            image(5:30,305:390,1:3) = 0;
            image(25:55,110:180,1:3) = 0;
        end
    end
    
elseif length(size(image)) == 2
    pix_min = min(min(image));
    
    if GType ~= 1
        if instance_num == 0
            image(100:175,400:650) = pix_min;
            image(240:320,270:400) = pix_min;
        else
            image(25:50,160:280) = pix_min;
            image(25:50,860:980) = pix_min;
        end
    else
        if instance_num == 0
            % vertical, then horizontal
            image(10:50,210:500) = pix_min;
            image(45:85,225:500) = pix_min;
            image(85:105,55:120) = pix_min;
            image(105:125,110:190) = pix_min;
            image(85:105,350:410) = pix_min;
            image(215:235,170:300) = pix_min;
            image(170:190,110:190) = pix_min;
            image(235:260,170:300) = pix_min;
            image(257:280,130:300) = pix_min;
            
            if age_PHI
                image(105:125,315:365) = pix_min;
            end
        else
            image(5:30,80:150) = pix_min;
            image(25:50,110:80) = pix_min;
            image(5:30,305:390) = pix_min;
            image(25:55,110:180) = pix_min;
        end
    end
end

end
