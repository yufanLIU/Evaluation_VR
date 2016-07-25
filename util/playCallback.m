function playCallback(hObject,~,videoSrc,hAxes)
       try
            % Check the status of play button
            isTextStart = strcmp(get(hObject,'string'),'Start');
            isTextCont  = strcmp(get(hObject,'string'),'Continue');
            if isTextStart
               % Two cases: (1) starting first time, or (2) restarting
               % Start from first frame
               if isDone(videoSrc)
                  reset(videoSrc);
               end
            end
            if (isTextStart || isTextCont)
                set(hObject,'string','Pause');
            else
                set(hObject,'string','Continue');
            end

            % Rotate input video frame and display original and rotated
            % frames on figure
            while strcmp(get(hObject,'string'),'Pause') && ~isDone(videoSrc)
                % Get input video frame and rotated frame
                [frame] = getAndProcessFrame(videoSrc);
                % Display input video frame on axis
                showFrameOnAxis(hAxes.axis, frame);
            end

            % When video reaches the end of file, display "Start" on the
            % play button.
            if isDone(videoSrc)
               set(hObject,'string','Start');
            end
       catch ME
           % Re-throw error message if it is not related to invalid handle
           if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
               rethrow(ME);
           end
       end
    end