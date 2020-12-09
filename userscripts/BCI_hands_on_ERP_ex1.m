% This tutorial demonstrates the use of BCILAB to learn basic predictive models using 
% ERP-like phenomena, here operating on the error negativity (in a Flanker task).
%
% In this data set, there are two different markers for the correct response ('S101' and 'S102',
% the first for left-hand responses, and the second for right-hand responses), as well as and 
% two different markers for incorrect responses ('S201','S202', again left/right hand).

% define markers; here, two groups of markers are being defined; the first group represents class 1
% (correct responses), and the second group represents class 2 (incorrect responses).
mrks = {{'S101','S102'},{'S201','S202'}};
mrks = {'2559.9609', '5120'};
% define ERP windows of interest; here, 7 consecutive windows of 50ms length each are being
% specified, starting from 250ms after the subject response
wnds = [0.25 0.3;0.3 0.35;0.35 0.4; 0.4 0.45;0.45 0.5;0.5 0.55;0.55 0.6];

% define load training data (BrainVision format)
%traindata = io_loadset('bcilab:/userdata/tutorial/flanker_task/12-08-002_ERN.vhdr');
traindata = io_loadset('bcilab:/userdata/Megan_M128_AEP/megan aep 2.edf');
% define approach
myapproach = {'Windowmeans' 'SignalProcessing', {'Resampling','off','EpochExtraction',[-0.2 0.8],'SpectralSelection',[0.1 15]}, 'Prediction',{'FeatureExtraction',{'TimeWindows',wnds}}};

%learn model 
[trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',mrks);
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

% visualize results
bci_visualize(lastmodel)