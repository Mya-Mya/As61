function [a0,ad,a1,a2] = get_a0d12(o, d)
% 与えられた運用が与えられた残距離にいる時の4つのパラメータを生成する．
% これらのパラメータは予想到着時間の計算，等式制約に使用される．
arguments
    o Operation
    d {mustBeNumeric}
end
global GROUND_SCALE

a0 = o.a00 + o.a0d * d;
ad = o.ad0 + GROUND_SCALE * o.add * d;
a1 = o.a10 + GROUND_SCALE * o.a1d * d;
a2 = o.a20 + GROUND_SCALE * o.a2d * d;
end

