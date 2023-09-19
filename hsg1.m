clear;
clc;
%在matlab中，灰度级如果是以uint8(八位二进制)形式储存的，则其范围是0~255
%如果是以double形式储存的，则其范围为0~1
%两者的转换：im2double(IM);uint8(DBL);
im1=imread('nacht1.jpg');
im2=rgb2gray(im1);
subplot(211),imshow(im1),title("Oringal Image");
subplot(212),imshow(im2),title("Gray Image");
%连通成分标记
sz=size(im2);
k=floor(im2/16);
%V集合设置
re=zeros(sz);
%初始化连通成分矩阵
num=1;
re(1,1)=num;
for j=2:sz(1)
    if k(j,1)~=k(j-1,1)
        num=num+1;
    end
    re(j,1)=num;
end
%初步的编号
for j=1:sz(1)
    for i=2:sz(2)
        if k(j,i)~=k(j,i-1)
            num=num+1;
            re(j,i)=num;
        else
            re(j,i)=re(j,i-1);
        end
    end
end
%先将每一行内部相邻的相似像素统一编号
for j=2:sz(1)
    for i=2:sz(2)
        if ((k(j-1,i)==k(j,i))&&(re(j-1,i)~=re(j,i)))
            if re(j-1,i)<re(j,i)
                sbs=find(re==re(j,i));
                re(sbs)=re(j-1,i);
            else
                sbs=find(re==re(j-1,i));
                re(sbs)=re(j,i);
            end
        end
    end
end
%四邻域相连通的成分编号在一起
for j=2:sz(1)
    for i=2:sz(2)
        if ((k(j-1,i-1)==k(j,i))&&(re(j-1,i-1)~=re(j,i)))
            if re(j-1,i-1)<re(j,i)
                sbs=find(re==re(j,i));
                re(sbs)=re(j-1,i-1);
            else
                sbs=find(re==re(j-1,i-1));
                re(sbs)=re(j,i);
            end
        end
    end
end
for j=2:sz(1)
    for i=1:(sz(2)-1)
        if ((k(j-1,i+1)==k(j,i))&&(re(j-1,i+1)~=re(j,i)))
            if re(j-1,i+1)<re(j,i)
                sbs=find(re==re(j,i));
                re(sbs)=re(j-1,i+1);
            else
                sbs=find(re==re(j-1,i+1));
                re(sbs)=re(j,i);
            end
        end
    end
end
%八邻域相连通的成分编号在一起
reu=unique(re);
siz=size(reu);
for i=1:siz(1)
    rev=reu(i);
    subs=find(re==rev);
    re(subs)=i;
end
%编号整理、排序
ord=zeros(siz(1),2);
ta=tabulate(re(:));
for i=1:siz(1)
    [ei,ej]=find(re==i);
    sumy=sum(ei)/ta(i,2);
    sumx=sum(ej)/ta(i,2);
    ord(i,1)=sumx;
    ord(i,2)=sumy;
end
%把每一个连通域内所有像素坐标值加和求平均得到中心坐标
imshow(im2);
hold on;
for i=1:siz(1)
    text(ord(i,1),ord(i,2), num2str(i),'Color', 'r') 
end 




%直方图均衡化
subplot(211),histogram(im2);
title('Histogram of Original Picture');
freq2=tabulate(im2(:));
aa=size(freq2);
freq1=zeros(256,3);
for i=1:aa(1)
    aaa=freq2(i,1);
    freq1(aaa+1,:)=freq2(i,:);
end
%有些亮度级没有，需要补零
freq=0.01*freq1(:,3);
%生成频率向量
%subplot(212),plot(freq);
%range=max(max(im2))-min(min(im2));
pp=cumsum(freq);
pp=255*pp;
%变换函数
im3=zeros(size(im2));
for i=1:256
    a=find(im2==i-1);
    im3(a)=pp(i,1);
end
subplot(221),histogram(im2);
subplot(222),histogram(im3);
subplot(223),imshow(im2);
%subplot(224),imshow(im3,[min(min(im2)),max(max(im2))]);
subplot(224),imshow(uint8(im3));
%imshow是一个自动的函数


