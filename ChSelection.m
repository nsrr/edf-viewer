function varargout = ChSelection(varargin)
% CHSELECTION M-file for ChSelection.fig
%      CHSELECTION, by itself, creates a new CHSELECTION or raises the existing
%      singleton*.
%
%      H = CHSELECTION returns the handle to a new CHSELECTION or the handle to
%      the existing singleton*.
%
%      CHSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHSELECTION.M with the given input arguments.
%
%      CHSELECTION('Property','Value',...) creates a new CHSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChSelection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChSelection

% Last Modified by GUIDE v2.5 27-Jan-2013 09:52:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @ChSelection_OutputFcn, ...
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


% --- Executes just before ChSelection is made visible.
function ChSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChSelection (see VARARGIN)

% Choose default command line output for ChSelection


% Process channelSelectionStruct
channelSelectionStruct = varargin{1};
handles.masterSelectionStruct = channelSelectionStruct;
handles.channelSelectionStructIn = channelSelectionStruct;
handles.channelSelectionStruct = channelSelectionStruct;
handles.channelSelectionStructOut = channelSelectionStruct;

handles.ChSelectionH = channelSelectionStruct.ChSelectionH;
handles.ChSelectionH = handles.figure1;
handles.SelectedCh = channelSelectionStruct.SelectedCh;
handles.ChInfo = channelSelectionStruct.ChInfo;
handles.FilterPara = channelSelectionStruct.FilterPara;

% handles.channelSelectionStructOut = [];
% for m = 1:length(channelSelectionStruct.FilterPara)
%     pstruct = channelSelectionStruct.FilterPara{m}
%     pstruct.Color
% end

handles.FlagSelectedCh = channelSelectionStruct.FlagSelectedCh;
handles.FlagChInfo = channelSelectionStruct.FlagChInfo;

% % assignin('base','ChSelectionH',handles.figure1);
% Temp = evalin('base','who');
% 
% FlagSelectedCh=0;
% FlagChInfo=0;
% for i=1:length(Temp)
%     if strcmp(Temp{i},'SelectedCh')
%         FlagSelectedCh=1;
%     end
%     if strcmp(Temp{i},'ChInfo')
%         handles.ChInfo=evalin('base','ChInfo');
%         FlagChInfo=1;
%     end
% end

% Define console output
handles.output = channelSelectionStruct;

% Define save feature flag
handles.SAVE_CHANGES = 0;



if handles.FlagSelectedCh && handles.FlagChInfo
    UpdateList(hObject, handles);
    Enable_Disable_Add_Remove(hObject, eventdata, handles)
end

% Set Name
set(handles.figure1, 'Name', 'Channel Selection');


% Update handles structure
guidata(hObject, handles);

set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes ChSelection wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ChSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% Get default command line output from handles structure

varargout{1}=handles.channelSelectionStructOut;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add if there is an entry to add
available_channels_string = get(handles.MainList1,'String');
if length(available_channels_string) > 0
    
    % Get Selected Channle ID
    % SelectedCh=evalin('base','SelectedCh');
    SelectedCh = handles.SelectedCh;
    Flag = 0;
    
    if get(handles.PopMenuChType,'value')==1
        % Reference Mode        
        Temp=[1:length(handles.ChInfo.nr)];
        Temp(SelectedCh((SelectedCh(:,2)==0),1))=[];
        
        
        if ~isempty(Temp)
            SelectedCh=[SelectedCh;[Temp(get(handles.MainList1,'Value')) 0]];
            Flag = 1;
        end
        
    else
        % Differential Mode
        DiffCh1 =get(handles.MainList1,'value');
        Temp=[1:length(handles.ChInfo.nr)];
        Temp([SelectedCh(SelectedCh(:,1)==DiffCh1 & SelectedCh(:,2)~=0 ,2);DiffCh1])=[];
        
        TempCh = [get(handles.MainList1,'Value') Temp(get(handles.MainList2,'Value'))];
        
        if handles.ChInfo.nr(TempCh(1))==handles.ChInfo.nr(TempCh(2))
            SelectedCh=[SelectedCh;TempCh];
            Flag = 1;
        else
%             warndlg('It is not possible to add these channels');
            warndlg('These are not compatible bipolar channels');
        end
        
    end
    
    if Flag
        
        % FilterPara = evalin('base','FilterPara');
        FilterPara = handles.FilterPara;
        
        i = length(FilterPara)+1;
        
        FilterPara{i}.A=1;
        FilterPara{i}.B=1;
        FilterPara{i}.HighValue=1;
        FilterPara{i}.LowValue=1;
        FilterPara{i}.NotchValue=1;
        FilterPara{i}.ScalingFactor=1;
        FilterPara{i}.Color='k';
        
        % Save changes to GUI handle
        % assignin('base','FilterPara',FilterPara)
        % assignin('base','SelectedCh',SelectedCh)
        handles.FilterPara = FilterPara;
        handles.SelectedCh = SelectedCh;
        
        guidata(hObject, handles);
    end
    
    handles = UpdateList(hObject, handles);   
    Enable_Disable_Add_Remove(hObject, eventdata, handles)
