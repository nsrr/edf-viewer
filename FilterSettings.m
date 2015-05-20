function varargout = FilterSettings(varargin)
% FILTERSETTINGS MATLAB code for FilterSettings.fig
%      FILTERSETTINGS, by itself, creates a new FILTERSETTINGS or raises the existing
%      singleton*.
%
%      H = FILTERSETTINGS returns the handle to a new FILTERSETTINGS or the handle to
%      the existing singleton*.
%
%      FILTERSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTERSETTINGS.M with the given input arguments.
%
%      FILTERSETTINGS('Property','Value',...) creates a new FILTERSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FilterSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilterSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilterSettings

% Last Modified by GUIDE v2.5 15-Jan-2013 09:30:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilterSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @FilterSettings_OutputFcn, ...
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


% --- Executes just before FilterSettings is made visible.
function FilterSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FilterSettings (see VARARGIN)


% Get Filter Settings from main GUI
handles.filterSettingsStruct = varargin{1};

% assignin('base','FilterSettingH',handles.figure1);
handles.FilterSettingH = handles.figure1;

handles.PlotCode = [];


SelectedCh= handles.filterSettingsStruct.SelectedCh;
handles.SelectedCh = SelectedCh;

ChInfo = handles.filterSettingsStruct.ChInfo;
handles.ChInfo = ChInfo;

FileInfo = handles.filterSettingsStruct.FileInfo;
handles.FileInfo = FileInfo;

FilterPara = handles.filterSettingsStruct.FilterPara;
handles.FilterPara = FilterPara;

Sel = handles.filterSettingsStruct.Sel; 

SelectedChMap = [];
for i=1:size(SelectedCh,1)
    if SelectedCh(i,2)==0
        SelectedChMap{i,1} = ChInfo.Labels(SelectedCh(i,1),:);
    else
        SelectedChMap{i,1} = [ChInfo.Labels(SelectedCh(i,1),:) '-' ChInfo.Labels(SelectedCh(i,2),:)];
    end
    SelectedChMap{i,1}((SelectedChMap{i,1}==' '))=[];
end

% % Choose a default signal if one is not selected
% if ~isempty(varargin)
%     Sel = varargin{1};
% else
%     Sel = 1;
% end


set(handles.ListBoxCh,'String',SelectedChMap,'value',Sel);



set(handles.PopMenuHighPass,'string',{'    off' '   0.1 Hz' '   0.2 Hz' '   0.3 Hz'...
    '   0.5 Hz' '   0.8 Hz' '   1    Hz' '   1.6 Hz' '   2    Hz' '   4    Hz' ...
    '   5    Hz' ' 10    Hz' ' 20    Hz' ' 30    Hz' ' 40    Hz'});


Temp = ChInfo.nr(SelectedCh(Sel))/FileInfo.DataRecordDuration;
set(handles.EditSamplingRate,'string',Temp)

Temp = num2str(fix(FilterPara{Sel}.ScalingFactor*100));
set(handles.EditSensitivity,'string',Temp);

set(handles.PopMenuNotch,'value',FilterPara{Sel}.NotchValue);
set(handles.PopMenuLowPass,'value',FilterPara{Sel}.LowValue);
set(handles.PopMenuHighPass,'value',FilterPara{Sel}.HighValue);
set(handles.PushButtonColor,'BackGroundColor',FilterPara{Sel}.Color);

% Choose default command line output for FilterSettings
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
            
            
% UIWAIT makes FilterSettings wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FilterSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

handles.filterSettingsStruct.FilterPara = handles.FilterPara;
varargout{1} = handles.filterSettingsStruct;

delete(handles.figure1);

% --- Executes on selection change in ListBoxCh.
function ListBoxCh_Callback(hObject, eventdata, handles)
% hObject    handle to ListBoxCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListBoxCh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBoxCh

% SelectedCh=evalin('base','SelectedCh');
% ChInfo = evalin('base','ChInfo');
% FileInfo = evalin('base','FileInfo');
% FilterPara = evalin('base','FilterPara');

SelectedCh= handles.SelectedCh;
ChInfo = handles.ChInfo;
FileInfo = handles.FileInfo;
FilterPara = handles.FilterPara;


Sel = get(hObject,'value');

Temp = ChInfo.nr(SelectedCh(Sel))/FileInfo.DataRecordDuration;
set(handles.EditSamplingRate,'string',Temp);


Temp = num2str(fix(FilterPara{Sel}.ScalingFactor*100));
set(handles.EditSensitivity,'string',Temp);


set(handles.PopMenuNotch,'value',FilterPara{Sel}.NotchValue);
set(handles.PopMenuLowPass,'value',FilterPara{Sel}.LowValue);
set(handles.PopMenuHighPass,'value',FilterPara{Sel}.HighValue);
set(handles.PushButtonColor,'BackGroundColor',FilterPara{Sel}.Color);

handles.PlotCode = [];

guidata(hObject,handles);


function handles=UpdateFilters(handles)

% SelectedCh=evalin('base','SelectedCh');
% ChInfo = evalin('base','ChInfo');
% FileInfo = evalin('base','FileInfo');
% FilterPara = evalin('base','FilterPara');

SelectedCh= handles.SelectedCh;
ChInfo = handles.ChInfo;
FileInfo = handles.FileInfo;
FilterPara = handles.FilterPara;

