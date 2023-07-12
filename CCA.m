function [label,p] = CCA(data,target_f, Fs, N)
% 本部分代码源于网络并进行了修改
[~,T]= size(data);
t=1/Fs:1/Fs:T/Fs;
for f_k=1:length(target_f)
    Y=[];
    for n=1:N 
        Y=cat(1,Y,cat(1,sin(2*pi*target_f(f_k)*n*t),cos(2*pi*target_f(f_k)*n*t)));
    end
    meanx=mean(data,2);
    meany=mean(Y,2);
    s11=0;s22=0;s12=0;s21=0;
    for i1=1:T
        s11=s11+(data(:,i1)-meanx)*(data(:,i1)-meanx)';
        s22=s22+(Y(:,i1)-meany)*(Y(:,i1)-meany)';
        s12=s12+(data(:,i1)-meanx)*(Y(:,i1)-meany)';
        s21=s21+(Y(:,i1)-meany)*(data(:,i1)-meanx)';
    end
    s11=s11/(T-1);
    s22=s22/(T-1);
    s12=s12/(T-1);
    s21=s21/(T-1);
    [~,eigvaluea]=eig(inv(s11)*s12*inv(s22)*s21);
    [evaluea, ~] = sort(-diag(eigvaluea));
    evaluea=-evaluea;
    p(f_k)=max(sqrt(evaluea));
end
[~,index]=max(p);
label = target_f(index);
end