end

%-------------------------------------------------------------- Update List
function handles = UpdateList(hObject,handles)

% SelectedCh=evalin('base','SelectedCh');
SelectedCh = handles.SelectedCh;

if get(handles.SelectedList,'value')>size(SelectedCh,1)
    set(handles.SelectedList,'value',size(SelectedCh,1));
end

SelectedChMap = [];
% mainCh = handles.ChInfo.Labels(SelectedCh(i,1), :);
for i=1:size(SelectedCh,1)
    if SelectedCh(i,2)==0
        SelectedChMap{i,1} = handles.ChInfo.Labels(SelectedCh(i,1),:);
    else
        SelectedChMap{i,1} = [handles.ChInfo.Labels(SelectedCh(i,1),:) '-' handles.ChInfo.Labels(SelectedCh(i,2),:)];
    end
    SelectedChMap{i,1}((SelectedChMap{i,1}==' '))=[];
end
set(handles.SelectedList,'String',SelectedChMap);

if get(handles.MainList1,'value')==0
    set(handles.MainList1,'value',1);
end

if get(handles.MainList2,'value')==0
    set(handles.MainList2,'value',1);
end

if get(handles.SelectedList,'value')==0
    set(handles.SelectedList,'value',1);
end

if get(handles.PopMenuChType,'value')==1
    % ref mode
    Temp=[1:size(handles.ChInfo.nr,1)];
    Temp(SelectedCh((SelectedCh(:,2)==0),1))=[];

    if get(handles.MainList1,'value')>length(Temp)
        set(handles.MainList1,'value',length(Temp));
    end

    set(handles.MainList1,'String',handles.ChInfo.Labels(Temp,:));

else
    % diff mode
    
    set(handles.MainList1,'String',handles.ChInfo.Labels);
    
    DiffCh1 =get(handles.MainList1,'value');
    
    Temp=[1:length(handles.ChInfo.nr)];
    Temp([SelectedCh(SelectedCh(:,1)==DiffCh1 & SelectedCh(:,2)~=0 ,2);DiffCh1])=[];

    if get(handles.MainList2,'value')>length(Temp)
        set(handles.MainList2,'value',length(Temp));
    end
    
    set(handles.MainList2,'String',handles.ChInfo.Labels(Temp,:));
end


% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% SelectedCh=evalin('base','SelectedCh');
% FilterPara=evalin('base','FilterPara');

SelectedCh = handles.SelectedCh;
FilterPara = handles.FilterPara;


Sel = get(handles.SelectedList,'value');

if ~isempty(SelectedCh)
    SelectedCh(Sel,:)=[];
    Index  = [1:length(FilterPara)];
    Index(Sel)=[];
    Temp = [];
    Counter = 0;
    for i=Index
        Counter = Counter + 1;
        Temp{Counter} = FilterPara{i};
    end
    
    % Update filter paramters
    FilterPara = Temp;
end
%assignin('base','SelectedCh',SelectedCh);
%assignin('base','FilterPara',Temp);
handles.SelectedCh = SelectedCh;
handles.FilterPara = FilterPara;


handles.SelectedCh = SelectedCh;
% handles.Temp = Temp;

% Update handles structure
guidata(hObject, handles);

UpdateList(hObject, handles);
Enable_Disable_Add_Remove(hObject, eventdata, handles)


% --- Executes on selection change in PopMenuChType.
function PopMenuChType_Callback(hObject, eventdata, handles)
% hObject    handle to PopMenuChType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PopMenuChType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopMenuChType


if get(hObject,'value')==1
    set(handles.MainList2,'Visible','off');
else
    set(handles.MainList2,'Visible','on');
end
    
UpdateList(hObject, handles);


% --- Executes on selection change in MainList1.
function MainList1_Callback(hObject, eventdata, handles)
% hObject    handle to MainList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MainList1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MainList1

UpdateList(hObject, handles);


% --- Executes on button press in ButtonLoad.
function ButtonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,FilePath] = uigetfile('.mat');

