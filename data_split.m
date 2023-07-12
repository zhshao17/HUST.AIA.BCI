function data_split(x, people, block, down_rate)
    trail_num = 0;
    data = [];
    for i = 1:length(x(11,:))
        if x(11,i) == 250
            disp('实验开始');
        elseif x(11,i) == 242
            disp('block 开始');
        elseif x(11,i) ==1
            disp('new trail');
            data = [];
            trail_num = trail_num + 1; % trail start
%             data = x(:, i);
        elseif x(11,i) ==0 && trail_num > 0
            data = [data, x(:, i)];
        elseif x(11, i) == 241 && trail_num >0
            disp('end trail');
            path_ = ['./data/S', num2str(people), '/block' ,num2str(block),'-trail',...\
                num2str(trail_num), '.mat'];
            
            % 保存之前先降采样
            data_ = down_sample(data, down_rate);
            % 保存
            save(path_, 'data_');
            disp('save trail');
        elseif x(11,i) == 243
            trail_num  = 0;
            disp('end block');
        elseif x(11, i) == 251
            disp('实验结束');
        end
    end
end

function data = down_sample(data, down_rate)
    % input:data: channel * times
    % outpput:y:% channel * times
    data = data'; % 变为times * channel
    data = downsample(data, down_rate); % times * channel
    data = data'; % channel * times
end


