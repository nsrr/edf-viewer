classdef loadCompumedicsAnnotationsClass
    %loadComumedicsAnnotations Loads compumedics annotations
    %   Class form is adapted from the PhysioMiMi code and updated to
    %   provide additional functionality.
    %
    % Function Prototypes:
    %
    %   obj = loadComumedicsAnnotations (fn)
    %
    % Public Properties
    %
    %      subjectId: Used to label plots
    %    figPosition: Move to generated figure position, if set
    %       scoreKey: Key for translating output numeric code to stage IDs 
    %
    % Dependent Properties
    %
    %      uniqueStageText: Unique stage
    %     numericHypnogram: Numeric hypnogram [1:num epochs]'
    %   characterHypnogram: Character hypnogram [1:num epochs]'
    %         normalizeHyp: hypnogram [t(0 100) stage]
    %           numHypDist:  Distributed numeric hypnogram [t(0-100) stage]
    %           xmlEntries: XMl entry types
    %          ScoredEvent: Scored event structure
    %            EventList: List of events
    %           EventTypes: Unique event entry types
    %           EventStart: Event start list
    %          SleepStages: List of sleep stages
    %          EpochLength: Epoch length 
    %         
    % Public Methods
    %    obj = plotHypnogram
    %    obj = plotHypnogramWithDist
    %   
    % Version: 0.1.04
    %
    % ---------------------------------------------
    % Dennis A. Dean, II, Ph.D
    %
    % Program for Sleep and Cardiovascular Medicine
    % Brigam and Women's Hospital
    % Harvard Medical School
    % 221 Longwood Ave
    % Boston, MA  02149
    %
    % File created: November 14, 2013
    % Last updated: May 5, 2014 
    %    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This file is part of the EDFViewer, Physio-MIMI Application tools
    %
    % EDFViewer is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or
    % (at your option) any later version.
    %
    % EDFViewer is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
    %
    % Copyright 2010, Case Western Reserve University
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright � [2013] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
    % WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
    % AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
    % PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
    % BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
    % INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
    % FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
    % AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
    % RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
    %
    
    %---------------------------------------------------- Public Properties
    properties (Access = public)
        % Input
        fn = '';
        
        % Optional Parameters
        subjectId = '';
        figPosition = [];
       
        % Translation Key
        scoreKey = { ...
            { 'Awake' ,      0,  'W'}; ...
            { '1' ,          1,  '1'}; ...
            { '2' ,          2,  '2'}; ...
            { '3' ,          3,  '3'}; ...
            { '4' ,          4,  '4'}; ...
            { 'REM' ,        5,  'R'}; ...
        };
        
       % Output
       figId = [];            
    end
     %------------------------------------------------ Dependent Properties
    properties (Dependent = true)        
        % Hypnogram Variables
        uniqueStageText                   % Unique stage
        numericHypnogram                  % Numeric hypnogram [1:num epochs]'
        characterHypnogram                % Character hypnogram [1:num epochs]'
        normalizeHyp                      % hypnogram [t(0 100) stage]
        numHypDist                        % Distributed numeric hypnogram 
                                          % [t(0-100) stage]
        % PhysioMiMi Terms
        xmlEntries                        % XMl entry types
        ScoredEvent                       % Scored event structure
        EventList                         % List of events
        EventTypes                        % Unique event entry types
        EventStart                        % Event start list
        SleepStages
        EpochLength                                      
    end
    %------------------------------------------------- Protected Properties
    properties (Access = protected)  
        % Lights off/on text
        lightsOffText = 'Lights Off';
        lightsOnText = 'Lights On';
        
        % Hypnogram Variables
        BAD_VALUE = 255;
   
        % Hypnogram Variables
        uniqueStageTextP              % Unique stage
        numericHypnogramP             % Numeric hypnogram [1:num epochs]'
        characterHypnogramP           % Character hypnogram [1:num epochs]'
        normalizeHypP                 % hypnogram [t(0 100) stage]
        numHypDistP                   % Distributed numeric hypnogram 
                                      % [t(0-100) stage]
                                          
        % PhysioMiMi Terms
        xmlEntriesP                   % XML Doc Entries
        ScoredEventP                  % Scored event data structure
        EventListP                    % List of events
        EventTypesP                   % Unique event entry types
        EventStartP                   % Event start list
        SleepStagesP                  % Sleep Stages
        EpochLengthP                  % Epoch Length  
    end
    %------------------------------------------------------- Public Methods
    methods
        %------------------------------------------------------ Constructor
        function obj = loadCompumedicsAnnotationsClass(varargin)
             if nargin == 1
                obj.fn = varargin{1};
            else
                fprintf('obj = loadComumedicsAnnotations (filename)') % (fn) to (filename)
            end           
        end
        %---------------------------------------------------- loadXmlStruct
        function obj = loadXmlStruct(obj)
            % Load Grass file
            fn = obj.fn;
            fid = fopen(fn);           
            
            % Process if file is open
            if fid > 0
                fileTxt = fread(fid)';
                fclose(fid);
            else
                msg = sprintf('Could not open %s', fn);
                error(msg);
            end 
             
            % Load file into a JAVA object
            try
                xmldoc = xmlread(fn);
            catch
                error('Failed to read XML file %s.',fn);
            end
            
            % Overview
            xmlVersion = xmldoc.getXmlVersion;
            xmlEncoding = xmldoc.getXmlEncoding;
            rootNode = xmldoc.getFirstChild;
            rootNodeTag = rootNode.getTagName;

            % Traverse 
            children = {};
            childrenStr = {};
            currentNode = rootNode.getFirstChild;
            currentNodeStr = char(getTagName(currentNode));
            lastNodeStr = char(getTagName(rootNode.getLastChild));
            while strcmp(currentNodeStr, lastNodeStr) ~= 1
                % Save Node
                children{end+1} = currentNode;
                childrenStr{end+1} = currentNodeStr;
                  
                % Get Child Elements     
                
                
                % Get Next Child
                currentNode = getNextSibling(currentNode);
                currentNodeStr = char(getTagName(currentNode));  
            end
            obj.xmlEntriesP = childrenStr;     
               
            xmlStruct.xmlVersion = xmlVersion;
            xmlStruct.xmlEncoding = xmlEncoding;
            xmlStruct.rootNodeTag = rootNodeTag;
            xmlStruct.currentNodeStr = currentNodeStr;            
            
            % Parse nodes
            [ScoredEvent, SleepStages, EpochLength] = parseNodes(xmldoc);
            
            % Pass key varaibles to obj
            obj.ScoredEventP = ScoredEvent;
            obj.SleepStagesP = SleepStages';
            obj.EpochLengthP  = EpochLength;
            
            % Create variables used in Grass Loader
            obj.characterHypnogramP = lookup(SleepStages, obj.scoreKey);
            obj.uniqueStageTextP = unique(obj.characterHypnogramP); 
        
            %--------------------------------------------------------------
            function [ScoredEvent, SleepStages, EpochLength] = parseNodes(xmldoc)
                % Function parses each XML node

                % Stage transformation flag
                TRANSFORM_STAGES = 0;
                
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

                % Sleep Stages
                if TRANSFORM_STAGES == 1
                    SleepStages = -SleepStages+5;
                end

            end  % End Embedded Function     
            %-------------------------------------------- Embedded Function
            function n = lookup(interptDistVal, table)
                lookUpF = cellfun(@(x)x{2},table);
                returnF = cellfun(@(x)x{3},table);
                vLookUpF = @(x)returnF(find(lookUpF==x));
                n = arrayfun(vLookUpF, interptDistVal)';
            end
        end
        %--------------------------------------------------------- loadFile
        function obj = loadFile(obj)
            % Load Grass file
            fn = obj.fn;
            fid = fopen(fn);           
            
            % Process if file is open
            if fid > 0
                fileTxt = fread(fid)';
            else
                msg = sprintf('Could not open %s', fn);
                error(msg);
            end
            
             
            % Pass loaded information to object
            try
                xdoc = xmlread(fn);
            catch
                error('Failed to read XML file %s.',xmlfile);
            end
            [ScoredEvent, SleepStages, EpochLength] = parseNodes(xdoc);
            
            % Get event information
            eventListF = @(x)ScoredEvent(x).EventConcept;
            EventListP = arrayfun(eventListF,[1:length(ScoredEvent)],...
                  'UniformOutput', 0)';
            EventTypesP = unique(EventListP);
            eventStartF = @(x)ScoredEvent(x).Start;
            EventStartP = arrayfun(eventStartF,[1:length(ScoredEvent)],...
                  'UniformOutput', 1)';
              
            % Pass key varaibles to obj
            obj.ScoredEventP = ScoredEvent;
            obj.SleepStagesP = SleepStages';
            obj.EpochLengthP  = EpochLength;
            
            % Pass detail information to obj
            obj.EventListP = EventListP;
            obj.EventTypesP = EventTypesP;
            obj.EventStartP = EventStartP;
            
            % Create variables used in Grass Loader
            obj.characterHypnogramP = lookup(SleepStages, obj.scoreKey);
            obj.uniqueStageTextP = unique(obj.characterHypnogramP); 
       
                        
            % Close file
            fid = fclose(fid);   
        
            %--------------------------------------------------------------
            function [ScoredEvent, SleepStages, EpochLength] = parseNodes(xmldoc)
                % Function parses each XML node


                % Stage transformation flag
                TRANSFORM_STAGES = 0;

                
                % Overview
                xmlVersion = xmldoc.getXmlVersion;
                xmlEncoding = xmldoc.getXmlEncoding;
                rootNode = xmldoc.getFirstChild;
                rootNodeTag = rootNode.getTagName;
                
                children = {};
                childrenStr = {};
                currentNode = rootNode.getFirstChild;
                currentNodeStr = char(getTagName(currentNode));
                lastNodeStr = char(getTagName(rootNode.getLastChild));
                while strcmp(currentNodeStr, lastNodeStr) ~=1
                    children{end+1} = currentNode;
                    childrenStr{end+1} = currentNodeStr;
                    currentNode = getNextSibling(currentNode);
                    currentNodeStr = char(getTagName(currentNode));
                end
                childrenStr;             
                
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

                % Sleep Stages
                if TRANSFORM_STAGES == 1
                    SleepStages = -SleepStages+5;
                end

            end  % End Embedded Function     
            %-------------------------------------------- Embedded Function
            function n = lookup(interptDistVal, table)
                lookUpF = cellfun(@(x)x{2},table);
                returnF = cellfun(@(x)x{3},table);
                vLookUpF = @(x)returnF(find(lookUpF==x));
                n = arrayfun(vLookUpF, interptDistVal)';
            end
        end
        %---------------------------------------------------- plotHypnogram
        function obj = plotHypnogram(obj, varargin)
            % Plot control
            LineWidth = 2;
            FontWeight = 'Bold';
            FontSize = 14;
            
            if nargin == 2
                figPosition = varargin{1};
            end
            
            % Get plotting information
            scoreKey = obj.scoreKey;
            numericHypnogram = obj.numericHypnogram;
            t = [0:1:length(numericHypnogram)-1]*obj.EpochLength/60/60;
                        
            % Create figure
            fid = figure('InvertHardcopy','off','Color',[1 1 1]);
            plot(t, numericHypnogram, 'LineWidth', LineWidth)
            if nargin >=2
                set(fid,'Position',figPosition);
            end

            % Change axis
            v = axis();
            v(1:2) = [0 t(end)];
            v(3:4) = [-2.5 5.5];
            axis(v)
            
            % Annotations
            titleStr = 'Hypnogram';
            if ~isempty(obj.subjectId)
                titleStr = obj.subjectId;
            end
            title(titleStr,'FontWeight',FontWeight,'FontSize',FontSize)
            xlabel('Time (hr)','FontWeight',FontWeight,'FontSize',FontSize);
            ylabel('Stage','FontWeight',FontWeight,'FontSize',FontSize);
            
            % Set x axis
            box(gca,'on');
            hold(gca,'all');            
            set(gca, 'LineWidth', LineWidth);
            set(gca, 'FontWeight', FontWeight);
            set(gca, 'FontSize', FontSize);
            set(gca, 'YTick', [-2:1:5]);
            set(gca, 'YTickLabel', ...
                {'U', 'M', 'W', '1', '2', '3', '4', 'R'});
            
