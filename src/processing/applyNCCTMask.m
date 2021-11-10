function newImg = applyNCCTMask(oldImg,mask)
    oldImg_r = oldImg(:,:,1);
    oldImg_g = oldImg(:,:,2);
    oldImg_b = oldImg(:,:,3);
    oldImg_r(~mask) = 0;
    oldImg_g(~mask) = 0;
    oldImg_b(~mask) = 0;
    
    newImg = uint8(zeros(size(oldImg)));
    newImg(:,:,1) = oldImg_r;
    newImg(:,:,2) = oldImg_g;
    newImg(:,:,3) = oldImg_b;
end