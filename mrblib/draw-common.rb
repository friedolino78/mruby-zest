
module Draw
    module WaveForm
        def self.sin(vg, bb, pts=128)
            xpts = Draw::DSP::linspace(0,1,pts)
            vg.path do |v|
                vg.move_to(bb.x, bb.y+bb.h/2)
                (1...pts).each do |pt|
                    vg.line_to(bb.x+bb.w*xpts[pt],
                               bb.y+bb.h/2+bb.h/2*Math.sin(2*3.14*xpts[pt]))
                end
                v.stroke_color Theme::VisualLine
                v.stroke_width 2.0
                v.stroke
            end
        end

        def self.plot(vg, ypts, bb, do_norm=true)
            ypts = DSP::normalize(ypts) if do_norm
            xpts = Draw::DSP::linspace(0,1,ypts.length)
            vg.path do |v|
                ypos = bb.y+bb.h/2-bb.h/2*ypts[0]
                ypos = [bb.y, [ypos, bb.y+bb.h].min].max
                vg.move_to(bb.x, ypos)
                (1...ypts.length).each do |pt|
                    ypos = bb.y+bb.h/2-bb.h/2*ypts[pt]
                    ypos = [bb.y, [ypos, bb.y+bb.h].min].max
                    vg.line_to(bb.x+bb.w*xpts[pt], ypos)
                end
                v.stroke_color Theme::VisualLine
                v.stroke_width 2.0
                v.stroke
            end
        end

        def self.bar(vg, data, bb, bar_color)
            n    = data.length
            xpts = Draw::DSP::linspace(0,1,n)
            (0...n).each do |i|
                x = bb.x+xpts[i]*bb.w
                y = bb.y+bb.h
                vg.path do |v|
                    v.move_to(x, y)
                    v.line_to(x, y-bb.h*data[i])
                    v.stroke_color bar_color
                    v.stroke_width 1.0
                    v.stroke
                end
            end
        end

        def self.under_highlight(vg, bb, dat, fill)
            n = dat.length
            vg.scissor(bb.x, bb.y+bb.h/2, bb.w, bb.h/2)
            vg.path do
                vg.move_to(0.0, 0.0);
                (0...n).each do |i|
                    vg.line_to(bb.x + bb.w*dat[i].x,
                               bb.y + bb.h/2*(1-dat[i].y));
                end
                vg.line_to(bb.x+bb.w, 0.0)
                vg.close_path
                vg.fill_color fill
                vg.fill
            end
            vg.reset_scissor
        end

        def self.over_highlight(vg, bb, dat, fill)
            n = dat.length
            vg.scissor(bb.x, bb.y, bb.w, bb.h/2);
            vg.path do
                vg.move_to(0.0,bb.y+bb.h)
                (0...n).each do |i|
                    vg.line_to(bb.x + bb.w*dat[i].x,
                               bb.y + bb.h/2*(1-dat[i].y));
                end
                vg.line_to(bb.x+bb.w,bb.y+bb.h)
                vg.close_path
                vg.fill_color fill
                vg.fill
            end
            vg.reset_scissor
        end

        def self.zero_line(vg, bb, co)
            vg.path do
                vg.move_to(bb.x,      bb.y+bb.h/2)
                vg.line_to(bb.x+bb.w, bb.y+bb.h/2)
                vg.stroke_color co
                vg.stroke
            end
        end

        def self.env_sel_line(vg, bb, m, dat, co)
            n = dat.length
            #Draw Sel Line
            if(m >= 0 && m < n)
                vg.path do
                    vg.move_to(bb.x + bb.w*dat[m].x, bb.y)
                    vg.line_to(bb.x + bb.w*dat[m].x, bb.y + bb.h)
                end
                vg.stroke_color co
                vg.stroke
            end
        end

        def self.lfo_plot(vg, bb, dat, stroke)
            n = dat.length
            vg.path do
                vg.move_to(bb.x + bb.w*dat[0].x,
                           bb.y + bb.h/2*(1-dat[0].y))
                (0...n).each do |i|
                    vg.line_to(bb.x + bb.w*dat[i].x,
                               bb.y + bb.h/2*(1-dat[i].y))
                end
                vg.stroke_width 3.0
                vg.stroke_color stroke
                vg.stroke
            end
            vg.stroke_width 1.0
        end

        def self.env_plot(vg, bb, dat, stroke, selected)
            n = dat.length
            vg.path do
                vg.move_to(bb.x + bb.w*dat[0].x,
                           bb.y + bb.h/2*(1-dat[0].y))
                (0...n).each do |i|
                    vg.line_to(bb.x + bb.w*dat[i].x,
                               bb.y + bb.h/2*(1-dat[i].y))
                end
                vg.stroke_width 3.0
                vg.stroke_color stroke
                vg.stroke
            end
            vg.stroke_width 1.0

            sel_color    = Theme::VisualSelect
            bright       = Theme::VisualBright
            (0...n).each do |i|
                xx = bb.x + bb.w*dat[i].x;
                yy = bb.y + bb.h/2*(1-dat[i].y);
                scale = 3
                vg.stroke_color sel_color if(selected == i)
                vg.stroke_color bright    if(selected != i)
                vg.fill_color   color(:black)
                Draw::WaveForm::env_marker(vg, xx, yy, scale)
            end
        end

        def self.env_marker(vg, x, y, scale)
            vg.path do
                vg.rect(x-scale,y-scale,scale*2,scale*2);
                vg.stroke_width 1.2
                vg.fill
                vg.stroke
            end
        end

        def self.overlay(vg, bb, pts)
            n = pts.length/2
            sel_color    = Theme::VisualSelect
            dim_color    = Theme::VisualDimTrans
            (0...n).each do |i|
                xx = bb.x + bb.w*(pts[2*i]-1)*0.33
                yy = bb.y + bb.h*(1-pts[2*i+1])

                vg.stroke_color sel_color
                vg.fill_color   color(:black)
                env_marker(vg, xx, yy, 3)

                vg.path do |v|
                    v.move_to(xx, bb.y)
                    v.line_to(xx, bb.y + bb.h)
                    v.stroke_color dim_color
                    v.stroke
                end
            end
        end

        def self.overlay_lfo(vg, bb, pts)
            n = pts.length/2
            sel_color    = Theme::VisualSelect
            dim_color    = Theme::VisualDimTrans
            (0...n).each do |i|
                xx = bb.x + 0.2*bb.w + 0.8*bb.w*pts[2*i]
                yy = bb.y + bb.h/2*(1-pts[2*i+1]/127)

                vg.stroke_color sel_color
                vg.fill_color   color(:black)
                env_marker(vg, xx, yy, 3)

                vg.path do |v|
                    v.move_to(xx, bb.y)
                    v.line_to(xx, bb.y + bb.h)
                    v.stroke_color dim_color
                    v.stroke
                end
            end
        end
    end
    module Grid
        def self.log_y(vg, min, max, bb)
            med_fill     = color("114575")
            log10 = Math.log(10)
            min_  = Math.log(min)/log10
            max_  = Math.log(max)/log10
            #1,2,3,4,5,6,7,8,9,10,20
            xx = min_.to_i
            loop {
                break if xx>max_
                base = (xx-min_)/(max_-min_)

                (0...10).each do |shift|
                    delta = Math.log((shift+1)*1.0)/(log10*(max_-min_))
                    dy = bb.h*(base+delta);

                    next if(dy < 0 || dy > bb.h)
                    vg.path do |v|
                        v.move_to(bb.x,      bb.y+dy);
                        v.line_to(bb.x+bb.w, bb.y+dy);
                        v.stroke_color med_fill
                        v.stroke
                    end
                end
                xx += 1
            }
        end
        def self.log_x(vg, min, max, bb)
            med_fill     = color("114575")
            log10 = Math.log(10)
            min_  = Math.log(min)/log10
            max_  = Math.log(max)/log10
            #1,2,3,4,5,6,7,8,9,10,20
            xx = min_.to_i
            loop {
                break if xx>max_
                base = (xx-min_)/(max_-min_)

                (0...10).each do |shift|
                    delta = Math.log((shift+1)*1.0)/(log10*(max_-min_))
                    dx = bb.w*(base+delta);

                    next if(dx < 0 || dx > bb.w)
                    vg.path do |v|
                        v.move_to(bb.x+dx, bb.y);
                        v.line_to(bb.x+dx, bb.y+bb.h);
                        v.stroke_color med_fill
                        v.stroke_width 2
                        v.stroke
                    end
                end
                xx += 1
            }
        end
        def self.linear_x(vg, min, max, bb, thick=1.0)
            med_fill     = Theme::GridLine
            light_fill   = Theme::GridLine
            c = max
            (0..c).each do |ln|
                vg.path do |v|
                    off = (ln/c)*(bb.w)
                    vg.move_to(bb.x+off, bb.y)
                    vg.line_to(bb.x+off, bb.y+bb.h)
                    if((ln%10) == 0)
                        v.stroke_color med_fill
                        v.stroke_width 4.0*thick
                    else
                        v.stroke_color light_fill
                        v.stroke_width 2.0*thick
                    end
                    v.stroke
                end
            end
        end
        def self.linear_y(vg, min, max, bb, thick=1.0, c=40)
            med_fill     = Theme::GridLine
            light_fill   = Theme::GridLine
            c = max
            (0..c).each do |ln|
                vg.path do |v|
                    off = (ln/c)*(bb.h)
                    vg.move_to(bb.x,      bb.y+off)
                    vg.line_to(bb.x+bb.w, bb.y+off)
                    if((ln%10) == 0)
                        v.stroke_color med_fill
                        v.stroke_width 4.0*thick
                    else
                        v.stroke_color light_fill
                        v.stroke_width 2.0*thick
                    end
                    v.stroke
                end
            end
        end
    end

    module DSP
        PI = 3.14

        #try to get a -1..1 signal
        def self.normalize(seq)
            min = 1
            max = -1
            seq.each do |x|
                min = x if x < min
                max = x if x > max
            end
            mag = [max,-min].max
            (0...seq.length).each do |i|
                seq[i] /= mag
            end
            seq
        end

        def self.norm_harmonics(seq)
            (0...seq.length).each do |i|
                seq[i] = -seq[i] if seq[i] < 0
            end
            max = -1
            seq.each do |x|
                max = x if x > max
            end
            (0...seq.length).each do |i|
                seq[i] = (seq[i]/max)**0.1
            end
            seq
        end

        def self.magnitude(num, dem, freq, order=1)
            angle = PI*freq
            n = Complex(0,0)
            d = Complex(1,0)
            (0...num.length).each do |i|
                n += Complex.polar(num[i], i*angle)
                d -= Complex.polar(dem[i], i*angle)
            end
            (n/d).abs**order
        end

        def self.logspace(a,b,n)
            la = Math.log10(a)
            lb = Math.log10(b)
            out = []
            (0...n).each do |i|
                out << 10**(la + i/n*(lb-la))
            end
            out
        end

        def self.linspace(a,b,n)
            out = []
            (0...n).each do |i|
                out << a + i/n*(b-a)
            end
            out
        end

        def self.cumsum(x)
            partial = 0
            n       = x.length
            (0...n).each do |i|
                partial += x[i]
                x[i]     = partial
            end
            x
        end

        def self.ary_max(x)
            max = -1e20
            x.each do |xx|
                max = xx if xx>max
            end
            max
        end

        def self.norm_0_1(x)
            max = ary_max(x)
            n   = x.length
            (0...n).each do |i|
                x[i] /= max
            end
            x
        end
    end
    module Layout
        def self.vpack(l, selfBox, b, x=0, w=1,fixed_pad=0, y=0, h=1)
            off = 0+y
            delta = h/b.length
            b.each_with_index do |bb,i|
                l.fixed_long(bb, selfBox, x, off, w, delta,
                        0, fixed_pad, 0, -2*fixed_pad)
                off += delta
            end
            selfBox
        end

        def self.hpack(l, selfBox, b, y=0, h=1, fixed_pad=0)
            off = 0
            delta = 1.0/b.length
            b.each_with_index do |bb,i|
                l.fixed_long(bb, selfBox, off, y, delta, h,
                            fixed_pad, 0, -2*fixed_pad, 0)
                off += delta
            end
            selfBox
        end

        def self.hfill(l, selfBox, b, w, pad=0, fixed_pad=0)
            off = pad/2
            b.each_with_index do |bb,i|
                l.fixed_long(bb, selfBox, off, 0, w[i], 1,
                            fixed_pad, 0, -2*fixed_pad, 0)
                off += w[i] + pad
            end
            selfBox
        end

        def self.vfill(l, selfBox, b, h, pad=0, fixed_pad=0)
            off = 0
            b.each_with_index do |bb,i|
                l.fixed_long(bb, selfBox, 0, off, 1,  h[i],
                            0, fixed_pad, 0, -2*fixed_pad)
                off += h[i]
            end
            selfBox
        end

        def self.grid(l, selfBox, children, rows, cols, padw=0, padh=0)
            width  = 1.0/cols
            height = 1.0/rows

            children.each_with_index do |bb,i|
                r = (i/cols).to_i
                c = i%cols
                l.fixed_long(bb, selfBox, c*width, r*height, width, height,
                            padw, padh, -2*padw, -2*padh)
            end
            selfBox
        end
        #Transposed grid
        def self.gridt(l, selfBox, children, rows, cols, padw=0, padh=0)
            width  = 1.0/cols
            height = 1.0/rows

            children.each_with_index do |bb,i|
                r = (i%rows).to_i
                c = (i/rows).to_i
                l.fixed_long(bb, selfBox, c*width, r*height, width, height,
                            padw, padh, -2*padw, -2*padh)
            end
            selfBox
        end

        def self.tabpack(l, base)
            selfBox = l.genBox(:tabbox, base)
            prev = nil

            total   = 0
            weights = []
            base.children.each do |ch|
                scale = 100
                $vg.font_size scale
                weight   = $vg.text_bounds(0, 0, ch.label.upcase)
                weights << weight
                total   += weight
            end

            base.children.each_with_index do |ch, idx|
                box = ch.layout(l)
                l.contains(selfBox,box)

                l.sh([box.w, selfBox.w], [1, -(1-1e-4)*weights[idx]/total], 0)

                #add in the aspect constraint
                l.aspect(box, 100, weights[idx])

                if(prev)
                    l.rightOf(prev, box)
                end
                prev = box
            end
            selfBox
        end
    end

    def self.indent(rect, padw, padh)
        Rect.new(padw+rect.x, padh+rect.y, rect.w-2*padw, rect.h-2*padh)
    end

    def self.fade(c)
        cc = c.clone
        cc.a = 0.8
        cc
    end

    def self.GradBox(vg, bb)
        vg.path do |v|
            v.rect(bb.x,bb.y,bb.w,bb.h)
            paint = v.linear_gradient(0,0,0,bb.h,
                  Theme::InnerGrad1, Theme::InnerGrad2)
            v.fill_paint paint
            v.fill
            v.stroke_color color(:black)
            v.stroke_width 1.0
            v.stroke
        end
    end

    def self.zipToPos(x,y)
        o = []
        n = [x.length, y.length].min
        (0...n).each do |i|
            o << Pos.new(x[i], y[i])
        end
        o
    end

    def self.toPos(p)
        o = []
        n = p.length/2
        (0...n).each do |i|
            o << Pos.new(p[2*i+1], p[2*i+0])
        end
        o
    end

