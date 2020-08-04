function [EEG data] = medicon2eeglabTest(inputPath)


load([inputPath '/testData.mat'])
testEvents=hlp_importfile([inputPath '/testEvents.txt'],1,length(testData));
data=reshape(testData,8,length(testData)*350);



k=1;
j=1;
l=1;
for i=1:(length(testData)*350)
    
    if(k==1)
        mrk(j).type='ST';
        mrk(j).latency=i;
        mrk(j).duration=1;
        mrk(j).urevent=j;
        j=j+1;
        mrk(j).type=num2str(testEvents(l));
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