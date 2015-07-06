function [ DEG ] = rad2deg( RAD )

% rad2 deg:  converts radians to degrees
% includes formula for converting from atan2 


    if RAD < 0

        RAD = RAD + 2*pi

        %DEG = 360 - (abs(RAD) * 180/pi);

    end

DEG = RAD * 180/pi;

end


