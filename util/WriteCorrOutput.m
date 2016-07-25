%=====================================================================
% File: WriteCorrOutput.m
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


function WriteCorrOutput(filename,SelectedMetrics,SelectedCorrelations,CorrResult)
%Function that writes the results of correlation analysis into a file. If
%no file is specified, the results are displayed on screen.

    Correlations={'Pearson','Spearman','Outlier Ratio','Root Mean Square Error','Mean Absolute Error'};
    NumOfMetrics=numel(SelectedMetrics);
    NumOfResults=numel(find(SelectedCorrelations));

    OutputArray=cell(NumOfMetrics+1,NumOfResults+1);
    OutputArray(2:end,1)=strcat({''},SelectedMetrics(:)');
    Idx=find(SelectedCorrelations);
    OutputArray(1,2:end)=Correlations(Idx);
    OutputArray(2:end,2:end)=num2cell(CorrResult(Idx,:)');

    if(isempty(filename))
        %No filename found. Print results in window.
        ResultsFig=figure('Name','Results','NumberTitle','off','Menubar','none');
        ColumnName=OutputArray(1,:);

        ResultsTab=uitable('Parent',ResultsFig,'Units','normalized',...
                            'RowStriping','off','ColumnName',ColumnName,...
                            'Data',OutputArray(2:end,:),...
                            'Position',[0.1 0.1 0.8 0.8],...
                            'ColumnWidth','auto');
    else

        %Identify the extension
        [pathstr,name,ext]=fileparts(filename);
        tmp=lower(ext(2:end));

        switch tmp

            case {'xls','xlsx'}
                xlswrite(filename,OutputArray);
            case {'csv','txt'}
                fid=fopen(filename,'w');
                if(-1==fid)
                    error('Unable to open the file for writing the output.');
                else
                    [lines,cols]=size(OutputArray);
                    ClassMap=cellfun('isclass',OutputArray,'char');
                    ConversionFn=cell(size(OutputArray));
                    ConversionFn(:,:)=cellstr('num2str');
                    ConversionFn(ClassMap)=cellstr('char');
                    for i=1:lines
                        for j=1:cols
                            fprintf(fid,'%s,',feval(ConversionFn{i,j},OutputArray{i,j}));
                        end
                        fprintf(fid,'\n');
                    end
                    fclose(fid);
                    
                end %fid~=-1
                
            case {'html'}
                WriteHtmlOutput(filename,OutputArray,'Metrics Performance',1,1);

            otherwise
                  error('Unsupported output file format.');

        end %switch tmp
        
    end % ~isempty(filename)