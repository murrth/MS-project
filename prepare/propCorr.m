function [rate, scale, nt] = propCorr(tOns,wbLock,waLock,ww,sw)
%
% analyse rate in rectengular time window
%
% input:    tOns    - target onset times relative to (or aligned on) microsaccade
%           wbLock  - window before lock
%           waLock  - window after lock
%           ww      - window width

% output:   rate    - proportion correct for interval
%           scale   - time axis (center of interval)
%           nt      - number of trials in which target appeared in interval aligned on microsaccade
            
% 12.12.2005 by Martin Rolfs; Modefied by Bonnie Lawrence

scale = [];
mw = 0;
for t = (wbLock+ww/2):sw:(waLock-ww/2) % -87.5 : 82.50  Center of each interval
    mw = mw + 1;    
    
    % Specifying begining and end of each interval
    w_beg = t-ww/2; % -100
    w_end = t+ww/2; % -75
    
    % Find index of target onsets (alinged on ms) that are in this interval
    idxMSwin = find(tOns(:,1)>=w_beg & tOns(:,1)<w_end); 

    % Calculate prop correct for trials in this interval
    nt(mw) = length(idxMSwin)  
    rate(mw) = sum(tOns(idxMSwin,2))/length(idxMSwin)     
    scale = [scale; t];
end

