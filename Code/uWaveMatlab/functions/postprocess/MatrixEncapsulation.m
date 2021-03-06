function [ distanceMatrix ] = MatrixEncapsulation(folderPath, cm )
% This function takes the path of parent folder (folderPath) where all the
% datasets for each days are & the cell matrix which contains all the
% calibrated datasets. It loops through all the datasets of different
% people, days, gestureTypes, and attempts, and then outputs the distance
% matrix which contains all the distances between calibrated dataset and
% attempted dataset per gesture.
%
%folderPath: should be ~/Data/gestures/
%cm: cell matrix
%distanceMatrix: Person(3) x Day(7) x GestureType(17) x Attempt(10)

    % create and fill the output matrix with 0s
    distanceMatrix = nan(3,7,17,10);
    % get the filenames for gestures
    fileMat=GetFileNames(); 
    % usernames
    user = {'Gino', 'Joe', 'Henry'};
    tic;
    
    % whose datasets
    for userInd = 1:3
        display(['User:' num2str(userInd)]);
       % loop through dataset for 7 days (from 4/7 - 4/13, add it to 7-13 when we load file)
       for date = 1:7
           if date == 1 && userInd ==1 
               continue;
           end
           display(['Date:' num2str(date)]);
            % how many gestures
            for gesInd = 1:17
                display(['Ges:' num2str(gesInd)]);
                % attempts# per gesture
                for attempts = 1:10
                    % load attempts data from mat file
                    loadFile=[folderPath '4-' num2str(date+6) '/' user{userInd} '_' fileMat{gesInd} '_' num2str(attempts) '.mat'];
                    matio = matfile(loadFile);
                    try
                        accelerationData = matio.a;                    
                    catch
                        distanceMatrix(userInd,date,gesInd,attempts) = NaN;
                        continue;
                    end

                    % load acceleration data matrix
                    % quantization
                    if userInd == 1
                        [~, accelerationData] = uWaveQuant (matio.t, accelerationData); 
                    end
                    % leveling
                    accLeveled = uWaveLeveling(accelerationData);
                    % calculate the distance between attempts and calibrated using DTW
                    % cm{gesInd,1} = time series of gesInd
                    [Dist, ~, ~, ~] = dtw (cm{gesInd,1}, accLeveled);
                    % fill the distance to the output matrix
                    distanceMatrix(userInd,date,gesInd,attempts) = Dist;
                end
                toc;
            end
        end
    end
    % finish processing
    % save the output matrix to the file
    outputFile = 'distanceMatrix.mat';
    save(outputFile,'distanceMatrix');

end

