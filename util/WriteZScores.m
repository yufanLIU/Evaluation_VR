%=====================================================================
% File: WriteZScores.m
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

function WriteZScores(filename,ZScoreArray,RejectedSub,ZScoreScaledArray,ScoreTypeString)
%Function that writes the Z-Scores into a file.

    str={['ZScores calculated using ' ScoreTypeString ' scores']};

	%Identify the extension
    [dummy1,dummy2,ext]=fileparts(filename);

    tmp=lower(ext(2:end));
      switch tmp

        case {'xls','xlsx'}
            %MATLAB warns you if you add a sheet at the end.
            warning off MATLAB:xlswrite:AddSheet
            xlswrite(filename,str,'ZScores','a1');
            xlswrite(filename,ZScoreArray,'ZScores','a3');

            if(~isempty(RejectedSub))
                xlswrite(filename,RejectedSub,'Rejected Subjects');
            end
            xlswrite(filename,ZScoreScaledArray,'Scaled ZScores');
            
        case {'csv','txt'}
            fid=fopen(filename,'w');
            if(-1==fid)
                error('Unable to open the file for writing the output.');
            else
                fprintf(fid,'\n===========================================');
                fprintf(fid,'\n');fprintf(fid,char(str));
                fprintf(fid,'\n===========================================');
                fprintf(fid,'\n');
                [Rows,Cols]=size(ZScoreArray);
                ClassMap=cellfun('isclass',ZScoreArray,'char');
                ConversionFn=cell(size(ZScoreArray));
                ConversionFn(:,:)=cellstr('num2str');
                ConversionFn(ClassMap)=cellstr('char');
                for i=1:Rows
                    for j=1:Cols
                        fprintf(fid,'%s,',feval(ConversionFn{i,j},ZScoreArray{i,j}));
                    end
                    fprintf(fid,'\n');
                end
                fprintf(fid,'\n===========================================');
                fprintf(fid,'\nRejected Subjects');
                fprintf(fid,'\n===========================================');
                fprintf(fid,'\n');
                if(~isempty(RejectedSub))
                    ClassMap=cellfun('isclass',RejectedSub,'char');
                    ConversionFn=cell(size(RejectedSub));
                    ConversionFn(:,:)=cellstr('num2str');
                    ConversionFn(ClassMap)=cellstr('char');

                    for i=1:length(RejectedSub)
                            fprintf(fid,'%s,',feval(ConversionFn{i},RejectedSub{i}));
                    end
                end

                fprintf(fid,'\n===========================================');
                fprintf(fid,'\nScaled ZScores');
                fprintf(fid,'\n===========================================');
                fprintf(fid,'\n');
                [Rows,Cols]=size(ZScoreScaledArray);
                ClassMap=cellfun('isclass',ZScoreScaledArray,'char');
                ConversionFn=cell(size(ZScoreScaledArray));
                ConversionFn(:,:)=cellstr('num2str');
                ConversionFn(ClassMap)=cellstr('char');
                for i=1:Rows
                    for j=1:Cols
                        fprintf(fid,'%s,',feval(ConversionFn{i,j},ZScoreScaledArray{i,j}));
                    end
                    fprintf(fid,'\n');

                end
                fclose(fid);
            end %fid~=-1
          case {'html'}
                fid=fopen(filename,'w');
                if(-1==fid)
                    error('Could not open output file for writing');
                else
                    %InsertinHTML searches for the tag '<body>' everytime. 
                    %Hence we have to insert in reverse order- Scaled 
                    %Z Scores followed by Rejected subjects and finally raw
                    %Z Scores.This ensures that we get the following layout:
                    %
                    % <body>
                    % Raw Z Scores
                    % Rejected subjects
                    % Scaled Z Scores
                    % </body>
                    
                    OutputBuffer=GenerateHTMLBody('Z Scores');
                    TableBuffer=GenerateHTMLTable(ZScoreScaledArray,1,0);
                    OutputBuffer=InsertinHTML(OutputBuffer,['<p>' TableBuffer '</p>'],'<body>');
                    OutputBuffer=InsertinHTML(OutputBuffer,'<h4>Scaled Z Scores</h4>','<body>');

                    TableBuffer=GenerateHTMLTable(num2cell(RejectedSub),0,0);
                    OutputBuffer=InsertinHTML(OutputBuffer,['<p>' TableBuffer '</p>'],'<body>');
                    OutputBuffer=InsertinHTML(OutputBuffer,'<h4>Rejected Subjects</h4>','<body>');

                    TableBuffer=GenerateHTMLTable(ZScoreArray,1,0);
                    OutputBuffer=InsertinHTML(OutputBuffer,['<p>' TableBuffer '</p>'],'<body>');
                    tmp=['<h4>' char(str) '</h4>'];
                    OutputBuffer=InsertinHTML(OutputBuffer,tmp,'<body>');

                    fwrite(fid,OutputBuffer,'uchar');
                    fclose(fid);
                end
          otherwise
                error('Unsupported output file format.');

      end %switch tmp
