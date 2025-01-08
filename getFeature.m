function [red_dpd,feature_slct] = getFeature(X_All,Y,delta)
    X = [X_All,Y];
    %X=X.standdata;
    % m为样本数、n为属性数
    [m,n]=size(X);
    
    sig_ctrl=0.01; %重要度下限的控制参数，取接近0的数
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    feature_slct=[]; % 最终属性选择的集合
    feature_lft=(1:n-1); % 条件属性
    number=(1:n-1); % 条件属性
    condiAtt=X(:,1:n-1); % 条件属性集合
    %decsAtt=Y'; % 决策属性集合
    NbrSet=[]; % 存放邻域集合
    Nbr_tmp=[];% 存放每个样本（临时）的邻域集合

    red=[]; % 初始化约简属性子集，初始值为空
    red_dpd=0; % 初始化约简集合的依赖度，初始值为0

    num_cur=0;
    array_cur=[];
    while num_cur<n-1
        if num_cur==0
            array_cur=[];
        else
            array_cur(:,num_cur)=X(:,feature_slct(num_cur));%将新选中的属性对应数据列加到原有表中
        end
        %%%%%%%%%%%%%%%%%%
        %%%%  对每个子属性计算依赖度
        %%%%%%%%%%%%%%%%%%%
        
        %%
        % 这里就直接最大值为0了 局部区域内只有一个样本
        % 因为在getPosSet里面出现了NaN 涉及NaN的逻辑运算结果通常为0
        for i=1:length(feature_lft)  % feature_lft 属性的个数
            array_tmp=array_cur;
            % 选出子属性，如果已经确定了一个约简，则将其与其他属性一起合成子属性
            array_tmp(:,[num_cur+1,num_cur+2])=X(:,[feature_lft(i),n]);% 选出第i个属性与决策属性  先通过feature
            % 此时得到的决策系统为去掉了指定的条件属性的新的决策系统
            PosSet_Att=getPosSet(array_tmp,delta); %求正域用这个
            % 计算依赖度
            dpd_Att_tmp=length(PosSet_Att)/m; % 计算每个属性的依赖度
            dpd_Atti(i,1)=dpd_Att_tmp; % 将每个属性的依赖度存储起来,共g行
            % 计算重要度
            sig_Att_tmp=dpd_Att_tmp-red_dpd; % 计算每个属性的重要度，增加法，不是删除法
            sig_Att(i,1)=sig_Att_tmp; % 将每个属性的重要度存储起来，共g行
        end
        %%
        
        % 选择重要度最大的一个，和他的索引
        [max_sig,max_sequence1]=max(sig_Att);%max_dpd表示每列最大的值，max_sequence1表示该列最大值所在的列
        red_dpd=red_dpd+max_sig;
        sig_Att=[]; % 清空重要度数组
        % 判断，如果最大的重要度为0的话，结束约简算法
        if max_sig==0
            break
        end
        feature_slct(num_cur+1)=feature_lft(max_sequence1);    % 最终属性选择的集合
        feature_lft(max_sequence1)=[]; % 把max_sequence1索引删了

        num_cur=num_cur+1;
    end
    best_member = ismember(number,feature_slct);
    % sum(best_member) == 0 就可以输出X_All 看一下最后是什么原因导致的
    
    number;
    feature_slct;
    ismember(number,feature_slct);
end
