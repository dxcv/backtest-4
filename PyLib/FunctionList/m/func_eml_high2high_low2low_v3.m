function [eml_high2high, eml_low2low, eml_high2low, pos_minmax_raw, pos_minmax_last_valid, eml_delta_high2low] = ...
    func_eml_high2high_low2low_v3(eml_HP1000_30, cut_eml_high2high_low2low, cut_eml_high2high_low2low_ratio, cut_eml_bounce_highlow, cut_eml_high2low)

eml_low2low     = zeros(length(eml_HP1000_30),1);
eml_high2high   = zeros(length(eml_HP1000_30),1);
eml_high2low    = zeros(length(eml_HP1000_30),1);

cut_percent_delta  = 0.65;
len_lookback_delta = 6;
len_nearby_pass    = 20;
pos_minmax_raw          = zeros(length(eml_HP1000_30),2);
pos_minmax_last_valid   = ones(length(eml_HP1000_30),2);
status_min_init  = 0;
status_max_init  = 0;
idx_last_min_raw = 1;
idx_last_max_raw = 1;
for idx=2*len_lookback_delta+1:length(eml_HP1000_30)
    pos_minmax_last_valid(idx,1) = pos_minmax_last_valid(idx-1,1);
    pos_minmax_last_valid(idx,2) = pos_minmax_last_valid(idx-1,2);
    
    delta_left  = eml_HP1000_30(idx-len_lookback_delta) - eml_HP1000_30(idx-2*len_lookback_delta:idx-len_lookback_delta-1);
    delta_right = eml_HP1000_30(idx-len_lookback_delta) - eml_HP1000_30(idx-len_lookback_delta+1:idx);
    
    %update raw minmax
    if     length(find(delta_left<0))  > len_lookback_delta*cut_percent_delta ...  %local min
        && length(find(delta_right<0)) > len_lookback_delta*cut_percent_delta   
        if status_min_init==0 || status_max_init==0
            pos_minmax_last_valid(idx,1) = idx-len_lookback_delta;
            status_min_init=1;
            pos_minmax_raw(idx,1) = -1;  
            pos_minmax_raw(idx,2) = idx-len_lookback_delta;        
            continue;
        end        
        %if down enough to be a valid min
        %if eml_HP1000_30(idx-len_lookback_delta) - eml_HP1000_30(pos_minmax_last_valid(idx,2)) < -cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=-1)
        %idx_last_max = find(pos_minmax_raw(1:idx)==1,1,'last');
        %if eml_HP1000_30(idx-len_lookback_delta) - eml_HP1000_30(pos_minmax_raw(idx_last_max,2)) < -cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=-1)
        [val_max_min2min, pos_max_min2min] = max(eml_HP1000_30(pos_minmax_last_valid(idx,1):idx-len_lookback_delta));
        pos_max_min2min = pos_max_min2min + pos_minmax_last_valid(idx,1) - 1;
        if min(eml_HP1000_30(pos_max_min2min:idx-len_lookback_delta-1)) < eml_HP1000_30(idx-len_lookback_delta)
            continue;
        end
        if eml_HP1000_30(idx-len_lookback_delta) - val_max_min2min < -cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=-1)
            pos_minmax_raw(idx,1) = -1;  
            pos_minmax_raw(idx,2) = idx-len_lookback_delta;        
            idx_last_min_raw = idx-len_lookback_delta; 
        end                        
    elseif length(find(delta_left>0))  > len_lookback_delta*cut_percent_delta ... %local max
        && length(find(delta_right>0)) > len_lookback_delta*cut_percent_delta        
        if status_min_init==0 || status_max_init==0
            pos_minmax_last_valid(idx,2) = idx-len_lookback_delta;
            status_max_init=1;
            pos_minmax_raw(idx,1) = 1;  
            pos_minmax_raw(idx,2) = idx-len_lookback_delta;        
            continue;
        end    
        %if up enough to be a valid max        
        %if eml_HP1000_30(idx-len_lookback_delta) - eml_HP1000_30(pos_minmax_last_valid(idx,1)) > cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=1)
        %idx_last_min = find(pos_minmax_raw(1:idx)==-1,1,'last');
        %if eml_HP1000_30(idx-len_lookback_delta) - eml_HP1000_30(pos_minmax_raw(idx_last_min,2)) > cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=1)        
        [val_min_max2max, pos_min_max2max] = min(eml_HP1000_30(pos_minmax_last_valid(idx,2):idx-len_lookback_delta));
        pos_min_max2max = pos_min_max2max + pos_minmax_last_valid(idx,2) - 1;
        if max(eml_HP1000_30(pos_min_max2max:idx-len_lookback_delta-1)) > eml_HP1000_30(idx-len_lookback_delta)
            continue;
        end
        if eml_HP1000_30(idx-len_lookback_delta) - val_min_max2max > cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=1)
            pos_minmax_raw(idx,1) = 1;  
            pos_minmax_raw(idx,2) = idx-len_lookback_delta;        
            idx_last_max_raw = idx-len_lookback_delta; 
        end
    end
    
    %update last valid minmax
    if pos_minmax_last_valid(idx,1)~=idx_last_min_raw
        if eml_HP1000_30(idx) - eml_HP1000_30(idx_last_min_raw) > cut_eml_bounce_highlow
            pos_minmax_last_valid(idx,1) = idx_last_min_raw;
        end
    end
    if pos_minmax_last_valid(idx,2)~=idx_last_max_raw
        if eml_HP1000_30(idx) - eml_HP1000_30(idx_last_max_raw) < -cut_eml_bounce_highlow
            pos_minmax_last_valid(idx,2) = idx_last_max_raw;
        end
    end        
