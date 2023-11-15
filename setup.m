% 計算のスケールに関する定数
global GROUND_SCALE; GROUND_SCALE = 0.01;
global VERTICAL_SCALE; VERTICAL_SCALE = 0.01;

% シミュレーション環境に関する定数
global D2;D2 = 50; % IP2 の残距離
global D1;D1 = 100; % IP1 の残距離

%% 運用の読み込み
% operations.csvの仕様
% 各行において1列目から順に

% 機種, ルート番号, 
% a0d ... a20, ←石井スクリプトと同じ順列
% IP1におけるCDO高度, IP2におけるCDO高度, 初期位置における高度

%
opts = delimitedTextImportOptions( ...
    VariableTypes={ ...
    'char','uint8', ...
    'double','double','double','double','double','double','double','double', ...
    'double','double', 'double' ...
    }, ...
    VariableNames={
    'AircraftType', 'Route', ...
    'a0d', 'a00', 'add', 'ad0', 'a1d', 'a10', 'a2d', 'a20', ...
    'h1_cdo', 'h2_cdo', 'h_init' ...
    } ...
);
table_operations = readtable("operations.csv",opts);

%
global OPERATIONS; OPERATIONS = [];
global NUM_OPERATION; NUM_OPERATION = size(table_operations,1);
for i=1:NUM_OPERATION
    row = table_operations(i,:);
    o = Operation;

    o.AircraftType = string(row.AircraftType);
    o.Route = string(row.Route);
    o.a0d = row.a0d; o.a00 = row.a00; o.add = row.add; o.ad0 = row.ad0;
    o.a1d = row.a1d; o.a10 = row.a10; o.a2d = row.a2d; o.a20 = row.a20;
    o.h1_cdo = row.h1_cdo; o.h2_cdo = row.h2_cdo; o.h_init = row.h_init;

    OPERATIONS = [OPERATIONS; o];
end

%
operationname_s = [];
for i=1:NUM_OPERATION
    o = OPERATIONS(i);
    name = string(i)+":"+o.AircraftType+" Rt"+o.Route;
    operationname_s = [operationname_s; name];
end
%%

% 法で定められている制約定数
% フライト間の到着時刻の最小間隔
global legal_tmin; legal_tmin = 120; 
% IP1における最低高度
global legal_h1_min; legal_h1_min = 20000;
% IP2における最高高度
global legal_h2_max; legal_h2_max = 19000;
% IP2における最低高度
global legal_h2_min; legal_h2_min = 14000;

