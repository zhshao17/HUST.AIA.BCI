clc,clear all;
warning off;
% 设定分析的信号
% people = 1;
% block = 2;
Label = [];
for people = 1:5
    for block = 1:2
        down_rate = 4; % 2倍降采样
        freqs = 8:0.3:13.7;% 目标信号的设置，按照pdf中的
        Fs = 1000; % 采样频率，按照pdf中的
        path = ['./data/S', num2str(people), '/block', num2str(block), '.mat'];
        data = load(path).data; % channel * times

        % 分割数据并保存,同时降采样
        data_split(data, people, block, down_rate)
        Fs = Fs/down_rate;

        % 利用CCA算法
        labels = [];
        P = [];
        for trail = 1:22
            path = ['./data/S', num2str(people), '/block' ,num2str(block),'-trail',...\
                num2str(trail), '.mat'];
            data_ = load(path).data_; % ch  annel * times
            data_ = data_(1:10,50:end-50);

            % 滤除50HZ工频噪声
            % t = (0:length(openLoop)-1)/Fs;
            d = designfilt('bandstopiir','FilterOrder',4, ...
                'HalfPowerFrequency1',48,'HalfPowerFrequency2',52, ...
                'DesignMethod','butter','SampleRate',Fs);
            y1 = filtfilt(d,data_'); % 滤除50hz后 times * channel
            y1 = y1'; % channel * times

            % 带通滤波
            wp = [4  90] / (Fs/2);  %通带截止频率
            ws = [8  80] / (Fs/2);  %阻带截止频率
            alpha_p = 3; %通带允许最大衰减为 3 db
            alpha_s = 20;%阻带允许最小衰减为20 db
            [ N3, wn ] = buttord( wp , ws , alpha_p , alpha_s);    %获取阶数和截止频率
            [ b, a ] = butter(N3,wn,'bandpass');    %获得转移函数系数
            y2 = filter(b,a,y1);

            [label, p] = CCA(y2, freqs, Fs, 5);
            labels = [labels; (label - 8)/0.3 + 1];
            P = [P; p];
        end
        Label = [Label, labels];
    end
end
result_table1=table(Label);
writetable(result_table1, 'CCA_label.csv');
