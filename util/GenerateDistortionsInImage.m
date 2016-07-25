%=====================================================================
% File: GenerateDistortionsInImage.m
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


function [DistortedFrame,OutputFileName]=GenerateDistortionsInImage(TestGenData,LoggingParam,FileNumber,RefImgFn,UserSuffix)
%Function that applies the selected distortions to the image, to generate
%the distorted image.

NumOfDistortions=numel(TestGenData.SelectedDistortions.identifier);

DisplayRefImgHandle=0;


if(FileNumber>numel(TestGenData.TestFiles))
    return;
end

[filepath,name,ext]=fileparts(TestGenData.TestFiles{FileNumber});

try
    msg=['\n Reading test file: ' TestGenData.TestFiles{FileNumber}];
    msg=regexprep(msg,'\\','\\\');

    LoggingParam.LogFn(LoggingParam.LogFile,msg);
    MediaParam.Width=TestGenData.TestImageWidth;
    MediaParam.Height=TestGenData.TestImageHeight;

    [TestFrame]=ReadImage(TestGenData.TestFiles{FileNumber},MediaParam);
    DisplayRefImgHandle=RefImgFn(DisplayRefImgHandle,TestGenData.TestFiles{FileNumber},TestFrame);
catch RetErr
    %Error occurred while reading this file. Skip, log error and
    %proceed.
    msg=['\nError reading test file. Error: ' RetErr.message 'Skipping...'];
    LoggingParam.LogFn(LoggingParam.LogFile,msg);
    return;
end

clear MediaParam;
DistortedFrame=TestFrame;
[TestGenData.TestImageHeight,TestGenData.TestImageWidth]=size(TestFrame);

%Generate output file name
OutputFileName=[name '_W' num2str(TestGenData.TestImageWidth) '_H' num2str(TestGenData.TestImageHeight) ];

for j=1:NumOfDistortions

    try
        %Call relevant distortion
        msg=['\nApplying distortion: ' TestGenData.SelectedDistortions.name{j} ];
        LoggingParam.LogFn(LoggingParam.LogFile,msg);

        MediaParam.RefFrame=DistortedFrame;
        MediaParam.DistortionSetting=TestGenData.SelectedDistortions.Settings{j};

        fname=['Generate_' TestGenData.SelectedDistortions.identifier{j}];
        [DistortedFrame,suffix] = feval(fname,MediaParam);

        OutputFileName=[OutputFileName suffix];
        LoggingParam.LogFn(LoggingParam.LogFile,'\nFile processed successfully.');
    catch RetErr
        msg=['\nErrors while generating file. Error: ' RetErr.message];
        LoggingParam.LogFn(LoggingParam.LogFile,msg);
        break;
    end
end %for j=1:NumOfDistortions

if(~isempty(UserSuffix))
    %Discard the generated suffix, use the user specified suffix instead.
  OutputFileName=[name '_' UserSuffix];
end