%             % plot lights on information
%             lightsOffHr = obj.lightsOffEpoch*obj.headerP.duration/60/60;
%             lightsOnHr = obj.lightsOnEpoch*obj.headerP.duration/60/60;
%             if ~isempty (lightsOffHr)
%                 line([lightsOffHr lightsOffHr], v(3:4),'color','magenta',...
%                     'LineWidth', LineWidth, 'LineStyle', '--')
%             end
%             if ~isempty (lightsOnHr)
%                 line([lightsOnHr lightsOnHr], v(3:4),'color','magenta',...
%                     'LineWidth', LineWidth, 'LineStyle', '--')
%             end            
            
            % Reploting
            plot(t, numericHypnogram, 'LineWidth', LineWidth, ...
                'color', 'blue');
                        
            if ~isempty(obj.figPosition)
                set(fid, 'Position', obj.figPosition);
            end
            
            % Save figure id            
            obj.figId = [obj.figId;fid];
        end
        %-------------------------------------------- plotHypnogramWithDist
        function obj = plotHypnogramWithDist(obj, varargin)
            % Plot Hypnogram with stage distribution 
   
            % Plot control
            LineWidth = 2;
            FontWeight = 'Bold';
            FontSize = 20;
            
            if nargin == 2
                figPosition = varargin{1};
            end

            % Get plotting information
            scoreKey = obj.scoreKey;
            numericHypnogram = obj.numericHypnogram;
            t = [0:1:length(numericHypnogram)-1]*obj.EpochLength/60/60;
            
            %---------------------------------------------------- Hypnogram
            
            % Create figure
            fid = figure('InvertHardcopy','off','Color',[1 1 1]);
            subplot(2,1,1)
            plot(t, numericHypnogram, 'LineWidth', LineWidth)
            hold on
            if nargin >=2
                set(fid,'Position',figPosition);
            end
            % Change axis
            v = axis();
            v(1:2) = [0 t(end)];
            v(3:4) = [-2.5 5.5];
            axis(v)
            
            % Annotations
            titleStr = 'Hypnogram';
            if ~isempty(obj.subjectId)
                titleStr = obj.subjectId;
            end
            title(titleStr,'FontWeight',FontWeight,'FontSize',FontSize+5)
            xlabel('Time (hr)','FontWeight',FontWeight,'FontSize',FontSize);
            ylabel('Stage','FontWeight',FontWeight,'FontSize',FontSize);
            
            % Set x axis
            box(gca,'on');
            hold(gca,'all');            
            set(gca, 'LineWidth', LineWidth);
            set(gca, 'FontWeight', FontWeight);
            set(gca, 'FontSize', FontSize);
            set(gca, 'YTick', [-2:1:5]);
            set(gca, 'YTickLabel', ...
                {'U', 'M', 'W', '1', '2', '3', '4', 'R'});
            
