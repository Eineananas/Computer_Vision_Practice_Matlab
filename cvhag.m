function varargout = cvhag(varargin)
% CVHAG MATLAB code for cvhag.fig
%      CVHAG, by itself, creates a new CVHAG or raises the existing
%      singleton*.
%
%      H = CVHAG returns the handle to a new CVHAG or the handle to
%      the existing singleton*.
%
%      CVHAG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVHAG.M with the given input arguments.
%
%      CVHAG('Property','Value',...) creates a new CVHAG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cvhag_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cvhag_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cvhag

% Last Modified by GUIDE v2.5 18-Oct-2022 20:39:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cvhag_OpeningFcn, ...
                   'gui_OutputFcn',  @cvhag_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cvhag is made visible.
function cvhag_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cvhag (see VARARGIN)

% Choose default command line output for cvhag
handles.output = hObject;

set(handles.load,'Enable','on');
set(handles.mark,'Enable','off');
set(handles.canny,'Enable','off');
set(handles.histequi,'Enable','off');
set(handles.slider1,'Enable','off');
set(handles.a1,'Visible','on');
set(handles.a2,'Visible','on');
set(handles.a3,'Visible','on');
set(handles.a4,'Visible','on');
set(handles.a4,'Visible','on');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cvhag wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cvhag_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path]=uigetfile({'*.jpg';'*.bmp';'*.jpeg';'*.png'}, '打开文件');
image=[path file];
handles.file=image;
if (file==0)
    warndlg('请选择一张图片...') ;
end
[fpath, fname, fext]=fileparts(file);
validex=({'.bmp','.jpg','.jpeg','.png'});
found=0;
for (x=1:length(validex))
    if (strcmpi(fext,validex{x}))
        found=1;
        handles.img=imread(image);
%         handles.i=imread(image);
        handles.im2=rgb2gray(handles.img);
        axes(handles.a1);
        cla;
        imshow(handles.img);
        % a1图区先清除，imshow新图
        axes(handles.a2);
        cla;
        imshow(handles.im2);
        axes(handles.a3);
        cla;
        set(handles.mark,'Enable','on');
        set(handles.histequi,'Enable','on');
        set(handles.canny,'Enable','on');
        guidata(hObject,handles);
        break;
    end
end


% --- Executes on button press in mark.
function mark_Callback(hObject, eventdata, handles)
% 连通成分标记的程序
% hObject    handle to mark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sz=size(handles.im2);
k=zeros(sz);
sd=strel('disk',1);
im30=imclose(handles.im2,sd);
im30=imopen(im30,sd);
% im30=handles.im2;
% 去毛刺
for i=1:sz(1)
    for j=1:sz(2)
        if im30(i,j)>140
            k(i,j)=1;
        else
            k(i,j)=0;
        end
    end
end
%V集合设置,二值化
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
%先将每一排内部相邻的相似像素统一编号
for j=2:sz(1)
    for i=2:sz(2)
        if ((k(j-1,i)==k(j,i))&&(re(j-1,i)~=re(j,i)))
            if re(j-1,i)<re(j,i)
                sbs=find(re==re(j,i));%返回索引
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
axes(handles.a3);
cla;
imshow(handles.im2);
hold on;
for i=1:siz(1)
    text(ord(i,1),ord(i,2), num2str(i),'Color', 'r') 
end 



% --- Executes on button press in histequi.
function histequi_Callback(hObject, eventdata, handles)
% hObject    handle to histequi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.a4);
cla;
histogram(handles.im2);
freq2=tabulate(handles.im2(:));
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
im3=zeros(size(handles.im2));
for i=1:256
    a=find(handles.im2==i-1);
    im3(a)=pp(i,1);
end
axes(handles.a5);
cla;
histogram(im3);
%subplot(224),imshow(im3,[min(min(im2)),max(max(im2))]);
axes(handles.a3);
cla;
imshow(uint8(im3));
%imshow是一个自动的函数


% --- Executes on button press in canny.
function canny_Callback(hObject, eventdata, handles)
% hObject    handle to canny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sz=size(handles.im2);
set(handles.slider1,'Enable','on');
sigma=1.6;
nn=5;
gg=zeros(nn,nn);%高斯算子初始化
for i=1:nn
    for j=1:nn
        gg(i,j)=exp(-(i^2+j^2)/(2*sigma^2))/(2*pi*sigma);
    end
end
gg=gg/sum(gg(:));
ima=im2double(handles.im2);
im4=zeros((sz(1)-2*floor(nn/2)),(sz(2)-2*floor(nn/2)));%新图像初始化
[a,b]=size(im4);
for i=1:a
    for j=1:b
        mid=gg.*ima([i:i+4],[j:j+4]);
        im4(i,j)=sum(mid(:));
    end
end
%卷积运算，高斯平滑
% subplot(221),imshow(ima);
% subplot(222),imshow(im4);
% sobel算子
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

handles.im7=im5;
guidata(hObject,handles);
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
for i=1:aa
    for j=1:bb
        if im6(i,j)>0;
            im6(i,j)=1;
        end
    end
end
%边缘强化
% subplot(221),imshow(im5);
axes(handles.a4);
cla;
axes(handles.a5);
cla;
axes(handles.a3);
cla;
imshow(im6); 

% im7 = edge(im2,'Canny');
%imshow(im7);
%matlab自带的canny算子的处理结果


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[aa,bb]=size(handles.im7);
rv=(get(hObject,'Value'));
ttl=0.05*(1-rv)+0.1;%低阈值
tth=0.125*(1-rv)+0.25;%高阈值
im8=zeros(size(handles.im7));
for i=2:aa-1
    for j=2:bb-1
        if handles.im7(i,j)>=tth %高通
            im8(i,j)=handles.im7(i,j);
        elseif (handles.im7(i,j)>=ttl) && (max(max(handles.im7(i-1:i+1,j-1:j+1)))>=tth)
            %介于两阈值之间的依其8领域进行判断
            im8(i,j)=handles.im7(i,j);
        end
    end
end
for i=2:aa-1
    for j=2:bb-1
        if im8(i,j)>(1-rv)
            im8(i,j)=1;%二值化
%         else
%             im8(i,j)=0;
        end
    end
end
axes(handles.a3);
cla;
imshow(im8); 
%边缘强化
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
