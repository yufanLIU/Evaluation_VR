%=====================================================================
% File: GenerateHTMLTable.m
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


function [OutputBuffer]=GenerateHTMLTable(OutputArray,RowHeaderPresent,ColHeaderPresent)
%Function that puts the "OutputArray" into an HTML table.

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
Tab=9;

OutputBuffer=[];
if(isempty(OutputArray))
    return;
end
[Rows,Cols]=size(OutputArray);

if(1==RowHeaderPresent)
    RowHeaderTag='th';
else
    RowHeaderTag='td';
end

if(1==ColHeaderPresent)
    ColHeaderTag='th';
else
    ColHeaderTag='td';
end
ClassMap=cellfun('isclass',OutputArray,'char');
ConversionFn=cell(size(OutputArray));
ConversionFn(:,:)=cellstr('num2str');
ConversionFn(ClassMap)=cellstr('char');

TableStartHtml=[NewLine,Tab,Tab,'<table>'];
RowStartHtml=[NewLine,Tab,Tab,Tab,'<tr>'];
ColStartHtml=[NewLine,Tab,Tab,Tab,Tab,'<'];
ColEndHtml=[NewLine,Tab,Tab,Tab,Tab,'</'];
RowEndHtml=[NewLine,Tab,Tab,Tab,'</tr>'];
TableEndHtml=[NewLine,Tab,Tab,'</table>'];
Terminator='>';

%First Row
OutputBuffer=[TableStartHtml,RowStartHtml];


for j=1:Cols
    OutputBuffer=[OutputBuffer,ColStartHtml,RowHeaderTag,Terminator];
    %Header Data
    OutputBuffer=[OutputBuffer,feval(ConversionFn{1,j},OutputArray{1,j})];
    OutputBuffer=[OutputBuffer,ColEndHtml,RowHeaderTag,Terminator];
end
OutputBuffer=[OutputBuffer,RowEndHtml];

%Subsequent Rows

for i=2:Rows
    OutputBuffer=[OutputBuffer,RowStartHtml];
    %First column

    OutputBuffer=[OutputBuffer,ColStartHtml,ColHeaderTag,Terminator];
    OutputBuffer=[OutputBuffer,feval(ConversionFn{i,1},OutputArray{i,1})];
    OutputBuffer=[OutputBuffer,ColEndHtml,ColHeaderTag,Terminator];

    %Subsequent Cols
    for j=2:Cols
        OutputBuffer=[OutputBuffer,ColStartHtml,'td',Terminator];
        OutputBuffer=[OutputBuffer,feval(ConversionFn{i,j},OutputArray{i,j})];
        OutputBuffer=[OutputBuffer,ColEndHtml,'td',Terminator];
    end
    OutputBuffer=[OutputBuffer,RowEndHtml];

end %for i=2:Rows

OutputBuffer=[OutputBuffer,TableEndHtml];
