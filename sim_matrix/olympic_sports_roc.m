function [ model_name, auc, x_out,y_out] = olympic_sports_roc( category, iter )


%load similarity matrix and labels
path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/similarities/simMatrix_',category,'.mat'];
load(['/export/home/mbautist/Desktop/workspace/cnn_similarities/datasets/OlympicSports/labels_HIWIs/labels_',category,'.mat']);
fprintf('Results at iteration %d\n', iter);

%h_main = figure;

fs = 18;
lt = 2;
legendfs = 22;
% set(h_main,'position',[0 0 750 750]);


%plot options
color = {'b+-','kd-','m+-','g-+','c-^','c-*','rs-','b.'};
model_name = {'HOG-LDA','Exemplar-SVM','Exemplar-CNN','Alexnet', 'NN-CNN','1-sample-CNN', 'CliqueCNN'};

model_idxs = setdiff(1:length(model_name),3);
model_idxs = [8];
INTERP = 'linear'

for model = model_idxs
    
    % choose different sim matrices for different models
    if model == 1
        path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/hog-lda/simMatrix_',category,'.mat']; 
    elseif model == 2
        path_simMatrix = ['/export/home/asanakoy/workspace/OlympicSports/plots/sims_',category,'_standard_esvm_HOG_no-pad.mat'];
    elseif model == 3
        path_simMatrix = ['/net/hciserver03/storage/asanakoy/workspace/OlympicSports/exemplar_cnn/similarities/fc4/sim_',category,'_ecnn_fc4_36patches_quadrantpool_zscores.mat'];
    elseif model == 4
        path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/imagenet/simMatrix_',category,'_imagenet-alexnet_iter_0_fc7.mat'];
    elseif model == 7    
        path_simMatrix = ['/net/hciserver03/storage/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/CliqueCNN_round_2/simMatrix_',category,'_cliqueCNN_round_2_',category,'_LR_0.001_M_0.9_BS_128_iter_',num2str(iter),'_fc7_prerelu.mat'];
%         path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/CliqueCNN/simMatrix_shuffle_long_jump_cliqueCNN_round_2_long_jump_LR_0.001_M_0.9_BS_128_iter_20000_fc7_prerelu.mat'];
         %path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/CliqueCNN/simMatrix_correct_',category,'_cliqueCNN_',category,'_LR_0.001_M_0.9_BS_128_iter_20000_fc7_prerelu.mat'];
    elseif model == 6    
% % % %         path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/1-sampleNN/simMatrix_',category,'_negExp_exemplar_',category,'_LR_0.001_M_0.9_BS_128_iter_1000_fc7_prerelu.mat'];
    elseif model == 5    
        path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/NN-CNN/simMatrix_',category,'_negExp_exemplarnns_',category,'_LR_0.001_M_0.9_BS_128_iter_1000_fc7_prerelu.mat'];
    elseif model == 8
%         path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/ablation_experiments/simMatrices/long_jump/simMatrix_long_jump_complete_iter_1_fc7.mat'];
%         path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/ablation_experiments/simMatrices/',category,'/simMatrixTest_',category,'_constrained_w=0.001_iter_1_fc7.mat'];
%         path_simMatrix = ['/export/home/mbautist/Desktop/PoseNet.mat'];
%         path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/CliqueCNN/simMatrix_',category,'_',category,'_LR_0.001_M_0.9_BS_128_iter_20000_fc7_prerelu.mat']
%         path_simMatrix = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/CliqueCNN/simMatrix_correct_',category,'_cliqueCNN_',category,'_LR_0.001_M_0.9_BS_128_iter_20000_fc7_prerelu.mat'];
%         path_simMatrix = ['/export/home/asanakoy/workspace01/datasets/OlympicSports/sim/tf/',category,'/simMatrix_',category,'_tf_0.1conv_1fc_iter_',num2str(iter),'_fc7_zscores.mat'];
        path_simMatrix = ['/export/home/asanakoy/workspace01/datasets/OlympicSports/sim/tf/with_bn/', category, '/simMatrix_', category, '_tf_0.1conv_1fc_with_bn_iter_', num2str(iter),'_fc7_zscores.mat']
    %PATH TO YOUR SIM

    end
    
    %compute max similarity amongs flipped and unflipped
    load(path_simMatrix)

    if exist('simMatrix','var') && exist('simMatrix_flip','var')
        simMatrix = cat(3, simMatrix, simMatrix_flip);
%         simMatrix = max(simMatrix, [], 3);
    end
    cont = 1;
    
    for i = 1:length(labels)
        %check labels with no positives or negatives
        if (length(labels(i).positives.ids)<1) || (length(labels(i).negatives.ids)<1)
            continue
        end
        
        %special case esvm
        if model == 2
            scores = sims_esvm{i};      
        else

            scores = zeros(1,length([labels(i).positives.ids labels(i).negatives.ids]));
            sims = squeeze(simMatrix(labels(i).anchor,:,:));  
            for k = 1:length([labels(i).positives.ids])
                if labels(i).positives.flipval(k)
                    scores(k) = sims(labels(i).positives.ids(k),2);
                else
                    scores(k) = sims(labels(i).positives.ids(k),1);
                end   
            end
            for j = 1:length([labels(i).negatives.ids])
                if labels(i).negatives.flipval(j)
                    scores(k+j) = sims(labels(i).negatives.ids(j),2);
                else
                    scores(k+j) = sims(labels(i).negatives.ids(j),1);
                end   
            end 
        end       
        
        
        labels_aux = [true(length(labels(i).positives.ids),1)' false(length(labels(i).negatives.ids),1)'];
        
        %skip anchors with no positive or negatives
        if length(find(labels_aux==1))<1 || length(find(labels_aux==0))<1
            continue
        end
        
        
        %roc call for each sample
        [x{cont},y{cont}] = perfcurve(labels_aux,double(scores),true);
        cont = cont +1;
    end
    
    %interpolation over all anchors
    mean_x = linspace(0, 1, 100);
    for i = 1:length(x)
        if length(x{i})<1
            continue
        end
        [new_x,idx] = unique(x{i});
        mean_y(i,:) = interp1(new_x, y{i}(idx), mean_x, INTERP);
    end
    
    %plots and outputs
    x_out(model,:) = mean_x;
    y_out(model,:) = mean(mean_y);
%     if model == 5 
%      plot(mean_x,mean(mean_y),'-*','Color',[0.44,0.44,0.44],'LineWidth',lt);   
%     else
%      plot(mean_x,mean(mean_y),color{model},'LineWidth',lt);
%     end
    auc(model) = trapz(mean_x,mean(mean_y));
    fprintf('%s %.4f\n', category, auc(model));
       
    return;
    fprintf('Model: %s, Avg AuC= %4.4f, Pctg. of data= %4.4f \n',model_name{model},auc(model),(cont-1)/length(labels));
    hold on
    clear x
    clear y
    clear new_x
    clear mean_y
    clear mean_x
end
axis tight
grid on

for i = model_idxs
   model_name{i} = [model_name{i},'(',sprintf('%4.2f',auc(i)),')'];
    
end

legend(model_name(model_idxs),'Interpreter','none', 'Location', 'SouthEast','Fontsize',legendfs);
set(gca,'FontSize',fs);
%title(category,'Interpreter','none')
saveTightFigure(gcf, [category,'.pdf']);
savefig([category,'.fig']);
close all


end
