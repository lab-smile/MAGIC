function [closestValue, Searching] = rgb2v_iterative_deepending(Rainbow_R, red, Rainbow_G, green, Rainbow_B, blue, factor)

closestValue = find(Rainbow_R <= red + factor & Rainbow_R >= red - factor & Rainbow_G <= green + factor & Rainbow_G >= green - factor & Rainbow_B <= blue + factor & Rainbow_B >= blue - factor);
%This is not behaving as intended
dim = size(closestValue);
if dim == [0 , 1]
    Searching = true;
elseif dim(1) > 1 
    Searching = false;
    closestValue = min(closestValue);
else
    Searching = false;
end

end