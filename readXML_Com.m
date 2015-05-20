
function [ScoredEvent, SleepStages, EpochLength] = readXML_Com(FileName)

try
    xdoc = xmlread(FileName);
catch
    error('Failed to read XML file %s.',xmlfile);
end
[ScoredEvent, SleepStages, EpochLength] = parseNodes(xdoc);



function [ScoredEvent, SleepStages, EpochLength] = parseNodes(xmldoc)

Temp = xmldoc.getElementsByTagName('EpochLength');
EpochLength = str2double(Temp.item(0).getTextContent);

events = xmldoc.getElementsByTagName('ScoredEvent');
if events.getLength>0
    ScoredEvent = [];
   for i = 0: events.getLength-1 
        ScoredEvent(i+1).EventConcept = char(events.item(i).getElementsByTagName('Name').item(0).getTextContent);
        Temp=findstr(ScoredEvent(i+1).EventConcept,'desaturation');
        if ~isempty(Temp)
            ScoredEvent(i+1).LowestSpO2        = str2num(events.item(i).getElementsByTagName('LowestSpO2').item(0).getTextContent);
            ScoredEvent(i+1).Desaturation      = str2num(events.item(i).getElementsByTagName('Desaturation').item(0).getTextContent);
        end
        ScoredEvent(i+1).Start        = str2num(events.item(i).getElementsByTagName('Start').item(0).getTextContent);
        ScoredEvent(i+1).Duration     = str2num(events.item(i).getElementsByTagName('Duration').item(0).getTextContent);
        ScoredEvent(i+1).InputCh      = char(events.item(i).getElementsByTagName('Input').item(0).getTextContent);
    end
end

Stages = xmldoc.getElementsByTagName('SleepStage');

if Stages.getLength>0
    SleepStages = [];
   for i = 0: Stages.getLength-1 
        SleepStages(i+1) = str2num(Stages.item(i).getTextContent);
    end
end

SleepStages = -SleepStages+5;