if ischar(FileName) == 1
    load([FilePath FileName]);
    
    % Save loaded structures
    handles.masterSelectionStruct = masterSelectionStruct;
    handles.channelSelectionStructIn = channelSelectionStructIn;
    handles.channelSelectionStruct = channelSelectionStruct;
    
    % Update operational variables
    handles.ChSelectionH = channelSelectionStruct.ChSelectionH;
    handles.ChSelectionH = handles.figure1;

    %%%%%%%%%%% Process selected channel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Algorithm:
    % 1. Get SelectedCh structure in montage 
    % 2. Translate SelectedCh:
    %      - For each index in SelectedCh
    %          * find out the label name in channelSelectionStruct.ChInfo
    %          * find this label's corresponding index in current 
    %            viewing EDF file
    %          * replace the index with the new index(translated)
    %          * if cannot find a label match, drop the row 
    % 3. Example:
    % >>> SelectedCh:       >>> SelectedChTranslatedFinal
    %      6     0      |             6     0
    %      7     0      |             7     0
    %      5     0      |             5     0
    %      8     0      |             8     0
    %      3     0      |               .
    %      4     0      |               .
    %     13     0      |               .
    %      9     0      |   
    %     10     0      |
    %      1     0      |   
    %     14     0      |
    %      2     0      |
    %     11     0      |             15   0
    %     12     0      |             12   0
    % Label name on left side channel 11 corresponding to current viewing
    % EDF signal label 15 for instance
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [rows, cols] = size(channelSelectionStruct.SelectedCh);
    SelectedChTranslated = zeros(rows, cols);
    for row = 1:rows
        for col = 1:cols
            if channelSelectionStruct.SelectedCh(row,col) ~= 0
                % find the label
                % fprintf('selected number: %d ', channelSelectionStruct.SelectedCh(row,col));
                montageLabel = channelSelectionStruct.ChInfo.Labels(channelSelectionStruct.SelectedCh(row,col),:);
                % fprintf('montage label: %s\n', montageLabel);            
                % compare the label to the EDF label and record index
                for j=1:size(handles.ChInfo.Labels, 1)
                    if strcmp(handles.ChInfo.Labels(j,:), montageLabel)
                        % fprintf('find match %s at index: %d\n', handles.ChInfo.Labels(j,:), j);
                        SelectedChTranslated(row, col) = j;
                    end
                end
            end
        end
    end
    % remove rows that start with index 0: cannot find corresponding label
    % in EDF
    SelectedChTranslatedFinal = [];
    j = 1;
    for i=1:rows % loop through row
        if SelectedChTranslated(i, 1) ~= 0
            SelectedChTranslatedFinal(j,:) = SelectedChTranslated(i,:);
            j = j + 1;
        end
    end
    handles.SelectedCh = SelectedChTranslatedFinal;
    %%%%%%%%%%% Process selected channel end %%%%%%%%%%%%%%%%%%

    handles.FilterPara = channelSelectionStruct.FilterPara; 
    handles.FlagSelectedCh = channelSelectionStruct.FlagSelectedCh;
    handles.FlagChInfo = channelSelectionStruct.FlagChInfo;    
    
    % Update handle change
    guidata(hObject, handles);
    
    % Process update
    UpdateList(hObject, handles); 
end

% --- Executes on button press in ButtonSave.
function ButtonSave_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get channel selection struct
masterSelectionStruct = handles.masterSelectionStruct;
channelSelectionStructIn = handles.channelSelectionStructIn;
channelSelectionStruct = handles.channelSelectionStruct;
channelSelectionStructOut = handles.channelSelectionStructOut;

% Update channel selection structure
channelSelectionStruct.SelectedCh = handles.SelectedCh;

% These two struct are not needed for applying montage
channelSelectionStruct.ChInfo = handles.ChInfo;
channelSelectionStruct.FilterPara = handles.FilterPara;

channelSelectionStruct.FlagSelectedCh = handles.FlagSelectedCh;
channelSelectionStruct.FlagChInfo = handles.FlagChInfo;


% get user defined file
[FileName,FilePath,FilterIndex] = uiputfile('*.mat');

% If file is selected save variables
if FilterIndex
    save([FilePath FileName],'channelSelectionStruct',...
        'channelSelectionStructIn', 'masterSelectionStruct');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Update handles
guidata(hObject, handles);

uiresume(hObject);

% --- Executes on button press in OkApply.
function OkApply_Callback(hObject, eventdata, handles)
% hObject    handle to OkApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set save changes flag
channelSelectionStruct.ChSelectionH = handles.ChSelectionH;
channelSelectionStruct.ChSelectionH = handles.figure1;
channelSelectionStruct.SelectedCh = handles.SelectedCh;
channelSelectionStruct.ChInfo = handles.ChInfo;
channelSelectionStruct.FilterPara = handles.FilterPara;

channelSelectionStruct.FlagSelectedCh = handles.FlagSelectedCh;
channelSelectionStruct.FlagChInfo = handles.FlagChInfo;

% Replace and save output structure
handles.channelSelectionStructOut = channelSelectionStruct;
guidata(hObject, handles);


% --- Executes on selection change in MainList2.
function MainList2_Callback(hObject, eventdata, handles)
% hObject    handle to MainList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MainList2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MainList2


% --- Executes during object creation, after setting all properties.
function MainList2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Enable_Disable_Add_Remove(hObject, eventdata, handles)
% hObject    handle to MainList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Disable ADD button, if no entries
available_channels_string = get(handles.MainList1,'String');
if length(available_channels_string) == 0
    set(handles.Add,'Enable','off');
else
    set(handles.Add,'Enable','on');
end

% Disable Remove button, if no entries
available_channels_string = get(handles.SelectedList,'String');
if length(available_channels_string) == 0
    set(handles.Remove,'Enable','off');
else
    set(handles.Remove,'Enable','on');
end



% --- Executes on button press in pbClose.
function pbClose_Callback(hObject, eventdata, handles)
% hObject    handle to pbClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)
