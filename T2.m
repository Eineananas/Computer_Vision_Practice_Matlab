%试识别下图中大、中、小圆形标记点，并计算各圆形标记点的中心坐标值。
clear;
clc;
im1=imread("lafoto.bmp");
%图像比较大，需要花费15倍的时间
[a,b]=size(im1);
im2=zeros(a,b);
for i=1:a
    for j=1:b
        if im1(i,j)<175
            %图像二值化处理
            %175这个边界是试出来的，要保证右上角的阴影与圆点分开；
            %又要保证圆点边缘全部囊括在内
            im2(i,j)=0;
        else
            im2(i,j)=1;
        end
        if i>2200
            im2(i,j)=0;
        end
        %最底下的一长条化成0，因为后面按照面积判断圆点大小进行标记的
        %最底下的一长条中要面积小的连通区域干扰
    end
end
imshow(im2);
se=strel('disk',5);
im2=imclose(im2,se);
im2=imopen(im2,se);
imshow(im2);
%先闭运算闭运弥合小缝隙，后开运算去除孤立的小点，毛刺和小桥

re=zeros(a,b);
%初始化连通成分编号矩阵
num=1;
re(1,1)=num;
for j=2:a
    if im2(j,1)~=im2(j-1,1)
        num=num+1;
    end
    re(j,1)=num;
end
for j=1:a
    for i=2:b
        if im2(j,i)~=im2(j,i-1)
            num=num+1;
            re(j,i)=num;
        else
            re(j,i)=re(j,i-1);
        end
    end
end
%先计算每一排内部
for j=2:a
    for i=2:b
        if ((im2(j-1,i)==im2(j,i))&&(re(j-1,i)~=re(j,i)))
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
for j=2:a
    for i=2:b
        if ((im2(j-1,i-1)==im2(j,i))&&(re(j-1,i-1)~=re(j,i)))
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
for j=2:a
    for i=1:(b-1)
        if ((im2(j-1,i+1)==im2(j,i))&&(re(j-1,i+1)~=re(j,i)))
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
ta=tabulate(re(:));
alf=find(ta(:,3)>0.05);
for i=1:a
    for j=1:b
        if ismember(re(i,j),alf)
            re(i,j)=0;
        end
    end
end
alf=find(ta(:,3)<0.002);
for i=1:a
    for j=1:b
        if ismember(re(i,j),alf)
            re(i,j)=0;
        end
    end
end
%alf为面积很大的连通区域，也就是背景，运用ismember和find把背景全部赋值为0
reu=unique(re);
[m,m1]=size(reu);
ta1=tabulate(re(:));
for i=1:m
    rev=reu(i);
    subs=find(re==rev);
    re(subs)=i-1;
end
%每一个圆占用的像素点按照从小到大进行编号

%0号是背景板，从1号开始
ord=zeros(m-1,2);
for i=1:m-1
    [ei,ej]=find(re==i);
    sumy=sum(ei)/ta1(i+1,2);
    sumx=sum(ej)/ta1(i+1,2);
    ord(i,1)=sumx;
    ord(i,2)=sumy;
end
%圆是对称图形，把圆内所有元素坐标值加和求平均得到圆心坐标
for i=1:m-1
    a=round(ord(i,2));
    b=round(ord(i,1));
    im2(a,b)=1;
end
imshow(im2);
hold on;
for i=1:m-1
    %rectangle('position',[ord(i,1)-18,ord(i,2)-18,36,36],'edgecolor','r');
    %text(ord(i,1)-18,ord(i,2)+18, num2str(i),'Color', 'r') 
    if ta1(i+1,2)>2000 && ta1(i+1,2)<5000
        text(ord(i,1)-30,ord(i,2)+30, '大','Color', 'b') ;
     elseif ta1(i+1,2)>800 && ta1(i+1,2)<1800
         text(ord(i,1)-18,ord(i,2)+18, '中','Color', 'b') ;
                %一般是1000~1100，这个有1200
    elseif ta1(i+1,2)<500 && ta1(i+1,2)>100
        text(ord(i,1)-18,ord(i,2)+18, '小','Color', 'b') ;
%     elseif ta1(i+1,2)<100
%         text(ord(i,1)-18,ord(i,2)+18, '超小','Color', 'b') ;
    end
end 
%总共226个圆点，按照每个圆所占有的像素数，共有四类大小不同的点





