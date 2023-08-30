function parsave(saveName,img)
%     switch varname
%         case 'MIP'
%             MIP = variable;
%         case 'rCBV'
%             rCBV = variable;
%         case 'TTP'
%             TTP = variable;
%         case 'rCBF'
%             rCBF = variable;
%         case 'MTT'
%             MTT = variable;
%         case 'Delay'
%             Delay = variable;
%         case 'NCCT'
%             NCCT = variable;
%     end
%     save(fname, varname);

    try
        writebmp(img,saveName);
    catch
        try
            writebmp(uint8(img),saveName);
        catch
            try
                imwrite(img,saveName,'bmp');
            catch
                imwrite(uint8(img),saveName,'bmp');
            end
        end
    end

        
end
