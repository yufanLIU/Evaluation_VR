%=====================================================================
% File: Configure_GNoise.m
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

function varargout = Configure_GNoise(varargin)
% CONFIGURE_GNoise M-file for Configure_GNoise.fig
%      CONFIGURE_GNoise, by itself, creates a new CONFIGURE_GNoise or raises the existing
%      singleton*.
%
%      H = CONFIGURE_GNoise returns the handle to a new CONFIGURE_GNoise or the handle to
%      the existing singleton*.
%
%      CONFIGURE_GNoise('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURE_GNoise.M with the given input arguments.
%
%      CONFIGURE_GNoise('Property','Value',...) creates a new CONFIGURE_GNoise or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Configure_GNoise_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Configure_GNoise_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help Configure_GNoise

% Last Modified by GUIDE v2.5 21-Aug-2009 08:48:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Configure_GNoise_OpeningFcn, ...
                   'gui_OutputFcn',  @Configure_GNoise_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Configure_GNoise is made visible.
function Configure_GNoise_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Configure_GNoise (see VARARGIN)

clc
handles.PreviewHandle=0;

%Setting the defaults

Output=Default_GNoise();

handles.GNoiseData.Mean=Output{1};
handles.GNoiseData.Variance=Output{2};

handles.output={handles.GNoiseData.Mean handles.GNoiseData.Variance};

%Display the defaults in the edit boxes
set(handles.Mean,'String',num2str(handles.GNoiseData.Mean));
set(handles.Variance,'String',num2str(handles.GNoiseData.Variance));

guidata(hObject,handles);

[Args]=ParseInputs(varargin{:});
    set(handles.GNoise,'visible','on');
     if(~isempty(Args.Buffer))
        handles.bDoPreview=1;
        handles.InputBuffer=Args.Buffer;
        [handles.PreviewHandle]=DisplayImg(handles.PreviewHandle,'Preview',handles.InputBuffer);
        set(handles.PreviewHandle,'CloseRequestFcn',{@PreviewCloseFcn,handles});
    else
        handles.bDoPreview=0;
    end
    guidata(hObject,handles);
    uiwait(handles.GNoise);

    
function []=PreviewCloseFcn(hObject, eventdata, handles)
if(0~=handles.PreviewHandle)
    figure(handles.PreviewHandle);
    close gcf force;
    handles.PreviewHandle=0;
end
guidata(handles.GNoise,handles);

% --- Outputs from this function are returned to the command line.
function varargout = Configure_GNoise_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if(0~=handles.PreviewHandle)
    figure(handles.PreviewHandle);
    close gcf force;
    handles.PreviewHandle=0;
end
delete(handles.GNoise);


function Mean_Callback(hObject, eventdata, handles)
% hObject    handle to Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mean as text
%        str2double(get(hObject,'String')) returns contents of Mean as a double
temp=str2num(get(hObject,'String'));
handles.GNoiseData.Mean=temp;
if(1==handles.bDoPreview)
    MediaParam.RefFrame=handles.InputBuffer;
    MediaParam.DistortionSetting={handles.GNoiseData.Mean handles.GNoiseData.Variance};
    [Buffer]=Generate_GNoise(MediaParam);
    msg=['Preview: Mean: ' num2str(handles.GNoiseData.Mean) ' Variance: ' num2str(handles.GNoiseData.Variance)];
    [handles.PreviewHandle]=DisplayImg(handles.PreviewHandle,msg,Buffer);
end
guidata(handles.GNoise,handles);


% --- Executes during object creation, after setting all properties.
function Mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Variance_Callback(hObject, eventdata, handles)
% hObject    handle to Variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Variance as text
%        str2double(get(hObject,'String')) returns contents of Variance as a double
temp=str2num(get(hObject,'String'));
handles.GNoiseData.Variance=temp;
if(1==handles.bDoPreview)
    MediaParam.RefFrame=handles.InputBuffer;
    MediaParam.DistortionSetting={handles.GNoiseData.Mean handles.GNoiseData.Variance};
    [Buffer]=Generate_GNoise(MediaParam);
    msg=['Preview: Mean: ' num2str(handles.GNoiseData.Mean) ' Variance: ' num2str(handles.GNoiseData.Variance)];
    [handles.PreviewHandle]=DisplayImg(handles.PreviewHandle,msg,Buffer);
end
guidata(handles.GNoise,handles);


% --- Executes during object creation, after setting all properties.
function Variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
% hObject    handle to Done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles.output=CheckIfDone(handles);
catch RetErr

    errordlg(RetErr.message);
    return;
end
guidata(handles.GNoise,handles);
uiresume(handles.GNoise);

% --- Executes on button press in Help.
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
HelpPath=which('UIFilters.html');

web([HelpPath '#GNoise'] ,'-browser');

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=[];
guidata(handles.GNoise,handles);
uiresume(handles.GNoise);

% --- Executes when user attempts to close GNoise.
function GNoise_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to GNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(handles.GNoise, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.output=[];
    guidata(handles.GNoise,handles);
    uiresume(handles.GNoise);
else
    % The GUI is no longer waiting, just close it
    delete(handles.GNoise);
end


% --- Executes on key press over GNoise with no controls selected.
function GNoise_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to GNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output=[];

    % Update handles structure
    guidata(handles.GNoise,handles);

    uiresume(handles.GNoise);
end

if isequal(get(hObject,'CurrentKey'),'return')
    try
        handles.output=CheckIfDone(handles);
    catch RetErr

        errordlg(RetError.message);
        return;
    end
    guidata(handles.GNoise,handles);
    uiresume(handles.GNoise);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Output]=CheckIfDone(handles)
Output=[];
if(  (isfield(handles.GNoiseData,'Mean')) && (~isempty(handles.GNoiseData.Mean))  )
else
    %Error
    error('Please specify the mean of the Gaussian noise generator','No mean specified','modal');

end
if(  (isfield(handles.GNoiseData,'Variance')) && (~isempty(handles.GNoiseData.Variance)) )
else
    %Error
    error('Please specify the variance of the Gaussian noise generator','No variance specified','modal');

end


%If we have come this far, everything must be OK

Output={handles.GNoiseData.Mean handles.GNoiseData.Variance};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to parse command line arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Args]=ParseInputs(varargin)

%Default Args

    Args.Buffer=[];

    k=1;

    LengthArgIn=length(varargin);
    while (k <=LengthArgIn )
        arg = varargin{k};

        if(isfield(arg, 'Buffer'))
            Args.Buffer=arg.Buffer;
        end

        k=k+1;
    end %while(k<=LengthArgIn)

%end %ParseInputs(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%