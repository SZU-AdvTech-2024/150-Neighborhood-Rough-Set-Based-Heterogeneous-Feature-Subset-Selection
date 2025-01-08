DataPath = 'C:\Users\H3M\Desktop\Tramsport\YJS\neighborhood-rough-set-master\neighborhood-rough-set-master\'
TrainPath='';

File = dir(fullfile(DataPath,'*.mat'))
FileNames = {File.name}'

% 改个数据集
FileNames={'wine.mat'}
FileName = erase(FileNames(1),'.mat');

data = cell2mat(struct2cell(load([DataPath,FileName{1},'.mat'])))

data(:,1:end-1)
data(:,end)
indices = crossvalind('Kfold',data(:,end), 10)%10折交叉验证
acc=zeros(1,10);

resultAcc = 0;
resultFeatureSlct = [];
resDelta = 0;
totalAcc = [];
for delta = 0.02:0.02:0.4

    for i=1:10
        test = (indices == i);
        train = ~test;
        Train = data(train, :);
        Test = data(test, :);
        
        TrainLables=Train(:,end); 
        TestLables=Test(:,end);
        
        Train=Train(:,1:end-1);
        Test=Test(:,1:end-1);
        [N,M] = size(Train);
    
        
            % 222
            [red_dpd,feature_slct] = getFeature(Train,TrainLables,delta);
            
            % 假设X是特征矩阵，Y是标签向量
            Train(:,feature_slct);
            TrainLables;
            % 训练SVM模型
            svmModel = fitcecoc(Train(:,feature_slct), TrainLables);
        
            % 预测
            Y_pred = predict(svmModel, Test(:,feature_slct));
        
            % 计算精度
            accuracy = sum(Y_pred == TestLables) / length(TestLables);
            fprintf('SVM分类精度: %.2f%%\n', accuracy * 100);
            
            acc(1,i)=accuracy;
        
    end
    MeanAcc = mean(acc)
    totalAcc = [totalAcc;MeanAcc];
    if MeanAcc > resultAcc
        resultAcc = MeanAcc;
        resultFeatureSlct = feature_slct;
        resDelta = delta;
    end
     
end
resultAcc
resultFeatureSlct
resDelta
meanACC = mean(totalAcc)
stdACC = std(totalAcc)
