function exitCallback(~,~,videoSrc,hFig)

        % Close the video file
        release(videoSrc);
        % Close the figure window
        close(hFig);
    end

