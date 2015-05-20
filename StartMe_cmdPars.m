function StartMe_cmdPars(varargin) %varargin
%varargin: (edfName, edfPath, xmlName, xmlPath)
    
    global needOpenDialog;
    global FilePath;
    global FileName;
    global XmlFilePath;
    global XmlFileName;
    
    if isempty(varargin)
        needOpenDialog = true;
    elseif length(varargin) == 2
        needOpenDialog = false;
        FilePath = varargin{2};
        FileName = varargin{1};
    elseif length(varargin) == 4
        needOpenDialog = false;
        FilePath = varargin{2};
        FileName = varargin{1};
        XmlFilePath = varargin{4};
        XmlFileName = varargin{3};
    end
    
    EDF_View({})
end