end

def color(c,alpha=255)
    if(c.class == Symbol)
        if(c == :red)
            return color("ff0000")
        elsif(c == :blue)
            return color("00ff00")
        elsif(c == :green)
            return color("0000ff")
        elsif(c == :coral)
            return color("FF7F50")
        elsif(c == :dark_orange)
            return color("FF8C00")
        elsif(c == :gold)
            return color("FFD700")
        elsif(c == :black)
            return color("000000")
        else
            raise Exception.new("Invalid Color", c)
        end
    end
    r = c[0..1].to_i 16
    g = c[2..3].to_i 16
    b = c[4..5].to_i 16
    NVG.rgba(r,g,b,alpha)
end

module Theme
    GeneralBackground   = color("2C2C2D")

    #Confirmed with designer
    SliderActive        = color("0A596F")
    SliderBackground    = color("1F2E3A")
    SliderStroke        = color("097d89")
    SliderVisActive     = color("15AEA3")

    KnobGrad1           = color("4E5050")
    KnobGrad2           = color("3D3E3E")

    HarmonicColor       = color("026392")

    TextColor           = color("CECECE")
    TextActiveColor     = color("52FAFE")
    TextModColor        = color("5BDBBA")

    ScrollInactive      = color("212121")
    ScrollActive        = color("606060")
    ButtonInactive      = color("424B56")
    ButtonActive        = color("00818E")

    ButtonGrad1         = color("4A4B4B")
    ButtonGrad2         = color("3E3F3F")

    ModuleGrad1         = color("4E4E4E")
    ModuleGrad2         = color("393939")

    WindowGrad1         = color("3A3A3B")
    WindowGrad2         = color("2A2A2B")

    InnerGrad1          = color("4E4E4F")
    InnerGrad2          = color("39393B")


    #Keyboard Widget
    KeyWhiteGrad1       = color("B0B7C0")
    KeyWhiteGrad2       = color("91989E")
    KeyWhiteAccent      = color("AEB7BF")
    KeyBlack            = color("2F3C45")
    KeyBlackAccent      = color("3C4F56")
    KeyEnable           = color("00ff00")

    TitleBar            = ButtonGrad1
    #Visualizations
    VisualBackground    = color("212121")
    VisualStroke        = color("014767")
    VisualLightFill     = color("014767",55)
    VisualBright        = color("3ac5ec")
    VisualDim           = color("114575")
    VisualDimTrans      = color("114575", 155)
    VisualSelect        = color("00ff00")

    VisualLine          = color("00FAFF")

    GridLine            = color("253743")

    #Bank Elements
    BankOdd             = color("3B3B3D")
    BankEven            = color("434344")
