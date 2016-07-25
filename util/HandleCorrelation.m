%=====================================================================
% File: HandleCorrelation.m
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


function HandleCorrelation(handles)
%Function that is called when the "Start" button is clicked and the 
%correlation tab is active. 

%Check if logging is to be performed

if(-1~=handles.FilePointers.LogFile)
    LogFn=@PerformLogging;
else
    LogFn=@NoLogging;
end

PlotParams.PlotMOS=handles.ToolOptions.PlotMOS;
PlotParams.PlotPrediction=handles.ToolOptions.PlotPrediction;
PlotParams.PlotOutlierBounds=handles.ToolOptions.PlotOutlierBounds;
PlotParams.OutlierDisplay=handles.ToolOptions.OutlierDisplay;
PlotParams.SavePlots=handles.ToolOptions.SavePlots;
PlotParams.PlotPath=handles.ToolOptions.PlotPath;
PlotParams.PlotHandle=0;

%Validating UI selections

LogFn(handles.FilePointers.LogFile,'\nValidating UI selections for the Correlation Tab...');

if((~isfield(handles.CorrData,'MOSFilename'))|| (isempty(handles.CorrData.MOSFilename)))
    LogFn(handles.FilePointers.LogFile,'\nNo MOS file specified.');
    error('No MOS file specified.');
end

if((~isfield(handles.CorrData.SelectedMetrics,'name'))|| (isempty(handles.CorrData.SelectedMetrics.name)))
    LogFn(handles.FilePointers.LogFile,'\nNo metric selected.');
    error('No metric selected');
end

if((~isfield(handles.CorrData,'ObjFilename'))|| (isempty(handles.CorrData.ObjFilename)))
    LogFn(handles.FilePointers.LogFile,'\nNo Objective metrics file specified.');
    error('No Objective metrics file specified.');
end

if((~isfield(handles.CorrData,'SelectedCorrelations'))|| (isempty(find(handles.CorrData.SelectedCorrelations,1))))
    LogFn(handles.FilePointers.LogFile,'\nNo Correlation coefficient specified.');
    error('No Correlation coefficient specified.');
end

if((1==strcmp(handles.ToolOptions.LogisticChoice,'user')) && (isempty(handles.ToolOptions.ModelFn)))
    LogFn(handles.FilePointers.LogFile,'\nNo Logistic function specified.');
    error('No Logistic function specified.');
end

NumOfMetrics=numel(handles.CorrData.SelectedMetrics.identifier);

%Read MOS file.

LogFn(handles.FilePointers.LogFile,'\nReading MOS File...');
try
    [MOSnum,MOStxt]=ReadTabulatedValues(handles.CorrData.MOSFilename);
catch RetErr
    msg=sprintf('\nErrors while Reading MOS file: %s',RetErr.message);
    LogFn(handles.FilePointers.LogFile,msg);
    error(msg);
end

%Read the Objective metrics file

try
    [OBJNum,OBJtxt]=ReadTabulatedValues(handles.CorrData.ObjFilename);
catch RetErr
    msg=sprintf('\nErrors while Reading Objective scores file: %s',RetErr.message);
    LogFn(handles.FilePointers.LogFile,msg);
    error(msg);

end

%Check for out of bound access
%MOStxt and OBJtxt must have atleast 2 rows and 2 cols.

if((~isempty(find(size(MOStxt)<2,1)))||...
    (~isempty(find(size(OBJtxt)<2,1)))...
    )
    msg='The MOS or objective metrics do not contain sufficient data or do not contain a header and listing of test file names.';
    LogFn(handles.FilePointers.LogFile,msg);
    error(msg);
end

%Check if the files in the MOS file match those in the objective metrics
%file.

tmp=setdiff({MOStxt{2:end,1}},{OBJtxt{2:end,1}});

if(~isempty(tmp))
    msg='The MOS and objective metrics use different test files.';
    LogFn(handles.FilePointers.LogFile,msg);
    error(msg);
end

%Extract MOS from the file.

[IntResult,MOSColIdx,ib]=intersect({MOStxt{1,:}},{'MOS','Mos','mos','Mean Opinion Score'});
[NumOfSubjects,LastSubject,SubColIdx]=ReadSubjectNumbers(lower(MOStxt(1,:)));
SubjectiveScoreIndices=[];
SubScores=[];