%canny算子
sigma=1.6;
nn=5;
gg=zeros(nn,nn);%高斯算子初始化
for i=1:nn
    for j=1:nn
        gg(i,j)=exp(-(i^2+j^2)/(2*sigma^2))/(2*pi*sigma);
    end
end
gg=gg/sum(gg(:));
im3=im2double(im2);
im4=zeros((sz(1)-2*floor(nn/2)),(sz(2)-2*floor(nn/2)));%新图像初始化
[a,b]=size(im4);
for i=1:a
    for j=1:b
        mid=gg.*im3([i:i+4],[j:j+4]);
        im4(i,j)=sum(mid(:));
    end
end
%卷积运算，高斯平滑
subplot(221),imshow(im3);
subplot(222),imshow(im4);
p=zeros(a-2,b-2);
q=zeros(a-2,b-2);
m=zeros(a-2,b-2);
the=zeros(a-2,b-2);
for i=1:(a-2)
    for j=1:(b-2)
        p(i,j)=im4(i,j+2)-im4(i,j)+2*(im4(i+1,j+2)-im4(i+1,j))+im4(i+2,j+2)-im4(i+2,j);
        q(i,j)=im4(i+2,j)-im4(i,j)+2*(im4(i+2,j+1)-im4(i,j+1))+im4(i+2,j+2)-im4(i,j+2);
        m(i,j)=sqrt(p(i,j)*p(i,j)+q(i,j)*q(i,j));
        the(i,j)=atan2(q(i,j),p(i,j));  %q/p,y/x,即与x轴正半轴的夹角  
    end
end
%sobel算子求梯度

im5=zeros(a-4,b-4);
for i=2:(a-3)
    for j=2:(b-3)
        if (the(i,j)<=(pi/8))&&(the(i,j)>=(-pi/8))||(the(i,j)>=(7*pi/8))&&(the(i,j)<=(-7*pi/8))
            if (m(i,j)>=m(i,j+1))&&(m(i,j)>=m(i,j-1))
                im5(i-1,j-1)=m(i,j);
            end
        elseif (the(i,j)>(pi/8))&&(the(i,j)<=(3*pi/8))||(the(i,j)>(-7*pi/8))&&(the(i,j)<=(-5*pi/8))
            if (m(i,j)>=m(i+1,j+1))&&(m(i,j)>=m(i-1,j-1))
                im5(i-1,j-1)=m(i,j);
            end
        elseif (the(i,j)>(3*pi/8))&&(the(i,j)<=(5*pi/8))||(the(i,j)<=(-3*pi/8))&&(the(i,j)>(-5*pi/8))
            if (m(i,j)>=m(i+1,j))&&(m(i,j)>=m(i-1,j))
                im5(i-1,j-1)=m(i,j);
            end
        else
            if (m(i,j)>=m(i-1,j+1))&&(m(i,j)>=m(i+1,j-1))
                im5(i-1,j-1)=m(i,j);
            end
        end  
    end
end
%分四个梯度方向，非极大值抑制

%双阈值检测和连结边缘
%低于阈值1的像素点会被认为不是边缘；高于阈值2的像素点会被认为是边缘；
%在阈值1和阈值2之间的像素点,若其8领域内有高于阈值2的像素点，则被认为是边缘，否则被认为不是边缘。
tl=0.1;%低阈值
th=0.25;%高阈值
[aa,bb]=size(im5);
im6=zeros(size(im5));
for i=2:aa-1
    for j=2:bb-1
        if im5(i,j)>=th %高通
            im6(i,j)=im5(i,j);
        elseif (im5(i,j)>=tl) && (max(max(im5(i-1:i+1,j-1:j+1)))>=th)
            %介于两阈值之间的依其8领域进行判断
            im6(i,j)=im5(i,j);
        end
    end
end
% for i=2:aa-1
%     for j=2:bb-1
%         if im6(i,j)>5;
%             im6(i,j)=1;
%         end
%     end
% end
%边缘强化
subplot(221),imshow(im5);
subplot(222),imshow(im6), title('Canny Edge detection results'); 
im7=edge(im2,'Canny');
subplot(223),imshow(im7);
%matlab自带的canny算子的处理结果