end

Pokemon = [
        "Bulbasaur",
        "Ivysaur",
        "Venusaur",
        "Charmander",
        "Charmeleon",
        "Charizard",
        "Squirtle",
        "Wartortle",
        "Blastoise",
        "Caterpie",
        "Metapod",
        "Butterfree",
        "Weedle",
        "Kakuna",
        "Beedrill",
        "Pidgey",
        "Pidgeotto",
        "Pidgeot",
        "Rattata",
        "Raticate",
        "Spearow",
        "Fearow",
        "Ekans",
        "Arbok",
        "Pikachu",
        "Raichu",
        "Sandshrew",
        "Sandslash",
        "Nidoran",
        "Nidorina",
        "Nidoqueen",
        "Nidoran",
        "Nidorino",
        "Nidoking",
        "Clefairy",
        "Clefable",
        "Vulpix",
        "Ninetales",
        "Jigglypuff",
        "Wigglytuff",
        "Zubat",
        "Golbat",
        "Oddish",
        "Gloom",
        "Vileplume",
        "Paras",
        "Parasect",
        "Venonat",
        "Venomoth",
        "Diglett",
        "Dugtrio",
        "Meowth",
        "Persian",
        "Psyduck",
        "Golduck",
        "Mankey",
        "Primeape",
        "Growlithe",
        "Arcanine",
        "Poliwag",
        "Poliwhirl",
        "Poliwrath",
        "Abra",
        "Kadabra",
        "Alakazam",
        "Machop",
        "Machoke",
        "Machamp",
        "Bellsprout",
        "Weepinbell",
        "Victreebel",
        "Tentacool",
        "Tentacruel",
        "Geodude",
        "Graveler",
        "Golem",
        "Ponyta",
        "Rapidash",
        "Slowpoke",
        "Slowbro",
        "Magnemite",
        "Magneton",
        "Farfetch'd",
        "Doduo",
        "Dodrio",
        "Seel",
        "Dewgong",
        "Grimer",
        "Muk",
        "Shellder",
        "Cloyster",
        "Gastly",
        "Haunter",
        "Gengar",
        "Onix",
        "Drowzee",
        "Hypno",
        "Krabby",
        "Kingler",
        "Voltorb",
        "Electrode",
        "Exeggcute",
        "Exeggutor",
        "Cubone",
        "Marowak",
        "Hitmonlee",
        "Hitmonchan",
        "Lickitung",
        "Koffing",
        "Weezing",
        "Rhyhorn",
        "Rhydon",
        "Chansey",
        "Tangela",
        "Kangaskhan",
        "Horsea",
        "Seadra",
        "Goldeen",
        "Seaking",
        "Staryu",
        "Starmie",
        "Mr. Mime",
        "Scyther",
        "Jynx",
        "Electabuzz",
        "Magmar",
        "Pinsir",
        "Tauros",
        "Magikarp",
        "Gyarados",
        "Lapras",
        "Ditto",
        "Eevee",
        "Vaporeon",
        "Jolteon",
        "Flareon",
        "Porygon",
        "Omanyte",
        "Omastar",
        "Kabuto",
        "Kabutops",
        "Aerodactyl",
        "Snorlax",
        "Articuno",
        "Zapdos",
        "Moltres",
        "Dratini",
        "Dragonair",
        "Dragonite",
        "Mewtwo",
        "Mew"]

