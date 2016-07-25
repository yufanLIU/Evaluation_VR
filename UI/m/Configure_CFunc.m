%=====================================================================
% File: Configure_CFunc.m
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
 
function varargout = Configure_CFunc(varargin)
% CONFIGURE_CFunc M-file for Configure_CFunc.fig
%      CONFIGURE_CFunc, by itself, creates a new CONFIGURE_CFunc or raises the existing
%      singleton*.
%
%      H = CONFIGURE_CFunc returns the handle to a new CONFIGURE_CFunc or the handle to
%      the existing singleton*.
%
%      CONFIGURE_CFunc('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURE_CFunc.M with the given input arguments.
%
%      CONFIGURE_CFunc('Property','Value',...) creates a new CONFIGURE_CFunc or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Configure_CFunc_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Configure_CFunc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help Configure_CFunc

% Last Modified by GUIDE v2.5 21-Aug-2009 08:48:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Configure_CFunc_OpeningFcn, ...
                   'gui_OutputFcn',  @Configure_CFunc_OutputFcn, ...
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


% --- Executes just before Configure_CFunc is made visible.
function Configure_CFunc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Configure_CFunc (see VARARGIN)

clc
%Setting the defaults

handles.CFuncData.Fname=[];
handles.CFuncData.Fparam=[];
handles.output={handles.CFuncData.Fname, handles.CFuncData.Fparam};


guidata(hObject,handles);

[Args]=ParseInputs(varargin{:});

    set(handles.CFunc,'visible','on');
    set(handles.FParamList,'visible','off');

    % Make the GUI modal
    set(handles.CFunc,'WindowStyle','modal')

    % UIWAIT makes Configure_CFunc wait for user response (see UIRESUME)
    uiwait(handles.CFunc);


% --- Outputs from this function are returned to the command line.
function varargout = Configure_CFunc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.CFunc);


function Fname_Callback(hObject, eventdata, handles)
% hObject    handle to Fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fname as text
%        str2double(get(hObject,'String')) returns contents of Fname as a double
EnteredString=get(hObject,'String');

%Validate the EnteredString to see if it is a valid file

if(exist(EnteredString,'file'))
    %It is a valid file
    handles.CFuncData.Fname=EnteredString;
    guidata(handles.CFunc,handles);
end

% --- Executes during object creation, after setting all properties.
function Fname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Fparam_Callback(hObject, eventdata, handles)
% hObject    handle to Fparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fparam as text
%        str2double(get(hObject,'String')) returns contents of Fparam as a double
temp=str2num(get(hObject,'String'));
if(0~=temp)
    set(handles.FParamList,'visible','on');
    set(handles.FParamListTable,'Data',cell(temp,1));
    guidata(handles.CFunc,handles);
end


% --- Executes during object creation, after setting all properties.
function Fparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fparam (see GCBO)
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
guidata(handles.CFunc,handles);
uiresume(handles.CFunc);

% --- Executes on button press in Help.
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
HelpPath=which('UIFilters.html');

web([HelpPath '#CFunc'] ,'-browser');

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=[];
guidata(handles.CFunc,handles);
uiresume(handles.CFunc);

% --- Executes when user attempts to close CFunc.
function CFunc_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to CFunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(handles.CFunc, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.output=[];
    guidata(handles.CFunc,handles);
    uiresume(handles.CFunc);
else
    % The GUI is no longer waiting, just close it
    delete(handles.CFunc);
end


% --- Executes on key press over CFunc with no controls selected.
function CFunc_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to CFunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output=[];


    % Update handles structure
    guidata(handles.CFunc,handles);

    uiresume(handles.CFunc);
end

if isequal(get(hObject,'CurrentKey'),'return')
    try
        handles.output=CheckIfDone(handles);
    catch RetErr

        errordlg(RetError.message);
        return;
    end
    guidata(handles.CFunc,handles);
    uiresume(handles.CFunc);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Output]=CheckIfDone(handles)
Output=[];
if(  (isfield(handles.CFuncData,'Fname')) && (~isempty(handles.CFuncData.Fname)) && (0~=handles.CFuncData.Fname) )
else
    %Error
    error('Please specify the number of Fname of the Gaussian filter','No number of Fname specified','modal');

end

%If we have come this far, everything must be OK

Output={[handles.CFuncData.Fname handles.CFuncData.Fparam],handles.CFuncData.SIGMA};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Filterspec]=ReturnFileFilter(FormatFile)
fid = fopen(FormatFile,'r');
Desc={};
ExtList={};
Filterspec={};
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    [t,r]=strtok(tline,',');

    ExtList{end+1}=r(2:end);
    Desc{end+1}=[t ' (' ExtList{end} ')'];
end
fclose(fid);
SupExtensions = regexprep(ExtList, ',', ';');

for i=1:numel(Desc)
    Filterspec{end+1,1}=SupExtensions{i};
    Filterspec{end,2}=Desc{i};
end
Filterspec{end+1,1}='*.*';
Filterspec{end,2}='All files (*.*)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to parse command line arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Args]=ParseInputs(varargin)

%Default Args

    Args.Visibility='off';
    Args.mode='default';
    Args.Buffer=[];

    k=1;

    LengthArgIn=length(varargin);
    while (k <=LengthArgIn )
        arg = varargin{k};

        % Objective tab parameters
        if(isfield(arg, 'Visibility'))
            Args.Visibility=arg.Visibility;
        end
        if(isfield(arg, 'mode'))
            Args.mode=arg.mode;
        end

        %Correlation tab parameters
        if(isfield(arg, 'Buffer'))
            Args.Buffer=arg.Buffer;
        end

        k=k+1;
    end %while(k<=LengthArgIn)

%end %ParseInputs(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
