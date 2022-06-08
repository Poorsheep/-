function varargout = untitled(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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

function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;
image1=imread('1.bmp');
axes(handles.axes1);
imshow(image1);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on mouse press over axes background.

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global im;
%图像预处理
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image=im;
l1=rgb2gray(image);%将RGB图像转换成灰度图像
level=graythresh(l1);%使用OTSU方法计算图像全局阈值
imshow(l1);
l2=im2bw(l1,level);%通过阈值处理将图像转换为二值图像
figure,imshow(l2);
l3=~l2;
l4=bwareaopen(l3,50);
l5=~l4;
l6=edge(l1,'canny');%在一幅亮度图像中寻找边缘
l7=imclose(l6,strel('rectangle',[2,19]));%对图像进行闭运算  创建形态学矩形结构元素
l8=imopen(l7,strel('rectangle',[2,19]));%对图像进行开运算
%figure,imshow(l8);
l9=imopen(l8,strel('rectangle',[2,19]));%对图像进行开运算 
figure,imshow(l9);
[L,num]=bwlabel(l9,8);%对二值图像进行形态学操作
STATS=regionprops(L,'all');%测量图像区域的属性
a=length(STATS);
%figure,imshow(L);

%hold on;
b=0;
for i=1:a
    temp=STATS(i).BoundingBox;
    s=temp(3)*temp(4);
    if s>b
        b=s;
        k=i;%记录面积最大的标记区域的索引值
    end
end
temp=STATS(k).BoundingBox;
Rx=round(temp(1));Ry=round(temp(2));%提取条形码区域左上角的坐标
Rwidth=round(temp(3));Rlength=round(temp(4));


%初始化
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_left = [13,25,19,61,35,49,47,59,55,11;...	%左边数据编码，奇
              39,51,27,33,29,57, 5,17,9,23];	%左边数据编码，偶
check_right = [114,102,108,66,92,78,80,68,72,116];	%右边数据编码
first_num = [31,20,18,17,12,6,3,10,9,5];    %第一位数据编码
bar = im;  %读输入条形码图片
bar_Gray = rgb2gray(bar);   %将RGB图片转换灰度图

[a_hist x] = imhist(bar_Gray);   %计算和显示图像的直方图，绘制灰度直方图，返回直方图数据向量a_hist，和相应的色彩值向量x

%寻找进行二值化处理的阈值，存放在T中
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hist_max = [];
if a_hist(1)>a_hist(2)
    hist_max = [hist_max 1];
end
x = max(x);
for i=2:x
    if a_hist(i)>a_hist(i-1) && a_hist(i)>a_hist(i+1)
        hist_max = [hist_max i];
    end
end
if a_hist(x)<a_hist(x+1)
    hist_max = [hist_max x+1];
end
[m,n] = size(hist_max);
k = 0;
max_1 = 0;
max_2 = 0;
for i=1:n
    if k<a_hist(hist_max(i))
        k = a_hist(hist_max(i));
        max_1 = hist_max(i);
    end 
end
temp = a_hist(max_1);
a_hist(max_1) = 0;
k = 0;
for i=1:n
    if k<a_hist(hist_max(i))
        k = a_hist(hist_max(i));
        max_2 = hist_max(i);
    end
end
a_hist(max_1) = temp;
if max_1>max_2
    k = max_1;
    max_1 = max_2;
    max_2 = k;
end
T = max_1;
k = a_hist(max_1);
for i=max_1:max_2
    if k>a_hist(i)
        k = a_hist(i);
        T = i;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[m,n] = size(bar_Gray); %求灰度图的大小
for i=1:m        %对图像进行二值化处理
    for j=1:n
        if bar_Gray(i,j)>T    %选择适当的阈值进行二值化处理
            bar_10(i,j) = 1;
        else
            bar_10(i,j) = 0;
        end
    end
end

imshow(bar_10);
hold on;
plot(Rx,Ry,'b*');
plot(Rx+Rwidth,Ry+Rlength,'b*');


%检测59根条形码
l = 0;      %记录条形码的行数
 for i=(Ry-2):(Ry+Rlength+2)  
    k = 1;
    l = l+1;
    for j=(Rx-2):(Rx+Rwidth+2)
        if bar_10(i,j)~=bar_10(i,j+1)   %比较同一行相邻两点的颜色是否一致
            bar_y(l,k) = j; %记录转折点的横坐标
            k = k+1;    %准备记录下一个数据点
        end
        if k>61 %点数大于60，该行应该删掉
            l = l-1;
            break
        end
    end
    if k<61 %点数小于60，该行应该删掉
        l = l-1;
    end
end
[m,n] = size(bar_y);%条形码部分所占空间的大小
if m<=1 %查看条形码是否有效
    code = '0';
    str=num2str(m);
    set(handles.text4,'string',str);
    return
end
for i=1:m            %计算每根条形码的宽度
    for j=1:n-1
        bar_num(i,j) = bar_y(i,j+1) - bar_y(i,j);
        if bar_num(i,j)<0
            bar_num(i,j) = 0;
        end
    end
end
bar_sum = sum(bar_num)/m;   %求每根条形码宽度的平均值
k = 0;
for i=1:59   %计算59根条形码的总宽度
    k = k + bar_sum(i);
end
k = k/95;   %计算单位条形码的宽度
for i=1:59  %计算每根条形码所占位数
    bar_int(i) = round(bar_sum(i)/k);
end
k = 1;
for i=1:59  %将条形码转换成二进制数
    if rem(i,2)
        for j=1:bar_int(i)  %黑色条用1表示
            bar_01(k) = 1;
            k = k+1;
        end
    else
        for j=1:bar_int(i)  %白色空用0表示
            bar_01(k) = 0;
            k = k+1;
        end
    end
end
if ((bar_01(1)&&~bar_01(2)&&bar_01(3))...   %判断起始符是否正确
        &&(~bar_01(46)&&bar_01(47)&&~bar_01(48)&&bar_01(49)&&~bar_01(50))...    %判断中间分隔符是否正确
        &&(bar_01(95)&&~bar_01(94)&&bar_01(93)))    %判断终止符是否正确
    l = 1;
    for i=1:6   %将左侧42位二进制数转换为十进制数
        bar_left(l) = 0;
        for k=1:7
            bar_left(l) = bar_left(l)+bar_01(7*(i-1)+k+3)*(2^(7-k));
        end
        l = l+1;
    end
    l = 1;
    for i=1:6   %将右侧42位二进制数转换为十进制数
        bar_right(l) = 0;
        for k=1:7
            bar_right(l) = bar_right(l)+bar_01(7*(i+6)+k+1)*(2^(7-k));
            k = k-1;
        end
        l = l+1;
    end
end
num_bar = '';
num_first = 0;
first = 2;
for i=1:6   %从左边数据编码表中查出条形码编码数字
    for j=0:1
        for k=0:9
            if bar_left(i)==check_left(j+1,k+1)
                num_bar = strcat(num_bar , num2str(k));
                switch first    %记录左边数据的奇偶顺序
                    case 2
                        first = j;
                        break;
                    case 1
                        num_first = num_first + j*(2^(6-i));
                        break;
                    case 0
                        num_first = num_first + ~j*(2^(6-i));
                        break;
                    otherwise
                        break;
                end
            end
        end
    end
end
for i=1:6   %从右边数据编码表中查出条形码编码数字
    for j=0:9
        if bar_right(i)==check_right(j+1)
            num_bar = strcat(num_bar , num2str(j));
        end
    end
end
for i=0:9   %从第一位数据编码表中查出第一位数字
    if num_first==first_num(i+1)
        num_bar = strcat(num2str(i) , num_bar);
        break;
    end
end

if numel(num_bar)~=13
   str='Please Turn It Around!';
    set(handles.text4,'string',str);
    
  return
end

check_code = 0;
for i=1:12  %计算校验码
    if rem(i,2)
        check_code = check_code + str2num(num_bar(i));
    else
        check_code = check_code + str2num(num_bar(i))*3;
    end
end
check_code = rem(check_code,10);
if check_code>0
    check_code = 10 - check_code;
end

if check_code==str2num(num_bar(13)) %判断校验码是否正确
    code = num_bar
else
  str='Please Turn It Around!';
    set(handles.text4,'string',str);
    return
end
set(handles.text1,'string',code);
set(handles.text4,'string','');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text1,'string','');
[filename,pathname]=...
    uigetfile({'*.jpg';'*.tif';'*.bmp';'*.gif';'*.*'},'选择图片');
if pathname == 0
    return;
end
str=[pathname filename];
global im;
im=imread(str);
axes(handles.axes1);
imshow(im);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