#Draw a linear x/y grid
def draw_grid(vg, r, c, x, y, w, h)
    light_fill   = NVG.rgba(0x11,0x45,0x75,200)
    med_fill   = NVG.rgba(0x11,0x45,0x75,240)

    (1..r).each do |ln|
        vg.path do |v|
            off = (ln/r)*(h/2)
            vg.move_to(x,   y + h/2+off);
            vg.line_to(x+w, y + h/2+off)
            vg.move_to(x,   y + h/2-off);
            vg.line_to(x+w, y + h/2-off)
            if((ln%10) == 0)
                v.stroke_color med_fill
                v.stroke_width 2.0
            else
                v.stroke_color light_fill
                v.stroke_width 1.0
            end
            v.stroke
        end
    end

    (1..c).each do |ln|
        vg.path do |v|
            off = (ln/c)*(w)
            vg.move_to(x+off, y)
            vg.line_to(x+off, y + h)
            if((ln%10) == 0)
                v.stroke_color med_fill
                v.stroke_width 2.0
            else
                v.stroke_color light_fill
                v.stroke_width 1.0
            end
            v.stroke
        end
    end
end

def make_bandpass(freq, fs, bw, gain, stages, log2)
    omega = 2 * 3.14159 * freq / fs
    sn    = Math.sin omega
    cs    = Math.cos omega
    alpha = sn * Math.sinh(log2 / 2 * bw * omega / sn);

    alpha = 1  if alpha > 1
    alpha = bw if alpha > bw

    b = [0.0, 0.0, 0.0]
    a = [0.0, 0.0, 0.0]
    b[0] =  alpha / (1 + alpha) * gain / stages;
    b[2] = -alpha / (1 + alpha) * gain / stages;
    a[1] = 2 * cs / (1 + alpha);
    a[2] = -(1 - alpha) / (1 + alpha);

    return b, a
