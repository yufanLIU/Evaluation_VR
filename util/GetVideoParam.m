%=====================================================================
% File: GetVideoParam.m
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


function [MediaParam]=GetVideoParam(filename,DefaultWidth,DefaultHeight,DefaultFPS,DefaultFormat)
%Function that reads the headers of the video stream to extract the video
%parameters

%Identify the extension
    [pathstr,name,ext]=fileparts(filename);
    tmp=lower(ext(2:end));
      switch tmp
          case 'yuv'
              %File does not contain a header that contains frame
              %dimensions. Return the defaults that should have been
              %entered in the UI
              MediaParam.Width=DefaultWidth;
              MediaParam.Height=DefaultHeight;
              MediaParam.FPS=DefaultFPS;
              MediaParam.Format=DefaultFormat;

              %Calculate number of frames

              %Raw yuv file
              FileProp=dir(filename);
              SizeOfFile=FileProp.bytes;

              SizeOfFrame=MediaParam.Width*MediaParam.Height;

              switch DefaultFormat

                case 'YUV444Planar'
                    ChromaWidth=MediaParam.Width;
                    ChromaHeight=MediaParam.Height;

                case {'YUV422Planar','UYVY'}
                    ChromaWidth=ceil(MediaParam.Width/2);
                    ChromaHeight=MediaParam.Height;

                case 'YUV420Planar'
                    ChromaWidth=ceil(MediaParam.Width/2);
                    ChromaHeight=ceil(MediaParam.Height/2);

                  otherwise

              end %switch DefaultFormat
              
              BytesRequiredForFrame=(SizeOfFrame+(2*ChromaWidth*ChromaHeight));
              %Get the number of frames.
              MediaParam.NumOfFrames=floor(SizeOfFile/BytesRequiredForFrame);

          case 'y'
              %File does not contain a header that contains frame
              %dimensions. Return the defaults that should have been
              %entered in the UI
              MediaParam.Width=DefaultWidth;
              MediaParam.Height=DefaultHeight;
              MediaParam.FPS=DefaultFPS;
              MediaParam.Format=DefaultFormat;

              %Calculate number of frames

              %Raw luminance only file
              FileProp=dir(filename);
              SizeOfFile=FileProp.bytes;
              SizeOfFrame=MediaParam.Width*MediaParam.Height;

              %Get the number of frames.
              MediaParam.NumOfFrames=floor(SizeOfFile/SizeOfFrame);

          case 'avi'
              Fileinfo=VideoReader(filename);
              if((isfield(Fileinfo,'Width')))
                MediaParam.Width=Fileinfo.Width;
              else
                MediaParam.Width=DefaultWidth;
              end
              if((isfield(Fileinfo,'Height')))
                MediaParam.Height=Fileinfo.Height;
              else
                MediaParam.Height=DefaultHeight;
              end
              if((isfield(Fileinfo,'FramesPerSecond')))
                MediaParam.FPS=Fileinfo.FramesPerSecond;
              else
                MediaParam.FPS=DefaultFPS;
              end
              if((isfield(Fileinfo,'NumFrames')))
                MediaParam.NumOfFrames=Fileinfo.NumFrames;
              else
                MediaParam.NumOfFrames=1;
              end
              MediaParam.Format='YUV444Planar';
          case 'y4m'
                %function to read files
                fid=fopen(filename,'r');

                %Check identifier
                temp=fread(fid,10,'uchar');
                if(0==strcmp(char(temp'),'YUV4MPEG2 '))
                    %Invalid file
                    fclose(fid);
                    error('Invalid y4m file');
                end

                NumParamFound=0;

                %Parse the header

                while(3~=NumParamFound)
                    %Read a char.
                    Identifier=fread(fid,1,'uchar');


                    switch Identifier
                        case 'W'
                            %Read till you get the space
                            tmpstr=[];
                            temp=fread(fid,1,'uchar');
                            while((' '~=temp)& (10~=temp))
                                tmpstr=[tmpstr temp];
                                temp=fread(fid,1,'uchar');
                            end
                            MediaParam.Width=str2num(char(tmpstr));
                            NumParamFound=NumParamFound+1;
                        case 'H'
                            %Read till you get the space
                            tmpstr=[];
                            temp=fread(fid,1,'uchar');
                            while((' '~=temp)& (10~=temp))
                                tmpstr=[tmpstr temp];
                                temp=fread(fid,1,'uchar');
                            end
                            MediaParam.Height=str2num(char(tmpstr));
                            NumParamFound=NumParamFound+1;
                        case 'F'
                            %Check if we reached the frame. We should get 'R'
                            %instead of a number
                            tmpstr=[];
                            temp=fread(fid,1,'uchar');
                            if('R'==temp)
                                fseek(fid,-2,'cof');
                                NumParamFound=3;
                                break;
                            end
                            while((' '~=temp)&(10~=temp))
                                tmpstr=[tmpstr temp];
                                temp=fread(fid,1,'uchar');
                            end
                            %Extract the numerator and the denominator
                            [Num,Denom]=strtok(char(tmpstr),':');
                            %Discard the ':'
                            Denom=Denom(2:end);
                            MediaParam.FPS=str2num(Num)/str2num(Denom);
                            NumParamFound=NumParamFound+1;
                        otherwise
                            %ignore
                            temp=fread(fid,1,'uchar');
                            while((' '~=temp)&(10~=temp))
                                temp=fread(fid,1,'uchar');
                            end
                    end %switch Identifier

                end %while(3~=NumParamFound)
                 %Check if we are at the start of a frame.
            temp=fread(fid,5,'uchar');
            if(1==(strcmp(char(temp'),'FRAME')))
                %Consume bytes until we get the '0x0A'
                temp=fread(fid,1,'uchar');
                %Count the number of bytes between 'FRAME' and '0x0A'
                count=0;
                while((10~=temp))
                    temp=fread(fid,1,'uchar');
                    count=count+1;
                end
            end %if(1==(strcmp(temp,'FRAME')))

            %Check if the format is 444,422 or 420

            %420

            %Save current file pointer location
            CurrLoc=ftell(fid);
            status=fseek(fid,MediaParam.Width*MediaParam.Height*1.5,'cof');
            temp=fread(fid,5,'uchar');
            %Restore fid. Do it from the beginning because the fseek or the
            %fread above might have failed. The failure will be caught by
            %the if else below.
            fseek(fid,CurrLoc,'bof');
            if(1==(strcmp(char(temp'),'FRAME')))
                MediaParam.Format='YUV420Planar';
                FormatFactor=1.5;
                ChromaWidth=ceil(MediaParam.Width/2);
                ChromaHeight=ceil(MediaParam.Height/2);
            else
                %422
                status=fseek(fid,MediaParam.Width*MediaParam.Height*2,'cof');
                temp=fread(fid,5,'uchar');
                %Restore fid
                fseek(fid,CurrLoc,'bof');
                if(1==(strcmp(char(temp'),'FRAME')))
                    MediaParam.Format='YUV422Planar';
                    FormatFactor=2;
                    ChromaWidth=ceil(MediaParam.Width/2);
                    ChromaHeight=MediaParam.Height;
                else
                    %444
                    status=fseek(fid,MediaParam.Width*MediaParam.Height*3,'cof');
                    temp=fread(fid,5,'uchar');
                    %Restore fid
                    fseek(fid,CurrLoc,'bof');
                    if(1==(strcmp(char(temp'),'FRAME')))
                        MediaParam.Format='YUV444Planar';
                        FormatFactor=3;
                        ChromaWidth=MediaParam.Width;
                        ChromaHeight=MediaParam.Height;
                    else
                        fclose(fid);
                        error('Unrecognised y4m file');
                    end %Not 444
                end %Not 422
            end %Not 420

            %Calculate number of frames
            fseek(fid,0,'eof');
            LengthOfPayload=ftell(fid)-CurrLoc;

            %Restore to beginning of frame
            fseek(fid,CurrLoc,'bof');

            %Assumption is that the number of parameters between 'FRAME'
            %and 0x0A is the same for all frames.
            %5 for 'FRAME'+count+ 1 for '0x0A'
            BytesRequiredForFrame=((MediaParam.Width*MediaParam.Height*FormatFactor)+(5+count+1));
            MediaParam.NumOfFrames=floor((LengthOfPayload+5+count+1)/BytesRequiredForFrame);

            fclose(fid);

          otherwise
            fname=['GetVideoParam_' tmp '.m'];

                if(2==exist(fname,'file'))

                    try
                        MediaParam=feval(fname,filename);
                    catch
                        error('Unsupported extension.');
                        return;
                    end
                else
                    error('Unsupported extension.');
                    return;
                    
                end %if(2==exist(fname,'file'))
                
      end %switch tmp
