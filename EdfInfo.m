function handles=EdfInfo(FileName)

fid = fopen (FileName);

handles.FileInfo.Version = char(fread(fid,[1 8],'uint8'));

handles.FileInfo.LocalPatientID = char(fread(fid,[1 80],'uint8'));

handles.FileInfo.LocalRecordID = char(fread(fid,[1 80],'uint8'));

handles.FileInfo.StartDate = char(fread(fid,[1 8],'uint8'));

handles.FileInfo.StartTime = char(fread(fid,[1 8],'uint8'));

handles.FileInfo.HeaderNumBytes = str2num(char(fread(fid,[1 8],'uint8')));

handles.FileInfo.Reserved = char(fread(fid,[1 44],'uint8'));

handles.FileInfo.NumberDataRecord = str2num(char(fread(fid,[1 8],'uint8')));

handles.FileInfo.DataRecordDuration = str2num(char(fread(fid,[1 8],'uint8')));

handles.FileInfo.SignalNumbers = str2num(char(fread(fid,[1 4],'uint8')));

ns = handles.FileInfo.SignalNumbers;

handles.ChInfo.Labels = char(fread(fid,[16 ns],'uint8')');

handles.ChInfo.TransType = char(fread(fid,[80 ns],'uint8')');

handles.ChInfo.PhyDim = char(fread(fid,[8 ns],'uint8')');

handles.ChInfo.PhyMin = str2num(char(fread(fid,[8 ns],'uint8')'));

handles.ChInfo.PhyMax = str2num(char(fread(fid,[8 ns],'uint8')'));

handles.ChInfo.DiMin = str2num(char(fread(fid,[8 ns],'uint8')'));

handles.ChInfo.DiMax = str2num(char(fread(fid,[8 ns],'uint8')'));

handles.ChInfo.PreFiltering = char(fread(fid,[80 ns],'uint8')');

handles.ChInfo.nr = str2num(char(fread(fid,[8 ns],'uint8')'));

handles.ChInfo.Reserved = char(fread(fid,[32 ns],'uint8')');

fclose(fid);