end

def make_formant(freq, fs, q, gain, stages)
    omega = 2 * 3.14159 * freq / fs
    sn    = Math.sin omega
    cs    = Math.cos omega
    alpha = sn / (2 * q);
    gain *= Math.sqrt(q + 1)

    b = [0.0, 0.0, 0.0]
    a = [0.0, 0.0, 0.0]

    b[0] = alpha / (1 + alpha)  * gain
    b[2] = -alpha / (1 + alpha) * gain
    a[1] = 2 * cs / (1 + alpha)
    a[2] = -(1 - alpha) / (1 + alpha)

    return b, a
end


def sub_synth_response(xpts, pars)
    ypts  = []
    xnorm = []
    fs   = 48000.0
    xpts.each do |x|
        ypts << 0
        xnorm << x / fs*2
    end

    stages = pars[0]

    filters = (pars.length-1)/3
    log2 = Math.log(2)

    (0...filters).each do |f|
        freq = pars[f*3+1]
        bw   = pars[f*3+2]
        gain = pars[f*3+3]

        (b, a) = make_bandpass(freq, fs, bw, gain, stages, log2)

        oo = Draw::opt_magnitude(b, a, xnorm, stages)
        xpts.each_with_index do |x, i|
            ypts[i] += oo[i]
        end
    end

    ypts
