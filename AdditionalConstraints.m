classdef AdditionalConstraints
    properties
        deltatmin_s %(i)はi便目とi+1便目間の予想到着時間の差の追加分
        delta_h1_max_s {mustBeNonpositive}
        delta_h2_max_s {mustBeNonpositive}
        delta_h1_min_s {mustBeNonnegative}
        delta_h2_min_s {mustBeNonnegative}
    end
    methods
        function c = AdditionalConstraints(N)
            arguments
                N {mustBeInteger}
            end
            D = N - 1;

            c.deltatmin_s = zerovec(D);
            c.delta_h1_max_s = zerovec(N);
            c.delta_h2_max_s = zerovec(N);
            c.delta_h1_min_s = zerovec(N);
            c.delta_h2_min_s = zerovec(N);
        end
    end
end