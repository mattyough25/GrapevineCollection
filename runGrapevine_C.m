%% Grapevine Recording Script with C Script Integration
clear
clc

global DF
sPath = cd;
%% Inistialize Boolean Variables
bRun = true;
bWrite2File = true;

%% Set File Name
sDataPath = cd;
sFile = [sprintf('GRAPEVINE_Array_Test_1_%s', datestr(now,'mm-dd-yyyy-HH-MM-SS'))];
sFilePath = [sDataPath,filesep,sFile];
sFileMat = sprintf('GRAPEVINE_Array_Test_1_%s.mat', datestr(now,'mm-dd-yyyy-HH-MM-SS'));

%% Define ip_address
ip = ['[]'];

%% Subscribe to DF Messages
% add messages
% MessageTypes =  {'SERVER_TIMESTAMP_USER'};
% % Messages to subscribe to DF
% ConnectArgs = {0, [], 'message_defs_wvu.mat'};
% mm_ip = ip;
% if strcmp(mm_ip, '[]')
%     mm_ip = [];
% end
% if exist('mm_ip','var') && ~isempty(mm_ip)
%     ConnectArgs{end+1} = ['-server_name ' mm_ip, ':7111'];
% end
% ConnectToMMM(ConnectArgs{:});
% Subscribe( MessageTypes{:});

%% Run Record Executable
record = actxserver('WScript.Shell');
record.Run('record'); %Invokes record.exe
pause(1); %Waits for the application to load.
record.AppActivate('record'); %Brings executable to focus
pause(0.1)
record.SendKeys('y');
pause(0.1)
record.SendKeys('{ENTER}');
pause(0.1)
record.SendKeys(sFilePath);
pause(0.1)
record.SendKeys('{ENTER}');
pause(0.1)
record.SendKeys('y');
pause(0.1)
record.SendKeys('{ENTER}');
pause(0.1)
record.SendKeys('q');
pause(0.1)
record.SendKeys('{ENTER}');
pause(0.1)
record.SendKeys('r');
pause(0.1)



%% Connect to Dragonfly and Get TimeServer Time
if bRun
    
%     %% read timeserver timestamp
%     % Request Time Server Time
%     nMT  = EnsureNumericMessageType('REQUEST_TIMESTAMP_USER');
%     % Get Sending Time
%     msg         = DF.MDF.REQUEST_TIMESTAMP_USER;
%     UnsafeSendMessage( nMT, msg);
    
%     for iMessage = 1:2
%         M           = ReadMessage('blocking');
%         if ~isempty(M.data)
%             record.SendKeys('{ENTER}');
%             break;
%         end
%     end
    record.SendKeys('{ENTER}'); 
    
    bWaitbar = waitbar(0, 'Grapevine EMG', 'Name', 'Collecting Data','CreateCancelBtn','delete(gcbf)');
    
    ix = 1;
    while bRun
        drawnow;
        
        %% Get Current Universal Time
        if ix == 1
            sTime = split(string(datetime('now','TimeZone','UTC','Format','HH:mm:ss.SSS')),":");
            tTime = (str2double(sTime(1))*3600) + (str2double(sTime(2))*60) + str2double(sTime(3));
	    tic
            nDataGrapevine.tTime(1) = tTime;
        else
            nDataGrapevine.tTime(ix) = nDataGrapevine.tTime(1) + toc;
        end
        ix = ix + 1;
        
        if ~ishandle(bWaitbar)
            record.SendKeys('s{ENTER}x{ENTER}');
            
            % Request Time Server Time
%             nMT  = EnsureNumericMessageType('REQUEST_TIMESTAMP_USER');
%             % Get Sending Time
%             msg         = DF.MDF.REQUEST_TIMESTAMP_USER;
%             UnsafeSendMessage( nMT, msg);
%             M           = ReadMessage('blocking');
%             nDataGrapevine.tTime(ix) = nDataGrapevine.tTime(1) + toc;
            
            disp('Stopped Recording')
            break;
        end
        
    end
end

%% Convert ns5 file and Save as Mat File
if bWrite2File && ~ishandle(bWaitbar)
    cd(sDataPath);
    
    NS5_Data = openNSx([sFile,'.ns5']);
    nDataGrapevine.arrayraw = double(NS5_Data.Data);
    s = whos('nDataGrapevine');
    
    if s.bytes < 2e9
        save(sFileMat,'nDataGrapevine');
    else
        save(sFileMat,'nDataGrapevine', '-v7.3');
    end
    
    cd(sPath);
end
