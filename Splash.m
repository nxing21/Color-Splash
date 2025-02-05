function varargout = Splash(varargin)
% SPLASH MATLAB code for Splash.fig
% Author: Nick Xing

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @Splash_OpeningFcn, ...
                       'gui_OutputFcn',  @Splash_OutputFcn, ...
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
end

% --- Executes just before Splash is made visible.
function Splash_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to Splash (see VARARGIN)

    % Choose default command line output for Splash
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes Splash wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = Splash_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    global threshold;
    threshold = get(hObject, 'Value');
    changeColor(0);
    % changeMultiColor(0);
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --------------------------------------------------------------------
function load_Callback(hObject, eventdata, handles)
    % hObject    handle to load (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global fileName;
    [fileName, pathName] = uigetfile(append(pwd, '\*.jpg'),'Load image');

    global im_rgb im_yuv threshold rgb_cmap mask savedMask;
    threshold = 0.15;
    im_rgb_org = imread([pathName, fileName]);
    im_rgb = imresize(im_rgb_org, 0.5);
    im_yuv = colorspace('RGB->YUV',im_rgb);
    axes(handles.imageAxis);
    imageHandle = image(im_rgb);
    rgb_cmap = colormap;
    axis equal off;
    set(imageHandle, 'ButtonDownFcn', {@pickColor, handles});
    handles.imageHandle=imageHandle;
    guidata(hObject,handles);
    
    mask = uint8(zeros(size(im_rgb, 1), size(im_rgb, 2)));
    savedMask = mask;
end

function pickColor(hObject, eventdata, handles)
    global xpos ypos im_rgb rgb_cmap;
    img = im_rgb;
    xpos = round(eventdata.IntersectionPoint(2));
    ypos = round(eventdata.IntersectionPoint(1));
    
    roiSize = 3; % Half size
    xRange = max(1, xpos-roiSize) : min(size(img, 1), xpos+roiSize);
    yRange = max(1, ypos-roiSize) : min(size(img, 2), ypos+roiSize);
    roiR = img(xRange, yRange, 1);
    r = mean(roiR(:))/255;
    roiG = img(xRange, yRange, 2);
    g = mean(roiG(:))/255;
    roiB = img(xRange, yRange, 3);
    b = mean(roiB(:))/255;
    
    img(xRange, yRange, :) = 255;
    axes(handles.colorAxis);imagesc(cat(3, r, g, b));colormap(rgb_cmap);axis equal off;
    
    changeColor(1);
    % changeMultiColor(1);
    global threshold;
    set(handles.slider1, 'Value', threshold);
end
   
function changeColor(flag)
    global im_yuv xpos ypos mask savedMask;
    umap = im_yuv(:,:,2);
    vmap = im_yuv(:,:,3);
    roiSize = 3; % Half size
    xRange = max(1, xpos-roiSize) : min(size(umap, 1), xpos+roiSize);
    yRange = max(1, ypos-roiSize) : min(size(umap, 2), ypos+roiSize);
    uroi = umap(xRange, yRange);
    ucenter = mean(uroi(:));
    vroi = vmap(xRange, yRange);
    vcenter = mean(vroi(:));
    
    mask = calMask(umap, vmap, ucenter, vcenter, flag) + savedMask;
    mask(mask > 1) = 1;
    combineColorAndGray(mask);
end

function combineColorAndGray(mask)
    global im_rgb flag_fill_hole;
    if(flag_fill_hole)
        fillMask = imfill(mask, 'hole');
        titleName = 'With hole-filling';
    else
        fillMask = mask;
        titleName = 'Without hole-filling';
    end

    im_color(:,:,1) = im_rgb(:,:,1) .* fillMask;
    im_color(:,:,2) = im_rgb(:,:,2) .* fillMask;
    im_color(:,:,3) = im_rgb(:,:,3) .* fillMask;
    grayImage = rgb2gray(im_rgb) .* (1-fillMask);
    im_gray = cat(3, grayImage, grayImage, grayImage);
    im_final = im_gray + im_color;
    figure(1);imagesc(im_final);axis equal off;title(titleName)
end

function changeMultiColor(flag)
    global im_rgb im_yuv xpos ypos;
    umap = im_yuv(:,:,2);
    vmap = im_yuv(:,:,3);
    roiSizeX = 10; roiSizeY = 15;
    uRoi = umap(xpos-roiSizeX:xpos+roiSizeX, ypos-roiSizeY:ypos+roiSizeY);
    vRoi = vmap(xpos-roiSizeX:xpos+roiSizeX, ypos-roiSizeY:ypos+roiSizeY);
    binCount = 16;
    xbins = linspace(min(umap(:)), max(umap(:)), binCount+1);
    ybins = linspace(min(vmap(:)), max(vmap(:)), binCount+1);
    hCounts = histcounts2(uRoi(:), vRoi(:), xbins,ybins);

    [uId, vId] = find(hCounts > roiSizeX*roiSizeY*4*.1);
    multiMask = uint8(zeros(size(umap)));
    for id= 1:length(uId)
        uloc = uId(id);
        vloc = vId(id);
        uCenter = mean(xbins(uloc:uloc+1));
        vCenter = mean(ybins(vloc:vloc+1));
        multiMask = multiMask + calMask(umap, vmap, uCenter, vCenter, flag);
    end
    multiMask(multiMask > 1) = 1;

    im_color(:,:,1) = im_rgb(:,:,1) .* multiMask;
    im_color(:,:,2) = im_rgb(:,:,2) .* multiMask;
    im_color(:,:,3) = im_rgb(:,:,3) .* multiMask;
    grayImage = rgb2gray(im_rgb) .* (1-multiMask);
    im_gray = cat(3, grayImage, grayImage, grayImage);
    im_final = im_gray + im_color;
    figure(1);imagesc(im_final);axis equal off;title('Final Image')
end

function out = sigmoidCal(in, weight)
    out = 1.0 ./ (1.0 + exp(-in) .* weight);
end

function mask = calMask(umap, vmap, ucenter, vcenter, flag)
    global threshold;
    
    uCal = umap - ucenter;
    vCal = vmap - vcenter;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    binCount = 32;
    xbins = linspace(min(uCal(:)), max(uCal(:)), binCount+1);
    ybins = linspace(min(vCal(:)), max(vCal(:)), binCount+1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    uvCal = sqrt(uCal.^2 + vCal.^2);
    feather = 3.0;
    uvCal = uvCal*feather;
    uvCalSigmoid = sigmoidCal( uvCal, 1.0 );
    minValue = min( uvCalSigmoid(:) );
    uvCalSigmoidNormalize = uvCalSigmoid - minValue;
    maxValue = max( uvCalSigmoidNormalize(:) );
    uvCalSigmoidNormalize = uvCalSigmoidNormalize / maxValue;
    
    % Caluculate an 'optimal' threshold based on histogram
    if(flag)
        hCounts = histcounts(uvCalSigmoidNormalize,100);
        th = 0;
        percentage = .98;
        for hIndex = 3:50
            if(hCounts(hIndex)<hCounts(hIndex-1)*percentage && hCounts(hIndex-1)<hCounts(hIndex-2)*percentage && ...
               hCounts(hIndex)<hCounts(hIndex+1)*percentage && hCounts(hIndex+1)<hCounts(hIndex+2)*percentage)
                th = hIndex;
                break;
            end
        end
        if(th == 0)
            [mVal, mPos] = max(hCounts(3:20));
            mPos = mPos+2;
            for hIndex = mPos:50
                if(hCounts(hIndex) < mVal/10)
                    break;
                elseif(hCounts(hIndex)<hCounts(hIndex-1) && hCounts(hIndex-1)<hCounts(hIndex-2) && hCounts(hIndex)<mVal/5)
                    break;
                end
            end
            for hIndex = hIndex:60
                if(hCounts(hIndex+1)>=mVal/10)
                    break;
                end
            end
            th = hIndex;
        end
        mVal = max(hCounts);
        if(sum(hCounts(1:th))>sum(hCounts)*.8)
            th=20; % Use current default percentage 15% or 20%;
        end
        threshold = th/100;
    end
    
    mask = uint8(zeros(size(umap)));
    mask(uvCalSigmoidNormalize < threshold) = 1;
end

% --------------------------------------------------------------------
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
    global mask savedMask;
    savedMask = savedMask + mask;
end


% --------------------------------------------------------------------
function Clear_Callback(hObject, eventdata, handles)
% hObject    handle to Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global savedMask;
    savedMask = uint8(zeros(size(savedMask)));
    combineColorAndGray(savedMask);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global flag_fill_hole savedMask
flag_fill_hole = get(hObject,'Value');
if(~exist('savedMask'))
    savedMask = mask;
end
changeColor(0);
end