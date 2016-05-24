Widget {
    id: radial

    function draw(vg)
    {
        #vg.path do |v|
        #    v.rect(0,0,w,h)
        #    v.fill_color(NVG.rgba(0xff,0xff,0xff,0x80))
        #    v.fill
        #end

        inner  = 0.1*[h,w].min
        outer = 0.5*[h,w].min
        cx = radial.w/2
        cy = radial.h/2
        pi = 3.14159
        start = pi/4;
        end_   = pi*3.0/4.0;
        start = 0
        end_  = -2.0*pi

        vg.path do |v|
            v.arc(cx, cy, outer, start, end_, 1);
            v.arc(cx, cy, inner, end_, start, 2);
            v.close_path
            v.fill_color(NVG.rgba(0x11,0x45,0x75,205));
            v.fill
        end

        vg.path do |v|
            outer = 0.5*0.707*[h,w].min
            v.move_to(cx-outer,cy-outer)
            v.line_to(cx+outer,cy+outer)
            v.move_to(cx+outer,cy-outer)
            v.line_to(cx-outer,cy+outer)
            v.stroke_color(NVG.rgba(0xff,0xff,0xff,0xff))
            v.stroke
        end

        textColor = NVG.rgba(0x3a,0xc5,0xec,255)

        #Draw North
        vg.font_face("bold")
        vg.font_size h/8
        vg.text_align NVG::ALIGN_CENTER | NVG::ALIGN_MIDDLE
        vg.fill_color(textColor)
        vg.text(w*0.5,h*0.2,"N")

        #Draw South
        vg.text(w*0.5,h*0.8,"S")

        #Draw East
        vg.text(w*0.8,h*0.5,"E")

        #Draw West
        vg.text(w*0.2,h*0.5,"W")
    }

    function abs(x)
    {
        if(x < 0)
            return -x
        else
            return x
        end
    }

    function onMousePress(ev) {
        puts "I got a mouse press (radial)"
        dx = ev.pos.x-radial.w/2
        dy = ev.pos.y-radial.h/2
        if(abs(dx) > abs(dy))
            #east vs west
            if(dx > 0)
                puts "East"
            else
                puts "West"
            end
        else
            #north vs south
            if(dy < 0)
                puts "North"
            else
                puts "South"
            end
        end
        rt = radial.root
        rt.ego_death radial
    }
}