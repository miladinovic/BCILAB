function [EEG data] = medicon2eeglab(inputPath)
try
load([inputPath '/trainData.mat'])
catch
    error("File you provided does not exist. If you are not please download dataset from https://www.medicon2019.org/scientific-challenge/ and place it under the folder userdata/medicon_2019_challange");
end
trainEvents=hlp_importfile([inputPath '/trainEvents.txt'],1,1600);
trainTargets=hlp_importfile([inputPath '/trainTargets.txt'],1,1600);
data=reshape(trainData,8,1600*350);


convMarkers=trainEvents+trainTargets*10;


k=1;
j=1;
l=1;
for i=1:560000
    
    if(k==1)
        mrk(j).type='ST';
        mrk(j).latency=i;
        mrk(j).duration=1;
        mrk(j).urevent=j;
        j=j+1;
        mrk(j).type=num2str(convMarkers(l));
        l=l+1;
        mrk(j).latency=i+51;
        mrk(j).duration=1;
        mrk(j).urevent=j;
        j=j+1;
        
    end
    k=k+1;
    
    if(k==351)
        k=1;
    end
    
        
end
EEG = pop_importdata('dataformat','array','nbchan',0,'data',data,'srate',256,'pnts',0,'xmin',0);
EEG.event=mrk;

EEG.chanlocs(1).labels = 'C3';
EEG.chanlocs(2).labels ='Cz'; 
EEG.chanlocs(3).labels ='C4'; 
EEG.chanlocs(4).labels ='CPz'; 
EEG.chanlocs(5).labels ='P3'; 
EEG.chanlocs(6).labels ='Pz';  
EEG.chanlocs(7).labels ='P4';  
EEG.chanlocs(8).labels ='POz'; 


end