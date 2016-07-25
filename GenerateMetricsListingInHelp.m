%=====================================================================
% File: GenerateMetricsListingInHelp.m
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

function []=GenerateMetricsListingInHelp()
%Function that reads the specified text files and generates the help documentation.
%
%The description files are:
%
%  IFRMetricsDesc.txt - File describing the full reference metrics for image
%  IRRMetricsDesc.txt - File describing the reduced reference metrics for image
%  INRMetricsDesc.txt - File describing the no reference metrics for image
%  VFRMetricsDesc.txt - File describing the full reference metrics for video
%  VRRMetricsDesc.txt - File describing the reduced reference metrics for video
%  VNRMetricsDesc.txt - File describing the no reference metrics for video
%
% The function uses the 'MetricsTemplate.html' template to generate the 'metrics.html' file.
% "metrics.html" describes the metrics currently included in the software package.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Reading the template
TemplateFile=which('MetricsTemplate.html');
TemplateFid=fopen(TemplateFile,'r');
if(-1==TemplateFid)
    fprintf('\nCould not find the template file');
    return;
end

Buffer=fread(TemplateFid,inf,'uchar');
fclose(TemplateFid);

str=char(Buffer)';
clear Buffer;

[CompType]=computer;
if(1==(strcmp('PCWIN',CompType)))
    %13->CR 10->LF
    NewLine=[13,10];
elseif(1==(strcmp('MAC',CompType)))
    %13->CR
    NewLine=[13];
else
    %Variants of UNIX
    %10->LF
    NewLine=[10];
end

OutputFid=fopen('metrics.html','w');
if(-1==OutputFid)
    fprintf('\nCould not open output file for writing');
    return;
end

TableGenParam={{'"IFRArea">','IFRMetricsDesc.txt'}...
               {'"IRRArea">','IRRMetricsDesc.txt'}...
               {'"INRArea">','INRMetricsDesc.txt'}...
               {'"VFRArea">','VFRMetricsDesc.txt'}...
               {'"VRRArea">','VRRMetricsDesc.txt'}...
               {'"VNRArea">','VNRMetricsDesc.txt'}...
    };

% Read the descriptions files and generate the tables

RestartFrom=1;
for i=1:6
    j=findstr(str,TableGenParam{i}{1});
    Offset=length(TableGenParam{i}{1})-1;
    %Copy the code including this id and the "> after it into Temp.
    Temp=str(RestartFrom:j+Offset);
    %Save the current pointer
    RestartFrom=j+Offset+1;
    fwrite(OutputFid,Temp,'uchar');
    Temp=GenerateTableCode(TableGenParam{i}{2},NewLine);
    fwrite(OutputFid,Temp,'uchar');
end

Temp=str(RestartFrom:end);

%Writing the output
fwrite(OutputFid,Temp,'uchar');

fclose(OutputFid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OutputBuffer]=GenerateTableCode(DescriptionFile,NewLine)

Tab=9;
TableStartHtml=['<table class=metricstable>'];
RowStartHtml=[NewLine,Tab,'<tr>',NewLine,Tab,Tab];
RowEndHtml=['</td>',NewLine,Tab,'</tr>'];

MetricRowHtml=['<td class=metricsheader>Metric name</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
ShortRowHtml=['<td class=metricsheader>Metric short name</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
PaperRowHtml=['<td class=metricsheader>Paper name</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
AuthorRowHtml=['<td class=metricsheader>Authors</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
SourceRowHtml=['<td class=metricsheader>Paper Source</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
WebsiteRowHtml=['<td class=metricsheader>Website</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
CodeRowHtml=['<td class=metricsheader>Code in this package</td>',NewLine,Tab,Tab,Tab,'<td class=metricsdata>'];
TableEndHtml=['</table>'];

% Read the metrics descriptions

MetricsDesc=which(DescriptionFile);
fid=fopen(MetricsDesc,'r');
MetricsData = textscan(fid,'%s%s%s%s%s%s%s',-1,'delimiter',';');
fclose(fid);
NumOfMetrics=length(MetricsData{1});

%Draw the tables
OutputBuffer=[];
for i=1:NumOfMetrics
    if((length(MetricsData{6}{i})>7)&& (1==strcmp(MetricsData{6}{i}(1:7),'http://')))
        WebsiteDetails=['<a target="_new" href="' MetricsData{6}{i} '">' MetricsData{6}{i} '</a>' ];
    else
        WebsiteDetails=[MetricsData{6}{i}];
    end
    TableStr=[TableStartHtml,...
        RowStartHtml,MetricRowHtml,MetricsData{1}{i},RowEndHtml,...
        RowStartHtml,ShortRowHtml,MetricsData{2}{i},RowEndHtml,...
        RowStartHtml,PaperRowHtml,MetricsData{3}{i},RowEndHtml,...
        RowStartHtml,AuthorRowHtml,MetricsData{4}{i},RowEndHtml,...
        RowStartHtml,SourceRowHtml,MetricsData{5}{i},RowEndHtml,...
        RowStartHtml,WebsiteRowHtml,WebsiteDetails,RowEndHtml,...
        RowStartHtml,CodeRowHtml,MetricsData{7}{i},RowEndHtml,...
        TableEndHtml];

    OutputBuffer=[OutputBuffer,'<p>',TableStr,'</p><br>'];
end
