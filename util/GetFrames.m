%=====================================================================
% File: GetFrames.m
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


function [NumReturnedFrames, YPlane,UPlane,VPlane ]=GetFrames(filename,Param)
%Function that gets the required number of frames from the stream

Width=Param.Width;
Height=Param.Height;
format=Param.Format;
StartFrame=Param.StartFrame;
NumRequestedFrames=Param.NumRequestedFrames;

YPlane=[];
UPlane=[];
VPlane=[];


	%Identify the extension
    [pathstr,name,ext]=fileparts(filename);
    tmp=lower(ext(2:end));
      switch tmp

      	case 'yuv'
			%Raw yuv file
            FileProp=dir(filename);
            SizeOfFile=FileProp.bytes;

			SizeOfFrame=Width*Height;

			switch format

				case 'YUV444Planar'
                    ChromaWidth=Width;
                    ChromaHeight=Height;

				case {'YUV422Planar','UYVY'}
                    ChromaWidth=ceil(Width/2);
                    ChromaHeight=Height;

				case 'YUV420Planar'
                    ChromaWidth=ceil(Width/2);
                    ChromaHeight=ceil(Height/2);
                    
                otherwise

			end %switch format
            
            BytesRequiredForFrame=(SizeOfFrame+(2*ChromaWidth*ChromaHeight));
            %Get the number of frames.
			NumOfFrames=floor(SizeOfFile/BytesRequiredForFrame);

            if(StartFrame>NumOfFrames)
                error('Requesting frame outside file');
            end

            if(-1==NumRequestedFrames)
                EndFrame=NumOfFrames;
            else
                EndFrame=StartFrame+NumRequestedFrames-1;
                if(EndFrame>NumOfFrames)
                    EndFrame=NumOfFrames;
                end
            end

            FramesToRead=EndFrame-StartFrame+1;

            k=1;
            fid=fopen(filename,'rb');

            fseek(fid,(StartFrame-1)*BytesRequiredForFrame,'bof');


            if(2==nargout)
                %Only Luminance required
                try
                    YPlane=zeros(Height,Width,FramesToRead);
                catch RetErr

                        try
                            YPlane=zeros(Height,Width,1);
                            EndFrame=StartFrame;
                        catch RetErr
                            error('Insufficient memory for frame');
                        end
                end

                if(1==strcmpi(format,'UYVY'))
                    for i=StartFrame:EndFrame
                        try
                            Planar=fread(fid,[2,Width*Height],'uchar');
                            YPlane(:,:,k)=reshape(Planar(2,:),Width,Height)';

                            NumReturnedFrames=k;
                            k=k+1;
                        catch RetErr
                            break;
                        end
                    end %for i=StartFrame:EndFrame
                else
                    for i=StartFrame:EndFrame
                        try
                            Planar=fread(fid,[Width,Height],'uchar');
                            YPlane(:,:,k)=Planar';

                            fseek(fid,ChromaWidth*ChromaHeight*2,'cof');
                            NumReturnedFrames=k;
                            k=k+1;
                        catch RetErr
                            break;
                        end
                    end %for i=StartFrame:EndFrame
                    
                end %if(1~=strcmpi(format,'UYVY'))

            elseif(4==nargout)
                %All components required
                try
                    YPlane=zeros(Height,Width,FramesToRead);
                    UPlane=zeros(Height,Width,FramesToRead);
                    VPlane=zeros(Height,Width,FramesToRead);
                catch RetErr
                        try
                            YPlane=zeros(Height,Width,1);
                            UPlane=zeros(Height,Width,1);
                            VPlane=zeros(Height,Width,1);
                            EndFrame=StartFrame;
                        catch RetErr
                            error('Insufficient memory for frame');
                        end
                end

                if(1==strcmpi(format,'UYVY'))
                    for i=StartFrame:EndFrame
                        try
                            Planar=fread(fid,[2,Width*Height],'uchar');
                            YPlane(:,:,k)=reshape(Planar(2,:),Width,Height)';

                            Planar(2,:)=Planar(1,:);

                            Planar(1,2:2:(Width*Height))=Planar(1,1:2:((Width*Height)-1));
                            Planar(2,1:2:((Width*Height)-1))=Planar(2,2:2:(Width*Height));

                            UPlane(:,:,k)=reshape(Planar(1,:),Width,Height)';
                            VPlane(:,:,k)=reshape(Planar(2,:),Width,Height)';

                            NumReturnedFrames=k;
                            k=k+1;
                        catch RetErr
                            break;
                        end

                    end %for i=StartFrame:EndFrame

                else
                    for i=StartFrame:EndFrame
                        try
                            Planar=fread(fid,[Width,Height],'uchar');
                            YPlane(:,:,k)=Planar';

                            Planar=fread(fid,[ChromaWidth,ChromaHeight],'uchar');
                            %Must upsample for vqm
                            if(ChromaHeight~=Height)
                                %420 to 422
                                Planar =  [Planar;Planar];
                                Planar=reshape(Planar,ChromaWidth,Height);
                            end
                            if(ChromaWidth~=Width)
                                %422 to 444
                                Planar=[Planar';Planar'];
                                Planar=reshape(Planar,Height,Width)';
                            end
                            UPlane(:,:,k)=Planar';

                            Planar=fread(fid,[ChromaWidth,ChromaHeight],'uchar');
                            %Must upsample for vqm
                            if(ChromaHeight~=Height)
                                %420 to 422
                                Planar =  [Planar;Planar];
                                Planar=reshape(Planar,ChromaWidth,Height);
                            end
                            if(ChromaWidth~=Width)
                                %422 to 444
                                Planar=[Planar';Planar'];
                                Planar=reshape(Planar,Height,Width)';
                            end
                            VPlane(:,:,k)=Planar';
                            NumReturnedFrames=k;
                            k=k+1;
                        catch RetErr
                            break;
                        end

                   end %for i=StartFrame:EndFrame
                   
                end %if(1~=strcmpi(format,'UYVY'))


            end %if(2==nargout)

            fclose(fid);

        case 'y'
            %Raw yuv file
            FileProp=dir(filename);
            SizeOfFile=FileProp.bytes;

			SizeOfFrame=Width*Height;
            BytesRequiredForFrame=(SizeOfFrame);
            %Get the number of frames.
			NumOfFrames=floor(SizeOfFile/BytesRequiredForFrame);

            if(StartFrame>NumOfFrames)
                error('Requesting frame outside file');
            end

            if(-1==NumRequestedFrames)
                EndFrame=NumOfFrames;
            else
                EndFrame=StartFrame+NumRequestedFrames-1;
                if(EndFrame>NumOfFrames)
                    EndFrame=NumOfFrames;
                end
            end

            FramesToRead=EndFrame-StartFrame+1;
            k=1;
            fid=fopen(filename,'rb');

            if(2==nargout)
                try
                    YPlane=zeros(Height,Width,FramesToRead);

                catch RetErr

                        try
                            YPlane=zeros(Height,Width,1);
                            EndFrame=StartFrame;
                        catch RetErr
                            error('Insufficient memory for frame');
                        end

                end
            elseif(4==nargout)
                try
                    YPlane=zeros(Height,Width,FramesToRead);
                    UPlane=128*ones(Height,Width,FramesToRead);
                    VPlane=128*ones(Height,Width,FramesToRead);
                catch RetErr
                        try
                            YPlane=zeros(Height,Width,1);
                            UPlane=128*ones(Height,Width,1);
                            VPlane=128*ones(Height,Width,1);
                            EndFrame=StartFrame;
                        catch RetErr
                            error('Insufficient memory for frame');
                        end

                end


            end %if(2==nargout)

            fseek(fid,(StartFrame-1)*BytesRequiredForFrame,'bof');
            for i=StartFrame:EndFrame
                try
                    Planar=fread(fid,[Width,Height],'uchar');

                    YPlane(:,:,k)=Planar';
                    NumReturnedFrames=k;
                    k=k+1;
                catch RetErr
                    break;
                end
            end %for i=StartFrame:EndFrame
            fclose(fid);

        case 'y4m'
            fid=fopen(filename,'r');
            %Check identifier
            temp=fread(fid,10,'uchar');
            if(0==strcmp(char(temp'),'YUV4MPEG2 '))
                %Invalid file
                fclose(fid);
                error('Invalid y4m file');
            end

            %We don't parse the header, just consume it. Assumption is that
            %GetVideoParam has been called already.

            bHeaderEndReached=0;

            %Parse the header

            while(1~=bHeaderEndReached)
                %Read a char.
                Identifier=fread(fid,1,'uchar');

                switch Identifier
                     case 'F'
                        %Check if we reached the frame. We should get 'R'
                        %instead of a number
                        tmpstr=[];
                        temp=fread(fid,1,'uchar');
                        if('R'==temp)
                            fseek(fid,-2,'cof');
                            bHeaderEndReached=1;
                            break;
                        else
                            %ignore
                            while((' '~=temp)&(10~=temp))
                                temp=fread(fid,1,'uchar');
                            end
                        end

                    otherwise
                        %ignore
                        temp=fread(fid,1,'uchar');
                        while((' '~=temp)&(10~=temp))
                            temp=fread(fid,1,'uchar');
                        end
                end %switch Identifier

            end %while(1~=bHeaderEndReached)

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
            status=fseek(fid,Width*Height*1.5,'cof');
            temp=fread(fid,5,'uchar');
            %Restore fid. Do it from the beginning because the fseek or the
            %fread above might have failed. The failure will be caught by
            %the if else below.
            fseek(fid,CurrLoc,'bof');
            if(1==(strcmp(char(temp'),'FRAME')))
                Format='YUV420Planar';
                FormatFactor=1.5;
                ChromaWidth=ceil(Width/2);
                ChromaHeight=ceil(Height/2);
            else
                %422
                status=fseek(fid,Width*Height*2,'cof');
                temp=fread(fid,5,'uchar');
                %Restore fid
                fseek(fid,CurrLoc,'bof');
                if(1==(strcmp(char(temp'),'FRAME')))
                    Format='YUV422Planar';
                    FormatFactor=2;
                    ChromaWidth=ceil(Width/2);
                    ChromaHeight=Height;
                else
                    %444
                    status=fseek(fid,Width*Height*3,'cof');
                    temp=fread(fid,5,'uchar');
                    %Restore fid
                    fseek(fid,CurrLoc,'bof');
                    if(1==(strcmp(char(temp'),'FRAME')))
                        Format='YUV444Planar';
                        FormatFactor=3;
                        ChromaWidth=Width;
                        ChromaHeight=Height;
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
            BytesRequiredForFrame=((Width*Height*FormatFactor)+(5+count+1));
            NumOfFrames=floor((LengthOfPayload+5+count+1)/BytesRequiredForFrame);

            if(StartFrame>NumOfFrames)
                fclose(fid);
                error('Requesting frame outside file');
            end

            if(-1==NumRequestedFrames)
                EndFrame=NumOfFrames;
            else
                EndFrame=StartFrame+NumRequestedFrames-1;
                if(EndFrame>NumOfFrames)
                    EndFrame=NumOfFrames;
                end
            end

            FramesToRead=EndFrame-StartFrame+1;
            k=1;

            if(2==nargout)
                %Only Luminance required
                try
                    YPlane=zeros(Height,Width,FramesToRead);
                catch RetErr
                        try
                            YPlane=zeros(Height,Width,1);
                            EndFrame=StartFrame;
                        catch RetErr
                            error('Insufficient memory for frame');
                        end

                end

                for i=StartFrame:EndFrame

                    %There might be characters after the "FRAME" keyword. You
                    %also have to skip the FRAME keyword per frame.

                    status=fseek(fid,((i-1)*BytesRequiredForFrame)+CurrLoc,'bof');

                    Planar=fread(fid,[Width,Height],'uchar');
                    YPlane(:,:,k)=Planar';
                    NumReturnedFrames=k;
                    k=k+1;

                end %for i=StartFrame:EndFrame

            elseif(4==nargout)
                %All components required
                try
                    YPlane=zeros(Height,Width,FramesToRead);
                    UPlane=zeros(Height,Width,FramesToRead);
                    VPlane=zeros(Height,Width,FramesToRead);
                catch RetErr
                        try
                            YPlane=zeros(Height,Width,1);
                            UPlane=zeros(Height,Width,1);
                            VPlane=zeros(Height,Width,1);
                            EndFrame=StartFrame;
                        catch RetErr
                            error('Insufficient memory for frame');
                        end
                end

                for i=StartFrame:EndFrame

                    %There might be characters after the "FRAME" keyword. You
                    %also have to skip the FRAME keyword per frame.

                    status=fseek(fid,((i-1)*BytesRequiredForFrame)+CurrLoc,'bof');

                    Planar=fread(fid,[Width,Height],'uchar');
                    YPlane(:,:,k)=Planar';

                    Planar=fread(fid,[ChromaWidth,ChromaHeight],'uchar');
                    %Must upsample for vqm
                    if(ChromaHeight~=Height)
                        %420 to 422
                        Planar =  [Planar;Planar];
                        Planar=reshape(Planar,ChromaWidth,Height);
                    end
                    if(ChromaWidth~=Width)
                        %422 to 444
                        Planar=[Planar';Planar'];
                        Planar=reshape(Planar,Height,Width)';
                    end
                    UPlane(:,:,k)=Planar';

                    Planar=fread(fid,[ChromaWidth,ChromaHeight],'uchar');
                    %Must upsample for vqm
                    if(ChromaHeight~=Height)
                        %420 to 422
                        Planar =  [Planar;Planar];
                        Planar=reshape(Planar,ChromaWidth,Height);
                    end
                    if(ChromaWidth~=Width)
                        %422 to 444
                        Planar=[Planar';Planar'];
                        Planar=reshape(Planar,Height,Width)';
                    end
                    VPlane(:,:,k)=Planar';

                    NumReturnedFrames=k;
                    k=k+1;

                end %for i=StartFrame:EndFrame

            end %if(2==nargout)

            fclose(fid);

		case 'avi'
            Fileinfo=VideoReader(filename);
            NumOfFrames=Fileinfo.NumFrames;
            if(StartFrame>NumOfFrames)
                error('Requesting frame outside file');
            end

            if(-1==NumRequestedFrames)
                idx=StartFrame:NumOfFrames;
            else
                if((StartFrame+NumRequestedFrames-1)>NumOfFrames)
                    idx=StartFrame:NumOfFrames;
                else
                    idx=StartFrame:StartFrame+NumRequestedFrames-1;
                end

            end %if(-1==NumRequestedFrames)

			try
                %Check if we have enough buffers to store the values
                FramesToRead=numel(idx);
                if(2==nargout)
                    try
                        YPlane=zeros(Height,Width,FramesToRead);
                    catch RetErr
                            try
                                YPlane=zeros(Height,Width,1);
                                idx=StartFrame;
                            catch RetErr
                                error('Insufficient memory for frame');
                            end
                    end

                elseif(4==nargout)
                    try
                        YPlane=zeros(Height,Width,FramesToRead);
                        UPlane=zeros(Height,Width,FramesToRead);
                        VPlane=zeros(Height,Width,FramesToRead);
                    catch RetErr
                            try
                                YPlane=zeros(Height,Width,1);
                                UPlane=zeros(Height,Width,1);
                                VPlane=zeros(Height,Width,1);

                                idx=StartFrame;
                            catch RetErr
                                error('Insufficient memory for frame');
                            end
                    end
                    
                end %if(2==nargout)
                
                mov = VideoReader(filename,idx);
                NumReturnedFrames=numel(idx);

            catch RetErr
                error(RetErr.message);
            end
            %Convert mov to luminance frame

            if(isempty(mov(1).colormap))
                %True color
                %Convert frames
                NumOfFrames=numel(mov);
                for i=1:NumOfFrames
                    YPlane(:,:,i)=0.29900 * mov(i).cdata(:,:,1) + 0.58700 * mov(i).cdata(:,:,2) + 0.11400 * mov(i).cdata(:,:,3);
                    UPlane(:,:,i)=-0.169 * mov(i).cdata(:,:,1) -0.331 * mov(i).cdata(:,:,2)+0.500 * mov(i).cdata(:,:,3);
                    VPlane(:,:,i)=0.500 * mov(i).cdata(:,:,1) -0.419 * mov(i).cdata(:,:,2) -0.081 * mov(i).cdata(:,:,3);
                end
                clear mov;
            else
                %unsupported
                error('Currently unsupported avi');
                
            end %if(isempty(mov(1).colormap))

	otherwise
                fname=['GetFrames_' tmp '.m'];

                if(2==exist(fname,'file'))

                    try
                        [NumReturnedFrames,YPlane,UPlane,VPlane]=feval(fname,filename);
                    catch RetErr
                        error('Unsupported extension.');
                        return;
                    end

                else
                    error('Unsupported extension.');
                    return;
                    
                end %if(2==exist(fname,'file'))
                
      end %switch tmp

end % GetFrames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%