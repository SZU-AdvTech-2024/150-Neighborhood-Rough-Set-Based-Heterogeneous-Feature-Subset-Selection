 function PosSet = getPosSet(dataArray,lammda)
% 以邻域粗糙集算法的方式获取下近似
% 输入dataArray为包含决策属性的数据样本，最后一列为决策属性
% lammda为邻域半径集合计算时候的参数 delta=std（data）/lammda
% lammda 注意！在这里计算的lammda和胡清华程序的lammda有区别
% 这里lammda取值尽量在0.5~1.5之间，如果太大，则不能输出正常结果，如果太小，则程序报错
% 如果数据内包含的样本数比较多（几十以上），则调大lammda=2~4
% 输出的PosSet为正域集合
% made by JieYU

[m,n]=size(dataArray); % m为样本数 n为属性个数(最后一列为决策属性)

%% 这里也可能有问题
% 筛选结果样本
% 参数
% return
% 正域理解

% if m<3 && n<3
%     disp('输入的决策系统行列个数不得小于3个！');
%     dataArray;
%     return;
% end
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 首先对数据进行归一化
% 如果这里样本比较少（比如在局部区域内只有自己单独一个样本的话，dataArray求出来就会出现NaN，而后续涉及NaN的逻辑运算结果都为0，即选不到特征）
for j=1:n-1
    amin=min(dataArray(:,j));
    amax=max(dataArray(:,j));
    for i=1:m
        dataArray(i,j)=(dataArray(i,j)-amin)./(amax-amin);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 计算邻域半径

%% 这里也可能有问题
% a = std(dataArray);
% b = std(dataArray)/lammda;
delta = lammda;
% delta=std(dataArray)/lammda;
%%

condiAtt=dataArray(:,1:n-1);
decsAtt=dataArray(:,n);
NbrSet=[];
Nbr_tmp=[];
PosSet_tmp=[];
flag2=1;

%%%%%%%%%%%%%%%%% 计算所有条件属性的下近似集合(邻域集合)
for i=1:m
   Nbr_tmp=[];
   for j=1:m
       flag1=1;
       dist=abs(condiAtt(i,1)-condiAtt(j,1));
       % delta = NaN，这里的逻辑运算结果为0，所以特征都没有选中
       if dist<=delta
           for k=2:n-1 % 其他属性的遍历判断
              dist_tmp = abs(condiAtt(i,k)-condiAtt(j,k));
              if dist_tmp<=delta
                  flag1=1; % 是否写入邻域集合的判断标记 1可以写入 0不可以写入
              else
                  flag1=0;
                  break
              end
           end
           if flag1==1 %可以写入邻域集合 即得到了下近似的集合
              Nbr_tmp=[Nbr_tmp,j]; % 得到的下近似集合
              flag1=0;
           end
       end
   end
   NbrSet(i,(1:length(Nbr_tmp)))=Nbr_tmp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 计算决策属性的划分情况
for p=1:m
    NbrD_tmp=[]; %清空
   for q=1:m
      if decsAtt(p,1)==decsAtt(q,1)
          NbrD_tmp=[NbrD_tmp,q];
      end
   end
   NbrD_Set(p,(1:length(NbrD_tmp)))=NbrD_tmp;
end


%%%%%%%%%%%%%%%%%%%%%%%%%% 求积极域（正域)
for r=1:m
    tmp=NbrSet(r,:); %取出第r行的下近似集合（可能包含0数字）
    for t=1:length(tmp)
        if tmp(1,t)~=0 % 排除为0的情况
            sign=ismember(tmp(1,t),NbrD_Set(r,:));
        end
        if sign==1 %是其中的元素
            flag2=1;
        else
            flag2=0;
            break
        end
    end
    if flag2==1
        PosSet_tmp(r,(1:length(tmp)))=tmp; %存放积极域
    end
end

%%%%%%%%%%%%%%%%%%%%%%% 判断得出的正域形状是否与数据原本形状相等，不相等则填充
[mm,nn]=size(PosSet_tmp);
if mm ~= m
    PosSet_tmp(m,:)=0;
end

%%%%%%%%%%%%%%%%%%%%%%% 整理得出正域
PosSet=[];% 存放正域集合
for s=1:length(PosSet_tmp) % 遍历临时得到的正域
   posTmp=PosSet_tmp(s,:);
   flag3=1;
   for z=1:length(posTmp)
       flag3=1;
       if posTmp(1,z)~=0
           %判断当前元素是否已经存在在正域内
          flag3=ismember(posTmp(1,z),PosSet);  
       end
       if flag3==0
           PosSet=[PosSet,posTmp(1,z)];
       end
   end
end



