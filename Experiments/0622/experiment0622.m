inst = setup_instance1;
dinit_s = inst.dinit_s;
N = inst.N;
operation_s = inst.operation_s;

%% TURN0 制御無し
a = Advisor(operation_s,dinit_s);
c = AdditionalConstraints(N);
[t_cdo_s,dt_cdo_s] = a.calc_cdo_policy;

%% TURN0 での入力
h1_s_0 = zeros(N,1);
h2_s_0 = zeros(N,1);
for i=1:N
    h1_s_0(i) = a.operation_s(i).h1_cdo;
    h2_s_0(i) = a.operation_s(i).h2_cdo;
end

%% TURN1 プロンプト無し
r1 = a.optimize_u(c);
draw_optimize_result2("1",a,c,r1,[])

%% TURN2
p2 = "increase the gap between the flight 6 and the previous one";
c2 = Interpreter1(p2,c)
r2 = a.optimize_u(c2);
draw_optimize_result2("2",a,c2,r2,r1);

%% TURN3
p3 = "lower the max height of ip1 on the flight 1";
c3 = Interpreter1(p3,c2)
r3 = a.optimize_u(c3);
draw_optimize_result2("3",a,c3,r3,r2);

%% TURN4
p3 = "lower the max height of ip1 on the flight 1";
c4 = Interpreter1(p3,c3);
r4 = a.optimize_u(c4);
draw_optimize_result2("4",a,c4,r4,r3);

%% ログを出力する

% (i,j)はi番目のフライトのTURN j
h1_table = [h1_s_0 r1.h1_s r2.h1_s r3.h1_s r4.h1_s];
h2_table = [h2_s_0 r1.h2_s r2.h2_s r3.h2_s r4.h2_s];
dt_table = [dt_cdo_s r1.dt_opt_s r2.dt_opt_s r3.dt_opt_s r4.dt_opt_s];

log_table = [
    h1_table
    h2_table
    dt_table
]
%%
I = 1:N;
I_str = arrayfun(@(x)string(x),I)
turn_s = 0:4;
%% 各フライトへの入力の変化を見る
figure
hold on
for i=1:N
    plot(turn_s,h2_table(i,:), ...
        DisplayName=num2str(i)+":"+a.name_s(i), ...
        Color=a.color_s(i,:),LineStyle=":",Marker="o", ...
        LineWidth=2,MarkerSize=9 ...
    )
end
xlabel("TURN#");ylabel("Alt [ft]")
xticks(turn_s);xticklabels(turn_s)
legend
hold off