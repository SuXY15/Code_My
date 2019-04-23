%% load xlsfile
defaultfolder = '/Users/suxy/Temp';
[filename, dirname] = uigetfile('*.xlsx','Open Data File',defaultfolder);
[data_1, ~] = xlsread([dirname, filename], 1);
[data_2, ~] = xlsread([dirname, filename], 2);
[data_3, name] = xlsread([dirname, filename], 3);

%% message aquire
type = data_2(:,1);       % ������ࣺ0�� 1��
num_g = size(data,1);     % �������� number of groups
num_c = size(data,2);     % ��ί���� number of commenters
num_1 = sum(type);        % ���������
num_0 = num_g-num_1;      % ���������
name_g = name(2:end, 1);  % �������� name of group
name_c = name(1, 3:end);  % ��ί���� name of commenters

%% data normalization
data_m = handle_data(data_2(:,2:end)); % ����ˮ׼�÷ֹ�һ������
data_e = handle_data(data_3(:,2:end)); % �����ò�÷ֹ�һ������

%% total score
org_s = data_1(:,2);      % ��֯�÷�    score of organizing
edu_s = data_1(:,3);      % ��������÷� score of education
art_s = mean(data_m,2);   % ����ˮ׼�÷� score of art
eng_s = mean(data_e,2);   % �����ò�÷� score of energy
tot_s = org_s*0.3+art_s*0.4+edu_s*0.3; % �ܷ� = ��֯*30% + ����ˮ׼*40% + �������*30%

%% bestow prizes
prize = zeros(num_g, 5);  % �ۺ�, ����, ����, ��֯, ��ò
for t = [0,1]
    index = (1-t)*(1:num_0)+t*(num_0+(1:num_1));
    
    tot_i = tot_s(index); % ���ֻܷ���
    tot = -sort(-tot_i);  % �Ӵ�С����
    tot_split1 = tot_i>=tot(2);               % �ִܷ�����ڵڶ����ľ�Ϊһ�Ƚ�
    num_split1 = sum(tot_split1);             % ���һ�Ƚ������� n1
    tot_split3 = tot_i<tot(num_split1+3);     % �ܷ�С�ڵ�n1+3���ľ�Ϊ���Ƚ�
    tot_split2 = ~tot_split3 & ~tot_split1;   % ����Ϊ���Ƚ�
    prize(t*num_0+find(tot_split1)',1) = 1;
    prize(t*num_0+find(tot_split2)',1) = 2;
    prize(t*num_0+find(tot_split3)',1) = 3;
    
    art_i = art_s(index); % ����������
    art = -sort(-art_i);
    art_split = art_i>=art(2);
    prize(t*num_0+find(art_split)',2) = 1;
    
    left_g = sum(prize(index,:)>0,2)<2;
    edu_i = edu_s(index); % ����������
    edu = -sort(-edu_i);
    num_edu = 0; cut_edu = 2;
    while num_edu<2 && cut_edu<length(index)
        edu_split = left_g & art_i>=art(cut_edu);
        num_edu = sum(edu_split);
        cut_edu = cut_edu + 1;
    end
    prize(t*num_0+find(edu_split)',3) = 1;
    
    left_g = sum(prize(index,:)>0,2)<2;
    org_i = org_s(index); % ����֯����
    org = -sort(-org_i);
    num_org = 0; cut_org = 2;
    while num_org<2 && cut_org<length(index)
        org_split = left_g & org_i>=art(cut_org);
        num_org = sum(org_split);
        cut_org = cut_org + 1;
    end
    prize(t*num_0+find(org_split)',4) = 1;
    
    left_g = sum(prize(index,:)>0,2)<2;
    eng_i = eng_s(index); % ����ò����
    eng = -sort(-eng_i);
    num_eng = 0; cut_eng = 2;
    while num_eng<2 && cut_eng<length(index)
        eng_split = left_g & eng_i>=art(cut_eng);
        num_eng = sum(eng_split);
        cut_eng = cut_eng + 1;
    end
    prize(t*num_0+find(eng_split)',5) = 1;
end

name_p = {'�ۺ����㽱'; "����ˮ׼��"; "���������"; "�����֯��"; "�����ò��"};
%% write results
for i=1:5
    xlswrite([dirname, filename], name_p{i},  2, ['C'+num_c num2str(1)]);
    xlswrite([dirname, filename], prize(:,i), 2, ['C'+num_c num2str(2)]);
end

%% data normalization
function data_o = handle_data(data_i)
    mean_c = mean(data_i);    % ��ί��־�ֵ
    std_c = std(data_i);      % ��ί��ֱ�׼��
    
    mean_m = median(mean_c);  % ��ί��־�ֵ����λ��
    std_m = median(std_c);    % ��ί��ֱ�׼�����λ��
    
    data_n = (data_i-mean_c)./std_c; % ��һ���÷� normalized data
    data_o = data_n.*std_m+mean_m;   % �����÷�
    % data_o = data_i;
end