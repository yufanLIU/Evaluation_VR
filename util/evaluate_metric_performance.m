%=====================================================================
% File: evaluate_metric_performance.m
% Original code written by Rony Ferzli, IVU Lab (http://ivulab.asu.edu)
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


function [MOSp,rnonlinear, rspear, routlier,rmse,mae] = evaluate_metric_performance(EvalMetricPerformParam)
%Function that evaluates the performance of the objective metrics.

N = length(EvalMetricPerformParam.MOSScores);
meanx = mean(EvalMetricPerformParam.OBJScore);
meany = mean(EvalMetricPerformParam.MOSScores);
numtest = sum((EvalMetricPerformParam.OBJScore-meanx).*(EvalMetricPerformParam.MOSScores-meany));
dentest = sqrt(sum((EvalMetricPerformParam.OBJScore-meanx).^2))*sqrt(sum((EvalMetricPerformParam.MOSScores-meany).^2));
r = numtest/dentest;

% Non-linear Pearson
options = optimset('MaxIter', 2000, 'TolFun', 1e-6,'Display','off');

switch(EvalMetricPerformParam.LogisticChoice)
    case 'default'
        logistic_fun=@DefaultLogisticFn;
        InitialBeta=[max(EvalMetricPerformParam.MOSScores) min(EvalMetricPerformParam.MOSScores) mean(EvalMetricPerformParam.OBJScore) 1];

    case 'none'
    logistic_fun=[];
    case 'user'
        logistic_fun=str2func(EvalMetricPerformParam.ModelFn);
        if(isempty(EvalMetricPerformParam.ModelFnVar))
            InitialBeta=[];
        else
            InitialBeta=EvalMetricPerformParam.ModelFnVar;
        end
        
end %switch(EvalMetricPerformParam.LogisticChoice)

%Perform curve fitting only if logistic function has been specified
if(~isempty(logistic_fun))
    [beta,r,J] = nlinfit(EvalMetricPerformParam.OBJScore,EvalMetricPerformParam.MOSScores,logistic_fun,InitialBeta,options);
    MOSp=logistic_fun(beta,EvalMetricPerformParam.OBJScore);

else
    MOSp=EvalMetricPerformParam.OBJScore;

end
x = MOSp;

meanx = mean(x);
meany = mean(EvalMetricPerformParam.MOSScores);
numtest = sum((x-meanx).*(EvalMetricPerformParam.MOSScores-meany));
dentest = sqrt(sum((x-meanx).^2))*sqrt(sum((EvalMetricPerformParam.MOSScores-meany).^2));
rnonlinear = numtest/dentest;

% Spearman
rspear = spear(x,EvalMetricPerformParam.MOSScores);


% Outlier

%Check if Subjective scores have been specified

if(isempty(EvalMetricPerformParam.SubjectiveScores))
     routlier=0;
else
    %This might be STD or subject score data
    if(1==EvalMetricPerformParam.IsSTD)
        %This is std.
        stddiff=EvalMetricPerformParam.SubjectiveScores;
    else
        diffOS = EvalMetricPerformParam.SubjectiveScores;
        [MM, NN] = size(diffOS);

        xrep = repmat(MOSp,1,NN);
        diffOS = diffOS - xrep ;
        stddiff = std(diffOS,0,2);
    end

    outlier = 0;
    OutlierIndices=zeros(1,N);
    for n=1:N
        if( abs(MOSp(n)-EvalMetricPerformParam.MOSScores(n)) > 2*stddiff(n))
            OutlierIndices(n)=1;
            outlier=outlier+1;
        end
    end
    routlier = outlier/N;

end %if(isempty(EvalMetricPerformParam.SubjectiveScores))

MOS = EvalMetricPerformParam.MOSScores;

%Root Mean Square Error
rmse = sqrt(sum((MOSp - MOS).^2)/(N));
%Mean Absolute Error
mae = sum(abs(MOSp-MOS))/(N);

%Plotting the data.

%Plotting has been embedded here itself because we have access to all the
%relevant variables here. If we have to move this into another function, we
%must figure out a clean way to pass stuff to the new function.

if((0~=EvalMetricPerformParam.PlotParams.PlotMOS) || ...
   (0~=EvalMetricPerformParam.PlotParams.PlotPrediction) || ...
   (0~=EvalMetricPerformParam.PlotParams.PlotOutlierBounds) ...
   )
    %Plotting has been enabled.

    if (0==EvalMetricPerformParam.PlotParams.PlotHandle)
        EvalMetricPerformParam.PlotParams.PlotHandle=figure;
    else
        figure(EvalMetricPerformParam.PlotParams.PlotHandle);
    end

    LegendDesc={};

    PlotTitle=['MOS Vs. ' EvalMetricPerformParam.PlotParams.MetricName];
    set(gcf,'name',PlotTitle,'NumberTitle','off');
    hold on
    if(0~=EvalMetricPerformParam.PlotParams.PlotMOS)
        %TODO figure out outliers
        switch(EvalMetricPerformParam.PlotParams.OutlierDisplay)
            case 'normal'
                plot(EvalMetricPerformParam.OBJScore,EvalMetricPerformParam.MOSScores,'b.');
                LegendDesc{end+1}='Scores';
            case 'hlight'
                plot(EvalMetricPerformParam.OBJScore,EvalMetricPerformParam.MOSScores,'b.');
                LegendDesc{end+1}='Scores';

                if(exist('OutlierIndices','var'))
                   TempObjScore=EvalMetricPerformParam.OBJScore(OutlierIndices==1);
                   TempMOSScore=EvalMetricPerformParam.MOSScores(OutlierIndices==1);

                   plot(TempObjScore,TempMOSScore,'mo');
                   LegendDesc{end+1}='Outliers';

                else
                    msgbox('No raw subjective scores/ standard deviations available. Cannot highlight outliers','No raw scores/ STDs available');
                end
            case 'hide'
                if(exist('OutlierIndices','var'))
                   TempObjScore=EvalMetricPerformParam.OBJScore;
                   TempMOSScore=EvalMetricPerformParam.MOSScores;
                   %remove the outliers
                   TempObjScore(OutlierIndices==1)=[];
                   TempMOSScore(OutlierIndices==1)=[];

                   plot(TempObjScore,TempMOSScore,'b.');
                   LegendDesc{end+1}='Scores';

                else
                    msgbox('No raw subjective scores/ standard deviations available. Cannot hide outliers','No raw scores/ STDs available');
                    plot(EvalMetricPerformParam.OBJScore,EvalMetricPerformParam.MOSScores,'b.');
                    LegendDesc{end+1}='Scores';

                end

        end %switch(EvalMetricPerformParam.PlotParams.OutlierDisplay)

    end %    if(0~=EvalMetricPerformParam.PlotParams.PlotMOS)

    [MonotonicPredictedMOS,idx]=sortrows([EvalMetricPerformParam.OBJScore,MOSp]);

    if(0~=EvalMetricPerformParam.PlotParams.PlotPrediction)
        plot(MonotonicPredictedMOS(:,1), MonotonicPredictedMOS(:,2),'g+-');
        LegendDesc{end+1}='Predicted MOS';

    end

    if((0~=EvalMetricPerformParam.PlotParams.PlotOutlierBounds) && (exist('stddiff','var')))
        %Upper bound
        plot(MonotonicPredictedMOS(:,1),(MonotonicPredictedMOS(:,2)+(2*stddiff(idx))),'r-');
        LegendDesc{end+1}='Upper bound (+/-2*STD)';

        %Lower bound
        plot(MonotonicPredictedMOS(:,1),(MonotonicPredictedMOS(:,2)-(2*stddiff(idx))),'r-');

    end

    legend(LegendDesc,'Location','NorthEastOutside');
    hold off
    title(PlotTitle);
    xlabel(EvalMetricPerformParam.PlotParams.MetricName);
    ylabel('MOS');
    if(1==EvalMetricPerformParam.PlotParams.SavePlots)
        filename=['MOS_Vs_' EvalMetricPerformParam.PlotParams.MetricName '.bmp'];
        filename=fullfile(EvalMetricPerformParam.PlotParams.PlotPath,filename);
        saveas(gcf,filename,'bmp');
    end

end %Plotting has been enabled


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function L = DefaultLogisticFn(beta,x)


L = ((beta(1) - beta(2))./(1+exp(-(x-beta(3))/abs(beta(4)))) + beta(2));

