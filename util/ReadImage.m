%=====================================================================
% File: ReadImage.m
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


function [YPlane]=ReadImage(filename,ImageParam)
%Function that reads the image.

Width=ImageParam.Width;
Height=ImageParam.Height;

	%Identify the extension
      [dummy1,dummy2,ext]=fileparts(filename);
      tmp=lower(ext(2:end));

      FrameSize=Width*Height;
      switch tmp

      	case {'yuv','y'}
	     %Raw yuv file
            FileProp=dir(filename);
            SizeOfFile=FileProp.bytes;

	     %Since we are only dealing with the Y plane and a single frame
            %we don't have to worry about the format

            %Check if size of file is atleast size of Luminance frame.

            if(SizeOfFile<FrameSize)
                error('File size less than required');
            end
            fid=fopen(filename,'rb');
     	    if(-1==fid)
     	       error('Could not open file');
            end

            Planar=fread(fid,FrameSize,'uchar');

            YPlane=reshape(Planar,Width,Height)';

            fclose(fid);

        case {'jpg','jpeg','bmp','tiff'}
			%Single frame formats supported by imread

            try
                Img=imread(filename);
            catch
                error('Error reading file.');
            end
            ImgInfo=imfinfo(filename);

            if((0==ImgInfo.Height) ||(0==ImgInfo.Width))
                  error('Invalid file.');
            end

            switch(ImgInfo.BitDepth)
                case 8
                    %Assume it is the luminance
                    YPlane=Img;
                case 24
                    %Identify the type
                   if(1==strcmp('jpg',ImgInfo.Format))
                        YPlane=Img(:,:,1);
                    else
                        %BMP,TIFF
                        ImgYUV = rgb2ycbcr(Img);
                        YPlane=ImgYUV(:,:,1);
                    end
                otherwise
                      error('Unsupported image file.');
                      
            end %switch(ImgInfo.BitDepth)
            
        otherwise
                fname=['Read_' tmp '.m'];

                if(2==exist(fname,'file'))

                    try
                        YPlane=feval(fname,filename);
                    catch
                        error('Unsupported extension.');
                        return;
                    end


                else
                    error('Unsupported extension.');
                    return;
                end

      end %switch tmp

end % ReadImage
