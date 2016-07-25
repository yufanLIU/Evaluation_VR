%=====================================================================
% File: Handle_INR.m
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


function [Results]=Handle_INR(HandlerParam)
%Function that handles the looping for different images and metrics for no 
%reference image quality metrics.

HandlerParam.LogFn(HandlerParam.LogFilePtr,'Entered Handle_INR');

NumOfMetrics=numel(HandlerParam.MetricsID);
NumOfTestFiles=numel(HandlerParam.TestFiles);

DisplayImgHandle=0;

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

            MediaParam.Width=HandlerParam.TestImageWidth;
            MediaParam.Height=HandlerParam.TestImageHeight;

            [TestFrame]=ReadImage(HandlerParam.TestFiles{i},MediaParam);

            DisplayImgHandle=HandlerParam.ImgFn(DisplayImgHandle,HandlerParam.TestFiles{i},TestFrame);

        catch RetErr
            msg=['\nUnable to read Test file. Error: ' RetErr.message 'Skipping...' ];
            HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);
            ProgressParam.StatusMsg=msg;
            HandlerParam.ProgressFn(ProgressParam);
            continue;
        end

           %Process metric

           for j=1:NumOfMetrics
            Wrapper_name=['INR_Metrics_' lower(HandlerParam.MetricsID{j}) ];

            try
                %Call relevant metric
                msg=['Processing file with metric: ' HandlerParam.MetricsID{j}];
                HandlerParam.LogFn(HandlerParam.LogFilePtr,msg);

                ProgressParam.MetricName=HandlerParam.MetricsID{j};
                ProgressParam.MetricNumber=j;
                ProgressParam.StatusMsg=msg;
                HandlerParam.ProgressFn(ProgressParam);

                Results(i,j) = feval(Wrapper_name,  double(TestFrame) );
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

HandlerParam.LogFn(HandlerParam.LogFilePtr,'Exiting Handle_INR');