%             % plot lights on information
%             lightsOffHr = obj.lightsOffEpoch*obj.headerP.duration/60/60;
%             lightsOnHr = obj.lightsOnEpoch*obj.headerP.duration/60/60;
%             if ~isempty (lightsOffHr)
%                 line([lightsOffHr lightsOffHr], v(3:4),'color','magenta',...
%                     'LineWidth', LineWidth, 'LineStyle', '--')
%             end
%             if ~isempty (lightsOnHr)
%                 line([lightsOnHr lightsOnHr], v(3:4),'color','magenta',...
%                     'LineWidth', LineWidth, 'LineStyle', '--')
%             end            
            
            % Reploting
            plot(t, numericHypnogram, 'LineWidth', LineWidth, ...
                'color', 'blue');
            
            %------------------------------------------------- Distribution
            subplot(2,1,2)
            
            % Clip to scheduled sleep
%             lightsOffEpoch = obj.lightsOffEpoch;
%             lightsOnEpoch = obj.lightsOnEpoch;
%             numericHypnogram = ...
%                 numericHypnogram(lightsOffEpoch:lightsOnEpoch);
            t = 100*[1:1:length(numericHypnogram)]/length(numericHypnogram);
            
            % Create figure
            plot(t, sort(numericHypnogram), 'LineWidth', LineWidth)

            % Change axis
            v = axis();
            v(1:2) = [0 100];
            v(3:4) = [-2.5 5.5];
            axis(v)
            
            % Annotations
            titleStr = 'Stage Distribution';
            if ~isempty(obj.subjectId)
                titleStr = obj.subjectId;
            end
            % title(titleStr,'FontWeight',FontWeight,'FontSize',FontSize)
            xlabel('Scheduled Sleep (%)','FontWeight', ...
                FontWeight,'FontSize',FontSize);
            ylabel('Stage','FontWeight',FontWeight,'FontSize',FontSize);
            
            % Set x axis
            box(gca,'on');
            hold(gca,'all');            
            set(gca, 'LineWidth', LineWidth);
            set(gca, 'FontWeight', FontWeight);
            set(gca, 'FontSize', FontSize);
            set(gca, 'YTick', [-2:1:5]);
            set(gca, 'YTickLabel', ...
                {'U', 'M', 'W', '1', '2', '3', '4', 'R'});
            
            if ~isempty(obj.figPosition)
                set(fid, 'Position', obj.figPosition);
            end
                        
            % Save figure id            
            obj.figId = [obj.figId;fid];
        end
    end
    %---------------------------------------------------- Private functions
    methods (Access=protected) 
    end
    %------------------------------------------------- Dependent Properties
    methods 
        %------------------------------------------ GrassLoadClassVaraibles
        %-------------------------------------------------- uniqueStageText
        function value = get.uniqueStageText(obj)
            value = obj.uniqueStageTextP;
        end
        %------------------------------------------------- numericHypnogram
        function value = get.numericHypnogram(obj)
            value = obj.SleepStagesP;
        end
        %---------------------------------------------- characterHypnogramP
        function value = get.characterHypnogram(obj)
            value = obj.characterHypnogramP;
        end
        %---------------------------------------------------- normalizeHypP
        function value = get.normalizeHyp(obj)
            value = {};
            if ~isempty(obj.SleepStages)            
                % Clip to scheduled sleep
                numericHypnogram = obj.numericHypnogram;

