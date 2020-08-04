% This script demonstrates how Sparse Variational Bayesian Logistic
% Regression with Automatic Relevance Determination can be used for
% classficiation of P300 BCI in children with Autism Spectrum Disorder (ASD).
%
% More information about the procedure can be found on:
%
% Miladinovic A. et al. (2020) Slow Cortical Potential BCI Classification
% Using Sparse Variational Bayesian Logistic Regression with Automatic Relevance Determination.
% In: Henriques J., Neves N., de Carvalho P. (eds) XV Mediterranean Conference on Medical and
% Biological Engineering and Computing – MEDICON 2019. MEDICON 2019. IFMBE Proceedings,
% vol 76. Springer, Cham. https://doi.org/10.1007/978-3-030-31635-8_225
% 
% Feel free to contact me if you have any difficulties and please cite the
% relevant paper if you like the demonstration!
%
% Created by Aleksandar Miladinovic, aleksandar.miladinovic@phd.units.it

% add helpers scripts for medicon 2019 dataset
addpath("hlp_medicon2019");

%check if bcilab is loaded
exist bci_visualize
if ans
    disp('BCILAB already loaded');
else
    % if not load BCILAB
    cd('..')
    bcilab;
end

% Download the dataset from
% https://www.medicon2019.org/scientific-challenge/ and place it under
% ../userdata/medicon_2019_challange

% This script only shows the demo for a single subject and on a single
% session! For the demo purposes it is enough to download a single subject
% ex: http://medicon2019.org/wp-content/uploads/sci_challenge/phase1/SBJ01.zip
% and extract the content to the ../userdata/medicon_2019_challange/
%
% medicon_2019_challange dir structure and required files
%
% medicon_2019_challange/
% -SBJ01
% --S01
% ---Test
% ---- runs_per_block.txt
% ---- testData.mat
% ---- testEvents.txt
% ---Train
% ---- trainData.mat
% ---- trainEvents.txt
% ---- trainLabels.txt
% ---- trainTargets.txt


%% convert data to EEGLAB format
trainDataPath='../userdata/medicon_2019_challange/SBJ01/S01/Train';
testDataPath='../userdata/medicon_2019_challange/SBJ01/S01/Test';
EEG_train=hlp_medicon2eeglabTrain(trainDataPath);
EEG_test=hlp_medicon2eeglabTest(testDataPath);



%% set input parameters

% time windows
wnds = [-0.15 -0.10;-0.10 -0.05;-0.05 0; 0 0.05;0.05 0.1;0.1 0.15;0.15 0.2;0.2 0.25;0.25 0.3;0.3 0.35;0.35 0.4; 0.4 0.45;0.45 0.5;0.5 0.55;0.55 0.6;0.6 0.65;0.65 0.7;0.7 0.75;0.75 0.8;0.8 0.85;0.85 0.9;0.9 0.95;0.95 1];

% epoch bounderies
tmw=[-0.15 1];

% markers
mrk={{'1','2','3','4','5','6','7','8'},{'11','12','13','14','15','16','17','18'}};

%%
%define approaches
approaches = [];

% window means Variation-bayes
approaches.wndmeans_vb = {'Windowmeans' 'SignalProcessing',{'EpochExtraction',tmw,'SpectralSelection',[0.1 15]}, ...
    'Prediction',{'FeatureExtraction',{'TimeWindows',wnds}, 'MachineLearning',{'Learner',{'logreg' 'variant','vb'}}}};

% window means Variation-bayes + Automatic Relevance Determination
approaches.wndmeans_vb_ard = {'Windowmeans' 'SignalProcessing',{'EpochExtraction',tmw,'SpectralSelection',[0.1 15]}, ...
    'Prediction',{'FeatureExtraction',{'TimeWindows',wnds}, 'MachineLearning',{'Learner',{'logreg' 'variant','vb-ard'}}}};

% window means Variation-bayes + Automatic Relevance
% Determination_iterative algorithm
approaches.wndmeans_vb_ard_iter = {'Windowmeans' 'SignalProcessing',{'EpochExtraction',tmw,'SpectralSelection',[0.1 15]}, ...
    'Prediction',{'FeatureExtraction',{'TimeWindows',wnds}, 'MachineLearning',{'Learner',{'logreg' 'variant','vb-iter'}}}};

% window means Variation-bayes with L2 optimization
approaches.wndmeans_logreg_l2 = {'Windowmeans' 'SignalProcessing',{'EpochExtraction',tmw,'SpectralSelection',[0.1 15]}, ...
    'Prediction',{'FeatureExtraction',{'TimeWindows',wnds}, 'MachineLearning',{'Learner',{'logreg' 'variant','l2'}}}};

%% build BCI models

bci_models = bci_batchtrain('StudyTag','MEDICON','Data',EEG_train','Approaches',approaches,'TargetMarkers',mrk,'ReuseExisting',false, ...
    'LoadArguments',{'type','EEG'}, 'TrainArguments',{'EvaluationScheme',{'chron',10,5}},'StoragePattern','%approach-%set.mat');
%if you experince problems running this bci_batchtrain function, restart bcilab

%% evaluate BCI models using test data

results=[];
% for each BCI model
for app = fieldnames(bci_models)'
    
    % extract model variable
    lastmodel=bci_models.(app{1}).model;
    
    % predict using EEG_test data
    [prediction,loss,teststats,targets] = bci_predict(lastmodel,EEG_test);
    
    % store prediction results in a matrix
    results=[results round(prediction{2}*prediction{3})-1 (prediction{2}*prediction{3})-1];
end

% import information about test events and runs per block
testEvents=hlp_importfile([testDataPath '/testEvents.txt'],1,length(results)+1);
runsPerBlock=hlp_importfile([testDataPath '/runs_per_block.txt'],1,1);

clear event
clear block
k=1;l=1;p=1;r=1;

% for each event produce results
for e=1:length(results)
    event(e)=k;
    l=l+1;
    if(l==8)
        l=0;
        k=k+1;
    end
    
    if(p==8*runsPerBlock)
        r=r+1; p=0;
    end
    block(e)=r;
    p=p+1;
end

% concatenate the results
%
% structure of results
%
% event : prediction_result_wndmeans_logreg_l2 :
% prediction_prob_wndmeans_logreg_l2 :
% prediction_result_wndmeans_vb_ard_iter :
% prediction_prob_wndmeans_vb_ard_iter :
% prediction_result_wndmeans_vb_ard :
% prediction_prob_wndmeans_vb_ard :
% prediction_result_wndmeans_vb :
% prediction_prob_wndmeans_vb :
% event : block
results=[testEvents(2:end) results event' block'];

% hardcoded true labels (for full information about the true labels contact the
% IFMBE Challange orginsation)
true_lab=[4	 4	1	8	3	7	1	8	4	6	8	2	1	5	5	6	2	3	7	1	7	8	8	1	7	4	8	3	2	6	7	6	4	4	7	7	7	1	5	1	1	2	6	4	7	7	5	5	5	7];

% format the results required by the challange committee 
out=hlp_print_format_output(results,fieldnames(bci_models),true_lab);


