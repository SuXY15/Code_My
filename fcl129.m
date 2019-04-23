%% load xlsfile
defaultfolder = '/Users/suxy/Temp';
[filename, dirname] = uigetfile('*.xlsx','Open Data File',defaultfolder);
[data_1, ~] = xlsread([dirname, filename], 1);
[data_2, ~] = xlsread([dirname, filename], 2);
[data_3, name] = xlsread([dirname, filename], 3);

%% message aquire
type = data_2(:,1);       % 队伍分类：0甲 1乙
num_g = size(data,1);     % 队伍数量 number of groups
num_c = size(data,2);     % 评委数量 number of commenters
num_1 = sum(type);        % 乙组队伍数
num_0 = num_g-num_1;      % 甲组队伍数
name_g = name(2:end, 1);  % 队伍名称 name of group
name_c = name(1, 3:end);  % 评委名称 name of commenters

%% data normalization
data_m = handle_data(data_2(:,2:end)); % 艺术水准得分归一化处理
data_e = handle_data(data_3(:,2:end)); % 精神风貌得分归一化处理

%% total score
org_s = data_1(:,2);      % 组织得分    score of organizing
edu_s = data_1(:,3);      % 主题教育得分 score of education
art_s = mean(data_m,2);   % 艺术水准得分 score of art
eng_s = mean(data_e,2);   % 精神风貌得分 score of energy
tot_s = org_s*0.3+art_s*0.4+edu_s*0.3; % 总分 = 组织*30% + 艺术水准*40% + 主题教育*30%

%% bestow prizes
prize = zeros(num_g, 5);  % 综合, 艺术, 教育, 组织, 风貌
for t = [0,1]
    index = (1-t)*(1:num_0)+t*(num_0+(1:num_1));
    
    tot_i = tot_s(index); % 按总分划分
    tot = -sort(-tot_i);  % 从大到小排序
    tot_split1 = tot_i>=tot(2);               % 总分大等于于第二名的均为一等奖
    num_split1 = sum(tot_split1);             % 获得一等奖的人数 n1
    tot_split3 = tot_i<tot(num_split1+3);     % 总分小于第n1+3名的均为三等奖
    tot_split2 = ~tot_split3 & ~tot_split1;   % 其余为二等奖
    prize(t*num_0+find(tot_split1)',1) = 1;
    prize(t*num_0+find(tot_split2)',1) = 2;
    prize(t*num_0+find(tot_split3)',1) = 3;
    
    art_i = art_s(index); % 按艺术划分
    art = -sort(-art_i);
    art_split = art_i>=art(2);
    prize(t*num_0+find(art_split)',2) = 1;
    
    left_g = sum(prize(index,:)>0,2)<2;
    edu_i = edu_s(index); % 按教育划分
    edu = -sort(-edu_i);
    num_edu = 0; cut_edu = 2;
    while num_edu<2 && cut_edu<length(index)
        edu_split = left_g & art_i>=art(cut_edu);
        num_edu = sum(edu_split);
        cut_edu = cut_edu + 1;
    end
    prize(t*num_0+find(edu_split)',3) = 1;
    
    left_g = sum(prize(index,:)>0,2)<2;
    org_i = org_s(index); % 按组织划分
    org = -sort(-org_i);
    num_org = 0; cut_org = 2;
    while num_org<2 && cut_org<length(index)
        org_split = left_g & org_i>=art(cut_org);
        num_org = sum(org_split);
        cut_org = cut_org + 1;
    end
    prize(t*num_0+find(org_split)',4) = 1;
    
    left_g = sum(prize(index,:)>0,2)<2;
    eng_i = eng_s(index); % 按风貌划分
    eng = -sort(-eng_i);
    num_eng = 0; cut_eng = 2;
    while num_eng<2 && cut_eng<length(index)
        eng_split = left_g & eng_i>=art(cut_eng);
        num_eng = sum(eng_split);
        cut_eng = cut_eng + 1;
    end
    prize(t*num_0+find(eng_split)',5) = 1;
end

name_p = {'综合优秀奖'; "艺术水准奖"; "主题教育奖"; "最佳组织奖"; "精神风貌奖"};
%% write results
for i=1:5
    xlswrite([dirname, filename], name_p{i},  2, ['C'+num_c num2str(1)]);
    xlswrite([dirname, filename], prize(:,i), 2, ['C'+num_c num2str(2)]);
end

%% data normalization
function data_o = handle_data(data_i)
    mean_c = mean(data_i);    % 评委打分均值
    std_c = std(data_i);      % 评委打分标准差
    
    mean_m = median(mean_c);  % 评委打分均值的中位数
    std_m = median(std_c);    % 评委打分标准差的中位数
    
    data_n = (data_i-mean_c)./std_c; % 归一化得分 normalized data
    data_o = data_n.*std_m+mean_m;   % 处理后得分
    % data_o = data_i;
end