%                 numericHypnogram = ...
%                     (numericHypnogram(lightsOffEpoch:lightsOnEpoch));
                t = 100*[1:1:length(numericHypnogram)]/...
                    length(numericHypnogram);
                value = [t',  numericHypnogram];
                value = [[0.0  numericHypnogram(1)] ; value];
            end
        end        
        %------------------------------------------------------ numHypDistP
        function value = get.numHypDist(obj)
            value = {};
            if ~isempty(obj.SleepStages)            
                % Clip to scheduled sleep
%                 lightsOffEpoch = obj.lightsOffEpoch;
%                 lightsOnEpoch = obj.lightsOnEpoch;
                numericHypnogram = obj.numericHypnogram;
                numericHypnogram = ...
                    ...%sort(numericHypnogram(lightsOffEpoch:lightsOnEpoch));
                    sort(numericHypnogram);
                t = 100*[1:1:length(numericHypnogram)]/...
                    length(numericHypnogram);
                value = [t',  numericHypnogram];
                value = [[0.0  numericHypnogram(1)] ; value];
            end
        end
        %----------------------------------------------PhysioMiMi Variables
        %------------------------------------------------------- xmlEntries
        function value = get.xmlEntries(obj)
            value = obj.xmlEntriesP;
        end
        %------------------------------------------------------ ScoredEvent
        function value = get.ScoredEvent(obj)
            value = obj.ScoredEventP;
        end
        
        %-------------------------------------------------------- EventList
        function value = get.EventList(obj)
            value = obj.EventListP;
        end
        %------------------------------------------------------- EventTypes
        function value = get.EventTypes(obj)
            value = obj.EventTypesP;
        end
        %------------------------------------------------------- EventStart
        function value = get.EventStart(obj)
            value = obj.EventStartP;
        end
        
        
        
        %------------------------------------------------------ SleepStages
        function value = get.SleepStages(obj)
            value = obj.SleepStagesP;
        end
        %------------------------------------------------------ EpochLength
        function value = get.EpochLength(obj)
            value = obj.EpochLengthP;
        end
    end
    %------------------------------------------------- Dependent Properties
    methods(Static)
        %---------------------------------------------------- GetEventTimes  
        function value = GetEventTimes(eventLabel, EventList, EventStart)
           % Return the time of the specified event
           
           % Define return value
           value = [];
           
           % Check for event typ
           eventIndex = strcmp(eventLabel, EventList);
           
           if ~isempty(eventIndex)
               value = EventStart(eventIndex);
           end 
        end
    end
end
