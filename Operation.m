classdef Operation
    %飛行機に対する運用を表すData Class．
    properties
        AircraftType {mustBeText} = "",
        Route {mustBeText} = "",

        a0d,
        a00,
        add,
        ad0,
        a1d,
        a10,
        a2d,
        a20,

        h1_cdo,
        h2_cdo,
        h_init
    end
end