end

def formant_filter_response(xpts, formants, q_value,
                            stages, gain)
    ypts  = []
    xnorm = []
    fs   = 48000.0
    xpts.each do |x|
        ypts << 0
        xnorm << x / fs*2
    end

    b = [0.0, 0.0, 0.0]
    a = [0.0, 0.0, 0.0]

    #for each formant...
    (0...formants.length).each do |nformant|
        #compute formant parameters(frequency,amplitude,etc.)
        filter_freq = formants[nformant].freq;
        filter_q    = formants[nformant].q * q_value;

        filter_q    = filter_q ** (1 / stages) if(stages > 1 && filter_q > 1)

        filter_amp = formants[nformant].amp

        #printf("NFORMANT %d\n", nformant);
        #printf("CHARACTERISTICS: FREQ %f Q %f AMP %f\n", filter_freq, filter_q, filter_amp);
        sample_rate = 48000

        next if(filter_freq > (sample_rate / 2 - 100))

        (b, a) = make_formant(filter_freq, sample_rate,
                               filter_q, filter_amp, stages)

        oo = Draw::opt_magnitude(b, a, xnorm, stages)
        xpts.each_with_index do |x, i|
            ypts[i] += oo[i]
        end
    end

    ypts.map {|x| [-40, to_dB(x) + gain].max }
end

def to_dB(x)
    20*Math.log(x)/Math.log(10)
end

class Formant
    def initialize(freq, amp, q)
        @freq = freq
        @amp  = amp
        @q    = q
    end

    attr_reader :freq, :amp, :q
end