if(isempty(MOSColIdx))
    %Check if Subjective scores are there. If yes, we can generate the MOS
    if(0~=NumOfSubjects)
        %Some subjective scores exist, can calculate MOS
        SubjectiveScoreIndices=SubColIdx-1;
        SubScores=MOSnum(:,SubjectiveScoreIndices);
        MOSScores=mean(SubScores,2);
    else
        msg='Cannot find the column containing the MOS scores';
        LogFn(handles.FilePointers.LogFile,msg);
        error(msg);
    end
else
    MOSScores=MOSnum(:,MOSColIdx-1);
    
end %if(isempty(MOSColIdx))

if(1==handles.CorrData.SelectedCorrelations(3))
    %Outlier ratio has been chosen. See if we have either std or subject
    %scores

    [IntResult,STDColIdx,ib]=intersect({MOStxt{1,:}},{'std','STD'});

    if(isempty(STDColIdx))
        %No STD found. Check if we have Subjective scores
        if(0~=NumOfSubjects)
            %Calculate std from subjective scores
            SubjectiveScoreIndices=SubColIdx-1;
            SubScores=MOSnum(:,SubjectiveScoreIndices);
            EvalMetricPerformParam.IsSTD=0;

        else
            msg='No subjective scores or Standard deviation found in MOS file. Cannot do Outlier Ratio';
            LogFn(handles.FilePointers.LogFile,msg);
            EvalMetricPerformParam.IsSTD=0;

            error(msg);
        end
    else
        %Use std
        SubScores=MOSnum(:,STDColIdx-1);
        EvalMetricPerformParam.IsSTD=1;

    end %if(isempty(STDColIdx))

else
    %Don't care if std or subject scores are present or not
    SubScores=[];
    EvalMetricPerformParam.IsSTD=0;

end %(1==handles.CorrData.SelectedCorrelations(3))

EvalMetricPerformParam.PlotParams=PlotParams;

EvalMetricPerformParam.SubjectiveScores=SubScores;
EvalMetricPerformParam.MOSScores=MOSScores;
EvalMetricPerformParam.LogisticChoice=handles.ToolOptions.LogisticChoice;
EvalMetricPerformParam.ModelFn=handles.ToolOptions.ModelFn;
EvalMetricPerformParam.ModelFnVar=handles.ToolOptions.ModelFnVar;

CorrResult=zeros(5,NumOfMetrics);

PredictedMOSArray=zeros(size(OBJNum,1),NumOfMetrics);

%Call the correlation function

for i=1:NumOfMetrics
    [IntResult,OBJColIdx,ib]=intersect({OBJtxt{1,:}},handles.CorrData.SelectedMetrics.identifier{i});

    if(isempty(OBJColIdx))
    %We do not have objective metrics for this metric
    else
        EvalMetricPerformParam.OBJScore=OBJNum(:,OBJColIdx-1);
        EvalMetricPerformParam.PlotParams.MetricName=handles.CorrData.SelectedMetrics.identifier{i};
        msg=['Evaluating performance for metric: ' handles.CorrData.SelectedMetrics.identifier{i}];
        LogFn(handles.FilePointers.LogFile,msg);

        [PredictedMOSArray(:,i),CorrResult(1,i),CorrResult(2,i),CorrResult(3,i),CorrResult(4,i),CorrResult(5,i)]=evaluate_metric_performance(EvalMetricPerformParam);

    end

end %for i=1:NumOfMetrics

LogFn(handles.FilePointers.LogFile,'\nWriting Correlation analysis output...');
try
    WriteCorrOutput(handles.CorrData.OutputFilename,handles.CorrData.SelectedMetrics.identifier,handles.CorrData.SelectedCorrelations,CorrResult);
catch RetErr
    msg=['Error while writing Correlation Analysis output: ' RetErr.message];
    LogFn(handles.FilePointers.LogFile,msg);
    error(msg);

end

if(0~=handles.ToolOptions.SaveMOS)
    LogFn(handles.FilePointers.LogFile,'\nWriting Predicted MOS');
    try
        WritePredictedMOS(handles.ToolOptions.MOSSaveFile,MOStxt(2:end,1),handles.CorrData.SelectedMetrics.identifier,MOSScores,PredictedMOSArray);
    catch RetErr
        msg=['Error while writing Predicted MOS: ' RetErr.message];
        LogFn(handles.FilePointers.LogFile,msg);
        error(msg);

    end
    
end %if(0~=handles.ToolOptions.SaveMOS)
