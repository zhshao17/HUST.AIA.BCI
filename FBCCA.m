clc,clear all;
warning off;
% % 设定分析的信号
% people = 1;
% block = 1;
Lable_FBCCA = [];
for people = 1:5
    for block = 1:2
        down_rate = 2; % 2倍降采样
        freqs = 8:0.3:13.7;% 目标信号的设置，按照pdf中的
        Fs = 1000; % 采样频率，按照pdf中的
        path = ['./data/S', num2str(people), '/block', num2str(block), '.mat'];
        data = load(path).data; % channel * times

        % 分割数据并保存,同时降采样
        data_split(data, people, block, down_rate)
        Fs = Fs/down_rate;

        % 滤波器的设置
        % 50HZ工频滤波
        d = designfilt('bandstopiir','FilterOrder',4, ...
            'HalfPowerFrequency1',48,'HalfPowerFrequency2',52, ...
            'DesignMethod','butter','SampleRate',Fs);
        % FBCCA 构建滤波器组
        Wp_high = 88;
        Ws_high = 84;
        Wp_low = [6 12 22 30 40 45 50 55];
        Ws_low = [8 16 26 35 45 50 55 60];
        alpha_p = 3; %通带允许最大衰减为  3db
        alpha_s = 20;%阻带允许最小衰减为  20db
        % 构建Lable
        Lable = [];
        for trail = 1:22
            path = ['./data/S', num2str(people), '/block' ,num2str(block),'-trail',...\
                num2str(trail), '.mat'];
            data_ = load(path).data_; % channel * times
            data_ = data_(1:10,:);
            % 滤除50HZ工频噪声
            y1 = filtfilt(d,data_');  % 滤除50hz后 times * channel

            N = length(data_(1,:));
            delta_f = 1*Fs/N;
            f = (-N/2:N/2-1)*delta_f;

            p_CF = [];
            for CF = 1:length(Wp_low)
                % 构建了多个滤波器
                wp = [Wp_low(CF) Wp_high ] / (Fs/2);  %通带截止频率,并对其归一化
                ws = [Ws_low(CF) Ws_high ] / (Fs/2);  %阻带截止频率,并对其归一化
                [ N3, wn ] = buttord( wp , ws , alpha_p , alpha_s);%获取阶数和截止频率
                [ b, a ] = butter(N3,wn,'bandpass');%获得转移函数系数
                %带通滤波
                y2 = filter(b,a,y1'); % channel * times
                [~, p] = CCA(y2, freqs, Fs, 5);
                p_CF  =[p_CF; p]; % CF * target_freq
            end
            % 进行处理
            A = 1.25;
            B = 0.25;
            n = 1:length(Wp_low);
            w = n.^(-1 * A) + B;
            value = p_CF.^2;
            value = w * value;
            [~, index] = max(value);
            lable = freqs(index);
            Lable = [Lable; (lable - 8)/0.3 + 1];
        end
        Lable_FBCCA = [Lable_FBCCA, Lable];
    end
end
result_table1=table(Lable_FBCCA);
writetable(result_table1, 'FBCCA_result.csv');


