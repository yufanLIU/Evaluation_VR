%=====================================================================
% File: Handle_VNR.m
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


function [Results]=Handle_VNR(HandlerParam)
%Function that handles the looping for different videos and metrics for no 
%reference video quality metrics.

HandlerParam.LogFn(HandlerParam.LogFilePtr,'Entered Handle_VNR');

NumOfMetrics=numel(HandlerParam.MetricsID);
NumOfTestFiles=numel(HandlerParam.TestFiles);

Results=nan(NumOfTestFiles,NumOfMetrics);

ProgressParam.MetricName=[];
ProgressParam.TestFilename=[];
ProgressParam.StatusMsg=[];
ProgressParam.NumOfMetrics=[];
ProgressParam.NumOfTestFiles=NumOfTestFiles;
ProgressParam.MetricNumber=[];
ProgressParam.TestFileNumber=[];

    for i=1:NumOfTestFiles

        ProgressParam.NumOfMetrics=NumOfMetrics;
        ProgressParam.MetricNumber=1;
        
        %Read Test
        try
            msg=['\nReading Test file: ' HandlerParam.TestFiles{i}];
            msg=regexprep(msg,'\\','\\\');
            HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);

            ProgressParam.StatusMsg='Reading Test file...';
            ProgressParam.TestFileNumber=i;
            ProgressParam.TestFilename=HandlerParam.TestFiles{i};
            HandlerParam.ProgressFn(ProgressParam);

            [TestMediaParam]=GetVideoParam(HandlerParam.TestFiles{i},HandlerParam.TestImageWidth,HandlerParam.TestImageHeight,HandlerParam.TestFPS,HandlerParam.TestFormat);
            %Check if we have space to store the test files.

            TotalReqdSize=HandlerParam.TestImageWidth*HandlerParam.TestImageHeight*3*TestMediaParam.NumOfFrames;
            try
                %Dummy allocation to see if memory is available
                t=zeros(TotalReqdSize);
                FrameServerParam.NumRequestedFrames=-1;
                FrameServerParam.MaxBufferableFrames=TestMediaParam.NumOfFrames;
                clear t;
                HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nEnough memory to store entire video');
            catch RetErr

                    %Not enough memory. Must stream video.

                    %Check if we can store 30 frames. If not go to worst case
                    %scenario of 1 frame.

                    TotalReqdSize=HandlerParam.TestImageWidth*HandlerParam.TestImageHeight*3*30;
                    try
                        %Dummy allocation to see if memory is available
                        t=zeros(TotalReqdSize);
                        FrameServerParam.NumRequestedFrames=30;
                        FrameServerParam.MaxBufferableFrames=30;
                        clear t;
                        HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nEnough memory to store 30 frames');
                    catch RetErr
                            %Not enough memory. Must stream video.

                            %Check if we can store 1 frame.

                            TotalReqdSize=HandlerParam.TestImageWidth*HandlerParam.TestImageHeight*3;
                            try
                                %Dummy allocation to see if memory is available
                                t=zeros(TotalReqdSize);
                                FrameServerParam.NumRequestedFrames=1;
                                FrameServerParam.MaxBufferableFrames=1;
                                clear t;
                                HandlerParam.LogFn(HandlerParam.LogFilePtr,'\nEnough memory to store one frame');


                            catch RetErr
                                msg=['\nFailure while trying allocate memory: ' RetErr.message ];
                                HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
                                error(msg);
                                
                            end %try single frame

                    end %try 30 frames

            end %try entire video
            
            FrameServerParam.StartFrame=1;

            %Do not call read the frames yet, let the individual metrics handle
            %it. We just give it the function pointer.
            FrameServerParam.FrameServerFn=@GetFrames;

        catch RetErr
            msg=['\nUnable to read Test file. Error: ' RetErr.message 'Skipping...' ];
            HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
            ProgressParam.StatusMsg=msg;
            HandlerParam.ProgressFn(ProgressParam);
            continue;
        end

           %Process metric

           for j=1:NumOfMetrics
            Wrapper_name=['VNR_Metrics_' lower(HandlerParam.MetricsID{j}) ];

            try
                %Call relevant metric
                msg=['Processing file with metric: ' HandlerParam.MetricsID{j}];
                HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);

                ProgressParam.MetricName=HandlerParam.MetricsID{j};
                ProgressParam.MetricNumber=j;
                ProgressParam.StatusMsg=msg;
                HandlerParam.ProgressFn(ProgressParam);

                Results(i,j)= feval(Wrapper_name, HandlerParam.TestFiles{i},TestMediaParam,FrameServerParam );

                msg='File processed successfully.';
                HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
                ProgressParam.StatusMsg=msg;

                HandlerParam.ProgressFn(ProgressParam);

            catch RetErr

                msg=['\nErrors while computing metrics. Error: ' RetErr.message];
                HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
                ProgressParam.StatusMsg=msg;

                HandlerParam.ProgressFn(ProgressParam);
            end

           end %for j=1:NumOfMetrics

    end %for i=1:NumOfTestFiles
    
HandlerParam.LogFn(HandlerParam.LogFilePtr,'Exiting Handle_VNR');