SelCh = get(handles.ListBoxCh,'value');
SamplingRate = ChInfo.nr(SelectedCh(SelCh))/FileInfo.DataRecordDuration;


TotalFilterA=1;
TotalFilterB=1;


% notch filter
switch get(handles.PopMenuNotch,'value')

    case 2 % 60Hz Notch Filter

        wo = 60/(SamplingRate/2);  
        if wo>=1
            warndlg('Sampling rate is lower than notch filter');
            set(handles.PopMenuNotch,'value',1)
        else
            
            bw = wo/35;
            [B,A] = iirnotch(wo,bw); % design the notch filter for the given sampling rate
            
            TotalFilterA = conv(TotalFilterA,A);
            TotalFilterB = conv(TotalFilterB,B);
        end


    case 3 % 50Hz Notch Filter

        wo = 50/(SamplingRate/2);  bw = wo/35; % design the notch filter for the given sampling rate
        
        if wo>=1
            warndlg('Sampling rate is lower than notch filter');
            set(handles.PopMenuNotch,'value',1)
        else
            
            [B,A] = iirnotch(wo,bw);
            
            TotalFilterA = conv(TotalFilterA,A);
            TotalFilterB = conv(TotalFilterB,B);
            
        end


end

% low passs filtering
if get(handles.PopMenuLowPass,'value')>1
    Sel=get(handles.PopMenuLowPass,'value');
    Temp1=get(handles.PopMenuLowPass,'string');
    Temp = cell2mat(Temp1(Sel));
    Temp = str2num(Temp(1:end-2));
    
    Temp = Temp/SamplingRate*2;
    
    if Temp>=1
        warndlg('Sampling rate is lower than low pass filter settings');
        
        Sel = Sel+1;
        Temp = cell2mat(Temp1(Sel));
        Temp = str2num(Temp(1:end-2));
        Temp = Temp/SamplingRate*2;
        
        while Temp>=1
            Sel = Sel+1;
            Temp = cell2mat(Temp1(Sel));
            Temp = str2num(Temp(1:end-2));
            Temp = Temp/SamplingRate*2;
        end
        
        set(handles.PopMenuLowPass,'value',Sel)
        
    end
    
    [B,A] = butter(2,Temp,'low');
    
    TotalFilterA = conv(TotalFilterA,A);
    TotalFilterB = conv(TotalFilterB,B);

end


% High pass filtering
if get(handles.PopMenuHighPass,'value')>2

    Sel=get(handles.PopMenuHighPass,'value');
    Temp1=get(handles.PopMenuHighPass,'string');
    Temp = cell2mat(Temp1(Sel));
    Temp = str2num(Temp(1:end-3));
    
    
   Temp = Temp/SamplingRate*2;
    
    if Temp>=1
        warndlg('Sampling rate is lower than high pass filter settings');
        
        Sel = Sel-1;
        Temp = cell2mat(Temp1(Sel));
        Temp = str2num(Temp(1:end-2));
        Temp = Temp/SamplingRate*2;
        
        while Temp>=1
            Sel = Sel-1;
            Temp = cell2mat(Temp1(Sel));
            Temp = str2num(Temp(1:end-2));
            Temp = Temp/SamplingRate*2;
        end
        
        set(handles.PopMenuHighPass,'value',Sel)
        
    end
    
   
    [B,A] = butter(1,Temp,'high');

    TotalFilterA = conv(TotalFilterA,A);
    TotalFilterB = conv(TotalFilterB,B);
end



FilterPara{SelCh}.A = TotalFilterA;
FilterPara{SelCh}.B = TotalFilterB;
FilterPara{SelCh}.HighValue = get(handles.PopMenuHighPass,'value');
FilterPara{SelCh}.LowValue = get(handles.PopMenuLowPass,'value');
FilterPara{SelCh}.NotchValue = get(handles.PopMenuNotch,'value');

%assignin('base','FilterPara',FilterPara);
handles.FilterPara = FilterPara;


% --- Executes on button press in PushButtonColor.
function PushButtonColor_Callback(hObject, eventdata, handles)
% hObject    handle to PushButtonColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Temp=uisetcolor;

if ~(length(Temp)==1)
    handles.PlotCode = Temp;
    set(hObject,'BackgroundColor',Temp);
else
    handles.PlotCode = [];
end

guidata(hObject,handles);


% --- Executes on button press in PushButtonCancel.
function PushButtonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushButtonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ListBoxCh_Callback(handles.ListBoxCh, eventdata, handles);

% --- Executes on button press in PushButtonApply.
function PushButtonApply_Callback(hObject, eventdata, handles)
% hObject    handle to PushButtonApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=UpdateFilters(handles);

SelCh = get(handles.ListBoxCh,'value');
% FilterPara = evalin('base','FilterPara');
FilterPara = handles.FilterPara;

if ~isempty(handles.PlotCode)
    FilterPara{SelCh}.Color = handles.PlotCode;
end

TempText = get(handles.EditSensitivity,'string');
Temp = str2num(TempText)/100;

FilterPara{SelCh}.ScalingFactor = Temp;

handles.FilterPara =FilterPara;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in PushButtonClose.
function PushButtonClose_Callback(hObject, eventdata, handles)
% hObject    handle to PushButtonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1);
