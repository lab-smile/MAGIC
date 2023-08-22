function imgs_aug = applyaugs(img, indication)

unit = size(img, 2) / 5;
imgA = img(:,1:unit,:); imgB = img(:,unit+1:unit*2,:); imgC = img(:,unit*2+1:unit*3,:);
imgD = img(:,unit*3+1:unit*4,:); imgE = img(:,unit*4+1:unit*5,:);

% AUG 1: REFLECTION
if numel(size(img))>2
    img_reflectedA = reflect_im(imgA);    img_reflectedB = reflect_im(imgB);
    img_reflectedC = reflect_im(imgC);    img_reflectedD = reflect_im(imgD);
    img_reflectedE = reflect_im(imgE);
    img_reflected = cat(2, img_reflectedA, img_reflectedB, img_reflectedC,... 
        img_reflectedD, img_reflectedE); 
else
    img_reflectedA = flip(imgA);    img_reflectedB = flip(imgB);
    img_reflectedC = flip(imgC);    img_reflectedD = flip(imgD);
    img_reflectedE = flip(imgE);
    img_reflected = cat(2, img_reflectedA, img_reflectedB, img_reflectedC,...
        img_reflectedD, img_reflectedE); 
end

% AUG 2: ROTATION (applied to mirrored and original)
r1 = rand * -10; r2 = rand * 10; % rotations % interpolation methods: 'nearest', 'bilinear', 'bicubic'
img_rot1A = imrotate(imgA,r1,'bicubic','crop'); img_rot2A = imrotate(imgA,r2,'bicubic','crop');
img_ref_rot1A = imrotate(img_reflectedA,r1,'bicubic','crop'); img_ref_rot2A = imrotate(img_reflectedA,r2,'bicubic','crop');
img_rot1B = imrotate(imgB,r1,'bicubic','crop'); img_rot2B = imrotate(imgB,r2,'bicubic','crop');
img_ref_rot1B = imrotate(img_reflectedB,r1,'bicubic','crop'); img_ref_rot2B = imrotate(img_reflectedB,r2,'bicubic','crop');
img_rot1C = imrotate(imgC,r1,'bicubic','crop'); img_rot2C = imrotate(imgC,r2,'bicubic','crop');
img_ref_rot1C = imrotate(img_reflectedC,r1,'bicubic','crop'); img_ref_rot2C = imrotate(img_reflectedC,r2,'bicubic','crop');
img_rot1D = imrotate(imgD,r1,'bicubic','crop'); img_rot2D = imrotate(imgD,r2,'bicubic','crop');
img_ref_rot1D = imrotate(img_reflectedD,r1,'bicubic','crop'); img_ref_rot2D = imrotate(img_reflectedD,r2,'bicubic','crop');
img_rot1E = imrotate(imgE,r1,'bicubic','crop'); img_rot2E = imrotate(imgE,r2,'bicubic','crop');
img_ref_rot1E = imrotate(img_reflectedE,r1,'bicubic','crop'); img_ref_rot2E = imrotate(img_reflectedE,r2,'bicubic','crop');

img_rot1 = cat(2, img_rot1A, img_rot1B, img_rot1C, img_rot1D, img_rot1E); 
img_rot2 = cat(2, img_rot2A, img_rot2B, img_rot2C, img_rot2D, img_rot2E); 
img_ref_rot1 = cat(2, img_ref_rot1A, img_ref_rot1B, img_ref_rot1C, img_ref_rot1D, img_ref_rot1E); 
img_ref_rot2 = cat(2, img_ref_rot2A, img_ref_rot2B, img_ref_rot2C, img_ref_rot2D, img_ref_rot2E); 

% AUG 3: TRANSLATION
x1 = rand * -30; y1 = ((rand * 2) - 1) * 30; % (-30, -30) to (0, 30)
x2 = rand * 30; y2 = ((rand * 2) - 1) * 30; % (0, -30) to (30, 30)

orig_t1 = apply_translation(x1, y1, imgA, imgB, imgC, imgD, imgE);
orig_t2 = apply_translation(x2, y2, imgA, imgB, imgC, imgD, imgE);
ref_t1 = apply_translation(x1, y1, img_reflectedA, img_reflectedB, img_reflectedC, img_reflectedD, img_reflectedE);
ref_t2 = apply_translation(x2, y2, img_reflectedA, img_reflectedB, img_reflectedC, img_reflectedD, img_reflectedE);
orig_rot_t1 = apply_translation(x1, y1, img_rot1A, img_rot1B, img_rot1C, img_rot1D, img_rot1E);
orig_rot_t2 = apply_translation(x2, y2, img_rot1A, img_rot1B, img_rot1C, img_rot1D, img_rot1E);
ref_rot_t1 = apply_translation(x1, y1, img_ref_rot1A, img_ref_rot1B, img_ref_rot1C, img_ref_rot1D, img_ref_rot1E);
ref_rot_t2 = apply_translation(x2, y2, img_ref_rot1A, img_ref_rot1B, img_ref_rot1C, img_ref_rot1D, img_ref_rot1E);


% ASSIGN TO FINAL STRUCT
switch indication
    case 'healthy'
        imgs_aug.img_original = img;
        imgs_aug.img_reflected = img_reflected;
    case 'unhealthy'
        imgs_aug.img_original = img;
        imgs_aug.img_reflected = img_reflected;
        imgs_aug.img_rot1 = img_rot1;
        imgs_aug.img_rot2 = img_rot2;
        imgs_aug.img_ref_rot1 = img_ref_rot1;
        imgs_aug.img_ref_rot2 = img_ref_rot2;
        imgs_aug.orig_t1 = orig_t1;
        imgs_aug.orig_t2 = orig_t2;
        imgs_aug.ref_t1 = ref_t1;
        imgs_aug.ref_t2 = ref_t2;
        imgs_aug.orig_rot_t1 = orig_rot_t1;
        imgs_aug.orig_rot_t2 = orig_rot_t2;
        imgs_aug.ref_rot_t1 = ref_rot_t1;
        imgs_aug.ref_rot_t2 = ref_rot_t2;
end
end

function img_reflectedA = reflect_im(imgA)
d1A = imgA(:,:,1); d2A = imgA(:,:,2); d3A = imgA(:,:,3);
img_reflectedA = cat(3, flip(d1A,2), flip(d2A,2), flip(d3A,2)); %horizontal reflection
end

function translated_im = apply_translation(x, y, imgA, imgB, imgC, imgD, imgE)
img_transA = imtranslate(imgA,[x,y]);
img_transB = imtranslate(imgB,[x,y]);
img_transC = imtranslate(imgC,[x,y]);
img_transD = imtranslate(imgD,[x,y]);
img_transE = imtranslate(imgE,[x,y]);

translated_im = cat(2, img_transA, img_transB, img_transC,...
        img_transD, img_transE);
end