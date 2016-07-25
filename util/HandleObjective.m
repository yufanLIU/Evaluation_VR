%=====================================================================
% File: HandleObjective.m
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


function HandleObjective(handles)
%Function that is called when the "Start" button is clicked and the 
%Objective Metrics tab is active. 

%Check if logging is to be performed

if(-1~=handles.FilePointers.LogFile)
    HandlerParam.LogFn=@PerformLogging;
else
    HandlerParam.LogFn=@NoLogging;
end

if(1==handles.ToolOptions.ProgressUpdate)
    HandlerParam.ProgressFn=@Progress;
else
    HandlerParam.ProgressFn=@NoProgress;
end

if(0~=handles.ToolOptions.DisplayImage)
    HandlerParam.ImgFn=@DisplayImg;
else
    HandlerParam.ImgFn=@NoDisp;
end
DisplayImgHandle=0;

HandlerParam.LogFilePtr=handles.FilePointers.LogFile;

%Validating UI Selections
HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nValidating UI selections for the Objective Tab...');

if((~isfield(handles.MetricData.SelectedMetrics,'name'))|| (isempty(handles.MetricData.SelectedMetrics.name)))
    HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nNo metric selected.');
    error('No metric selected');
else
    HandlerParam.MetricsID=handles.MetricData.SelectedMetrics.identifier;
end

if((~isfield(handles.MetricData,'TestFiles'))|| (isempty(handles.MetricData.TestFiles)))
  HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nNo Test files found.');
  error('No Test files found');
else
    HandlerParam.TestFiles=handles.MetricData.TestFiles;
    HandlerParam.TestImageWidth=handles.MetricData.TestImageWidth;
    HandlerParam.TestImageHeight=handles.MetricData.TestImageHeight;
    HandlerParam.TestFormat=handles.MetricData.TestFormat;
    HandlerParam.TestFPS=handles.MetricData.TestFPS;
end



if((1==strcmp('FR',handles.MetricType))|| (1==strcmp('RR',handles.MetricType)))
    if((~isfield(handles.MetricData,'RefFiles'))|| (isempty(handles.MetricData.RefFiles)))
        HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nNo Reference files found.');
        error('No Reference files found');
    else
        if((numel(handles.MetricData.RefFiles)~=numel(handles.MetricData.TestFiles)) && (1~=numel(handles.MetricData.RefFiles)))
            HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nNumber of reference and test files do not match.');
            error('Number of reference and test files do not match.');
        else
          HandlerParam.RefFiles=handles.MetricData.RefFiles;
          HandlerParam.RefImageWidth=handles.MetricData.RefImageWidth;
          HandlerParam.RefImageHeight=handles.MetricData.RefImageHeight;
          HandlerParam.RefFormat=handles.MetricData.RefFormat;
          HandlerParam.RefFPS=handles.MetricData.RefFPS;
        end
    end
else
        HandlerParam.RefFiles=[];
        HandlerParam.RefImageWidth=[];
        HandlerParam.RefImageHeight=[];
        HandlerParam.RefFormat=[];
        HandlerParam.RefFPS=[];
end

% All OK so far. Start the processing

fname=['Handle_' handles.MediaType   handles.MetricType];

%Call relevant handler
try

    Results=feval(fname,HandlerParam);
catch RetErr
    msg=sprintf('\nErrors while Processing: %s',RetErr.message);
    HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
    error(msg);
end

%Write the output
HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nWriting objective metrics output...');

try
    WriteObjOutput(handles.MetricData.OutputFilename,handles.MetricData.SelectedMetrics,handles.MetricData.TestFiles,Results);
catch RetErr
    msg=sprintf('\nErrors while Writing the output: %s',RetErr.message);
    HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
    error(msg);
end
