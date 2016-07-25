%=====================================================================
% File: HandleGenTest.m
% Original code written by Adithya V. Murthy, IVU Lab (http://ivulab.asu.edu)
% Last Revised: November 2010 by Adithya V. Murthy
%=====================================================================
% Copyright Notice:
%
% Copyright (c) 2009-2010 Arizona Board of Regents.
% All Rights Reserved.
%
% Contact: Lina Karam (karam@asu.edu) and Adithya V. Murthy (adithya.murthy@asu.edu)
%
% Image, Video, and Usabilty (IVU) Lab, ivulab.asu.edu
% Arizona State University
%
% This copyright statement may not be removed from this file or from
% modifications to this file.
% This copyright notice must also be included in any file or product
% that is derived from this source file.
%
% Redistribution and use of this code in source and binary forms,
% with or without modification, are permitted provided that the
% following conditions are met:
%
% - Redistribution's of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
%
% - Redistribution's in binary form must reproduce the above copyright 
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% - The Image, Video, and Usability Laboratory (IVU Lab,
% http://ivulab.asu.edu) is acknowledged in any publication that
% reports research results using this code, copies of this code, or
% modifications of this code.
%
%The code and our papers are to be cited in the bibliography as:
%
%A. V. Murthy and L. J. Karam, "IVQUEST- Image and Video QUality Evaluation SofTware",
%http://ivulab.asu.edu/Quality/IVQUEST
%
%A. V. Murthy and L. J. Karam, "MATLAB Based Framework For Image and Video Quality Evaluation,"
%International Workshop on Quality of Multimedia Experience (QoMEX), pages 242-247, June 2010. 
%
%A. V. Murthy, "MATLAB Based Framework For Image and Video Quality Evaluation," Master's thesis, Arizona State University, May 2010
%
% DISCLAIMER:
%
% This software is provided by the copyright holders and contributors
% "as is" and any express or implied warranties, including, but not
% limited to, the implied warranties of merchantability and fitness for 
% a particular purpose are disclaimed. In no event shall the Arizona
% Board of Regents, Arizona State University, IVU Lab members, or
% contributors be liable for any direct, indirect, incidental, special,
% exemplary, or consequential damages (including, but not limited to,
% procurement of substitute goods or services; loss of use, data, or
% profits; or business interruption) however caused and on any theory
% of liability, whether in contract, strict liability, or tort
% (including negligence or otherwise) arising in any way out of the use
% of this software, even if advised of the possibility of such damage.
%
%=====================================================================


function HandleGenTest(handles)
%Function that is called when the "Start" button is clicked and the 
%Generate Test Media tab is active. 

%Check if logging is to be performed

if(-1~=handles.FilePointers.LogFile)
    LogFn=@PerformLogging;
else
    LogFn=@NoLogging;
end

if(0~=handles.ToolOptions.DisplayRefImage)
    RefImgFn=@DisplayImg;
else
    RefImgFn=@NoDisp;
end

if(0~=handles.ToolOptions.DisplayGenImage)
    GenImgFn=@DisplayImg;
else
    GenImgFn=@NoDisp;
end

DisplayGenImgHandle=0;

%Validating selections
LogFn(handles.FilePointers.LogFile,'\nValidating UI selections for the Generate test Tab...');

if((~isfield(handles.TestGenData.SelectedDistortions,'name'))|| (isempty(handles.TestGenData.SelectedDistortions.name)))
    LogFn(handles.FilePointers.LogFile,'\nNo distortions selected.');
    error('No distortions selected');
end

if((~isfield(handles.TestGenData,'TestFiles'))|| (isempty(handles.TestGenData.TestFiles)))
  LogFn(handles.FilePointers.LogFile,'\nNo Test files found.');
  error('No Test files found');
end
if((0==handles.ToolOptions.AutoFilename)&&(isempty(handles.ToolOptions.GenFilenameSuffix)))
    LogFn(handles.FilePointers.LogFile,'\nNo filename suffix specified.');
    error('No filename suffix specified.');
end

if(~isempty(handles.ToolOptions.GenFilenameSuffix))
    UserSuffix=handles.ToolOptions.GenFilenameSuffix;
else
    UserSuffix=[];
end

NumOfTestFiles=numel(handles.TestGenData.TestFiles);

msg=[];

LoggingParam.LogFn=LogFn;
LoggingParam.LogFile=handles.FilePointers.LogFile;

for i=1:NumOfTestFiles

    msg=['\nProcessing file ' num2str(i)];
    LogFn(handles.FilePointers.LogFile,msg);

    [DistortedFrame,OutputFileName]=GenerateDistortionsInImage(handles.TestGenData,LoggingParam,i,RefImgFn,UserSuffix);

    DisplayGenImgHandle=GenImgFn(DisplayGenImgHandle,OutputFileName,DistortedFrame);

    OutputFileName=fullfile(char(handles.TestGenData.GenPath),OutputFileName);
    LogFn(handles.FilePointers.LogFile,'\nWriting generated test file...');

    if(1==strcmp('I',handles.MediaType))
        OutputFileName=[OutputFileName '.bmp'];
        imwrite(DistortedFrame,OutputFileName,'bmp');
    else
        msgbox('Not Currently supported');
    end

end %for i=1:NumOfTestFiles