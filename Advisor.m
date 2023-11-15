classdef Advisor
    properties
        operation_s;
        d_s;

        name_s;
        color_s;

        N {mustBeInteger};
        D {mustBeInteger};

        a0_s;
        ad_s;
        a1_s;
        a2_s;
    end
    methods
        function a = Advisor(operation_s, d_s)
            a.operation_s = operation_s;
            a.d_s = d_s;
            
            a.N = length(a.operation_s);
            assert(a.N==length(a.d_s));
            a.D = a.N-1;

            a.name_s = [];
            for i=1:a.N
                o = a.operation_s(i);
                name = o.AircraftType+"/"+o.Route;
                a.name_s = [a.name_s name];
            end
            a.color_s = lines(a.N);


            a.a0_s = zeros(a.N,1);
            a.ad_s = zeros(a.N,1);
            a.a1_s = zeros(a.N,1);
            a.a2_s = zeros(a.N,1);
            for i=1:a.N
                o = a.operation_s(i);
                d = a.d_s(i);
                [a0,ad,a1,a2] = get_a0d12(o,d);
                a.a0_s(i) = a0; a.ad_s(i)=ad; a.a1_s(i)=a1; a.a2_s(i)=a2;
            end
        end

        function [t_cdo_s,dt_cdo_s] = calc_cdo_policy(a)
            t_cdo_s = zeros(a.N,1);
            for i = 1:a.N
                o = a.operation_s(i);
                t_cdo_s(i) = get_pred_arrivaltime( ...
                    a.a0_s(i), a.ad_s(i), a.a1_s(i), a.a2_s(i),...
                    o.h_init, o.h1_cdo, o.h2_cdo ...
                );
            end
            dt_cdo_s = diff(t_cdo_s);
        end

        function r = optimize_u(a,c)
            arguments
                a Advisor
                c AdditionalConstraints
            end
            global legal_tmin legal_h2_max legal_h2_min legal_h1_min VERTICAL_SCALE GROUND_SCALE
            %% 状態 x の仕様．
            % x = [ Δh1(1) Δh2(1) ... Δh1(N) Δh2(N) Δt(1) ... Δt(N) ]
            % Δh1(i) フライトiのIP1における高度の，CDO高度(.h1_cdo)に対する差分 = x(2i-1)
            % Δh2(i) フライトiのIP2における高度の，CDO高度(.h2_cdo)に対する差分 = x(2i)
            % Δt(i)  フライトiの予想到着時間の，予想CDO到着時間(that)に対する差分 = x(2N+i)
            dim_x = 2*a.N + a.N;
            offset_deltat_index = 2*a.N;

            %% 等式制約．
            Aeq = zeros(a.N,dim_x);
            beq = zeros(a.N,1);
            for i =1:a.N
                % 高度の変更が予想到着時間の変化に反映されること．
                % a1 Δh1 + a2 Δh2 - Δt = 0
                Aeq_newrow = zeros(1,dim_x);
            
                Aeq_newrow(2*i-1) = a.a1_s(i);
                Aeq_newrow(2*i) = a.a2_s(i);
                Aeq_newrow(offset_deltat_index + i) = -1;
            
                Aeq(i,:) = Aeq_newrow;
            end
            %% 不等式制約．
            [that_s, ~] = a.calc_cdo_policy;
            Aiq = zeros(a.D,dim_x);
            biq = zeros(a.D,1);
            for i=1:a.D
                % 自分とその次のフライトの予想到着時間が tmin 以上離れていること．
                % (that(i+1)+Δt(i+1)) - (that(i)+Δt(i)) >= tmin
                Aiq_newrow = zeros(1,dim_x);
            
                Aiq_newrow(offset_deltat_index + i) = 1;
                Aiq_newrow(offset_deltat_index + i+1) = -1;
                Aiq(i,:) = Aiq_newrow;
            
                tmin = legal_tmin + c.deltatmin_s(i);% 予想到着時間の差の追加
                b = -that_s(i)+that_s(i+1)-tmin;
                biq(i) = b;
            end

            %% 上限下限．
            ub_deltah = zeros(2*a.N,1);
            lb_deltah = zeros(2*a.N,1); 
            
            for i=1:a.N
                % IP1とIP2での高度に対する上限下限．
                o = a.operation_s(i);
                h1_max = round(o.h_init*VERTICAL_SCALE,2)/VERTICAL_SCALE + c.delta_h1_max_s(i); %何故丸め処理をするのか？
                h2_max = legal_h2_max + c.delta_h2_max_s(i);
                h1_min = legal_h1_min + c.delta_h1_min_s(i);
                h2_min = legal_h2_min + c.delta_h2_min_s(i);
                % IP1/2高度の上限下限の追加
                ub_deltah(2*i-1) = VERTICAL_SCALE*(h1_max - o.h1_cdo);
                ub_deltah(2*i) = VERTICAL_SCALE*(h2_max - o.h2_cdo);
                lb_deltah(2*i-1) = VERTICAL_SCALE*(h1_min - o.h1_cdo);
                lb_deltah(2*i) = VERTICAL_SCALE*(h2_min - o.h2_cdo);
            end
            
            ub_deltat = Inf*ones(a.N,1); lb_daltat = -Inf*ones(a.N,1);
            ub = [ub_deltah; ub_deltat];
            lb = [lb_deltah; lb_daltat];

            %% 目的関数と最適化．
            objective_fun = @(x) ...
                0.1*norm(x(1:offset_deltat_index));
            x0 = zeros(dim_x,1);
            options = optimoptions('fmincon',...
                Algorithm='sqp', ...
                ConstraintTolerance=1e-12, ...
                MaxFunctionEvaluations=1e4 ...
            );
            [x_opt,fval] = fmincon(objective_fun,x0, ...
                Aiq,biq,Aeq,beq,lb,ub,[],options);

            %% 結果．
            t_opt_s = zeros(a.N,1);
            h1_s = zeros(a.N,1);
            h2_s = zeros(a.N,1);
            for i=1:a.N
                o = a.operation_s(i);
                h1 = x_opt(2*i-1)/VERTICAL_SCALE+o.h1_cdo;
                h1_s(i) = h1;
            
                h2 = x_opt(2*i)/VERTICAL_SCALE+o.h2_cdo;
                h2_s(i) = h2;
                
                t = that_s(i)+x_opt(offset_deltat_index+i);
                t_opt_s(i) = t;
            end
            dt_opt_s = diff(t_opt_s);

            r = struct;
            r.h1_s = h1_s; r.h2_s = h2_s;
            r.Aeq = Aeq; r.beq = beq;
            r.Aiq = Aiq; r.biq = biq;
            r.ub = ub; r.lb = lb;
            r.x_opt = x_opt;
            r.t_opt_s = t_opt_s; r.dt_opt_s = dt_opt_s;
            r.fval = fval;
        end
    end
end