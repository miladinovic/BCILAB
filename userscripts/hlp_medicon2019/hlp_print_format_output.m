function [fin_output]=hlp_print_format_output(results,app_names)

%%

[x l]=size(results);
fprintf('Number of approaches is %d\n',(l-3)/2);
fprintf('%s\n',app_names{:});
    fin_output=[];
    
     fprintf("\n\n Results \n\n");

for app=1:length(app_names)
    
    sel_APP=results(:,[1,app*2,app*2+1,end-1,end]);
    
    Cond=sel_APP(:,2)==0;
    Y=find(Cond);
    
    % remove
    sel_APP(Y,:) = [];
    
    for i=1:50
        %select susel_APP matrix for event
        C=(sel_APP(:,5)==i);
        idx=find(C);
        if(isempty(idx))
            %put a randomValue
            output(i)=randsample(1:8,1);
            continue
        end
        C=sel_APP(idx,:);
        Uniq = unique(C(:,1));
        UniqCnt=histc(C(:,1),Uniq);
        if length(UniqCnt)==1
            %if only one detected
            output(i)=C(1,1);
            continue
        end
        
        %check if apperence is uniform
        if max(UniqCnt)==1
            %take with higher prosel_APPasel_APPility
            [Prosel_APP,idxMaxProsel_APP]=max(C(:,3));
            output(i)=C(idxMaxProsel_APP,1);
            continue
        end
        
        %check the one that have most of apperacnes
        [reps,idxReps]=max(UniqCnt);
        output(i)=C(idxReps,1);
        continue
    end
    
    fin_output=[fin_output; output];
    fprintf("%s ",app_names{app});fprintf("%d ",output);fprintf("\n");
    
    
    
    
end





end

