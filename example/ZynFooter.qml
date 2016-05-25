Widget {
    id: foot
    function class_name() {"ZynFooter"}
    Indent {
        id: wheelwell
        x: 0.010*foot.w
        y: 0.15*foot.h
        w: 0.017*foot.w
        h: (1-2*0.15)*foot.h
        ModWheel {
            label: "wheel"
            x: 0.1*wheelwell.w
            y: 0.1*wheelwell.h
            w: 0.8*wheelwell.w
            h: 0.8*wheelwell.h
        }
    }

    Keyboard {
        id: key
        x: 0.032*foot.w
        w: 0.536*foot.w
        y: foot.h*0.10
        h: foot.h*0.8
    }
}