end


%calculate high2high, low2low, high2low
eml_delta_high2low  = zeros(length(eml_HP1000_30),1);
eml_delta_high2high = zeros(length(eml_HP1000_30),1);
eml_delta_low2low   = zeros(length(eml_HP1000_30),1);

for idx=2:length(eml_HP1000_30)    
    eml_low2low(idx)     = eml_low2low(idx-1);
    eml_high2high(idx)   = eml_high2high(idx-1);
    eml_high2low(idx)    = eml_high2low(idx-1);
        
    %1.min compare in min point
    if pos_minmax_raw(idx,1)==-1 && pos_minmax_last_valid(idx,1)~=1
        cut_eml_high2high_low2low_temp = min(max(cut_eml_high2high_low2low, range(eml_HP1000_30(pos_minmax_last_valid(idx,1):pos_minmax_raw(idx,2)))*cut_eml_high2high_low2low_ratio ), 2*cut_eml_high2high_low2low);
        eml_delta_low2low(idx) = eml_HP1000_30(pos_minmax_raw(idx,2)) - eml_HP1000_30(pos_minmax_last_valid(idx,1));
        if     eml_delta_low2low(idx) > cut_eml_high2high_low2low_temp 
            eml_low2low(idx) = 1;
        elseif eml_delta_low2low(idx) < -cut_eml_high2high_low2low_temp 
            eml_low2low(idx) = -1;
        else
            eml_low2low(idx) = 0;
        end                  
    %2.max compare in max point    
    elseif pos_minmax_raw(idx,1)==1 && pos_minmax_last_valid(idx,2)~=1
        cut_eml_high2high_low2low_temp = min(max(cut_eml_high2high_low2low, range(eml_HP1000_30(pos_minmax_last_valid(idx,2):pos_minmax_raw(idx,2)))*cut_eml_high2high_low2low_ratio ),2*cut_eml_high2high_low2low);
        eml_delta_high2high(idx) = eml_HP1000_30(pos_minmax_raw(idx,2)) - eml_HP1000_30(pos_minmax_last_valid(idx,2));
        if     eml_delta_high2high(idx) > cut_eml_high2high_low2low_temp %&& eml_HP1000_30(idx)>30
            eml_high2high(idx) = 1;
        elseif eml_delta_high2high(idx) < -cut_eml_high2high_low2low_temp %&& eml_HP1000_30(idx)<30
            eml_high2high(idx) = -1;
        else
            eml_high2high(idx) = 0;
        end                      
    %3.break point compare, extra
    else
        %a point lower than last min a lot
        if pos_minmax_last_valid(idx,1)~=1 
            cut_eml_high2high_low2low_temp = min(max(cut_eml_high2high_low2low, range(eml_HP1000_30(pos_minmax_last_valid(idx,1):idx))*cut_eml_high2high_low2low_ratio ), 2*cut_eml_high2high_low2low);
            if eml_HP1000_30(idx) - eml_HP1000_30(pos_minmax_last_valid(idx,1)) < -cut_eml_high2high_low2low_temp
                [val_max_min2min, pos_max_min2min] = max(eml_HP1000_30(pos_minmax_last_valid(idx,1):idx));
                pos_max_min2min = pos_max_min2min + pos_minmax_last_valid(idx,1) - 1;
                if min(eml_HP1000_30(pos_max_min2min:idx-len_lookback_delta)) < eml_HP1000_30(idx)
                    continue;
                end
                if eml_HP1000_30(idx) - val_max_min2min < -cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=-1)
                    eml_low2low(idx) = -1; 
                end
            end             
        end
        
        %a point higher than last max a lot
        if pos_minmax_last_valid(idx,2)~=1
            cut_eml_high2high_low2low_temp = min(max(cut_eml_high2high_low2low, range(eml_HP1000_30(pos_minmax_last_valid(idx,2):idx))*cut_eml_high2high_low2low_ratio ), 2*cut_eml_high2high_low2low);                        
            if eml_HP1000_30(idx) - eml_HP1000_30(pos_minmax_last_valid(idx,2)) > cut_eml_high2high_low2low_temp
                [val_min_max2max, pos_min_max2max] = min(eml_HP1000_30(pos_minmax_last_valid(idx,2):idx));
                pos_min_max2max = pos_min_max2max + pos_minmax_last_valid(idx,2) - 1;
                if max(eml_HP1000_30(pos_min_max2max:idx-len_lookback_delta)) > eml_HP1000_30(idx)
                    continue;
                end
                if eml_HP1000_30(idx) - val_min_max2max > cut_eml_bounce_highlow && all(pos_minmax_raw(idx-len_nearby_pass+1:idx,1)~=1)
                    eml_high2high(idx) = 1; 
                end
            end                         
        end        
    end
               
    %4.min max area compare 
    if     pos_minmax_raw(idx,1)==-1 && pos_minmax_last_valid(idx,2)~=1
        %eml_delta_high2low(idx) = mean(eml_HP1000_30(pos_minmax_last_valid(idx,2):pos_minmax_raw(idx,2)));
        idx_last_max=find(pos_minmax_raw(1:idx,1)==1,1,'last');
        eml_delta_high2low(idx) = mean(eml_HP1000_30(pos_minmax_raw(idx_last_max,2):pos_minmax_raw(idx,2)));
        if     eml_delta_high2low(idx) > cut_eml_high2low
            eml_high2low(idx) = 1;
        elseif eml_delta_high2low(idx) < -cut_eml_high2low
            eml_high2low(idx) = -1;
        else
            eml_high2low(idx) = 0;
        end  
    elseif pos_minmax_raw(idx,1)==1 && pos_minmax_last_valid(idx,1)~=1
        %eml_delta_high2low(idx) = mean(eml_HP1000_30(pos_minmax_last_valid(idx,1):pos_minmax_raw(idx,2)));
        idx_last_min=find(pos_minmax_raw(1:idx,1)==-1,1,'last');
        eml_delta_high2low(idx) = mean(eml_HP1000_30(pos_minmax_raw(idx_last_min,2):pos_minmax_raw(idx,2)));
        if     eml_delta_high2low(idx) > cut_eml_high2low
            eml_high2low(idx) = 1;
        elseif eml_delta_high2low(idx) < -cut_eml_high2low
            eml_high2low(idx) = -1;
        else
            eml_high2low(idx) = 0;
        end
    end
end



end