Widget {
    id: center

    function draw(vg)
    {
        bg_color      = color("424B56")
        vg.path do |v|
            v.rect(0, 0, self.w, self.h)
            v.fill_color(bg_color)
            v.fill
        end
    }
    function layout(l)
    {
        #puts "Center layout"
        selfBox = l.genBox :zynCenter, center
        headBox  = header.layout(l)
        row1Box  = row1.layout(l)
        row2Box  = row2.layout(l)
        footBox  = footer.layout(l)

        #puts "module layout done"
        l.contains(selfBox, headBox)
        l.contains(selfBox, row1Box)
        l.contains(selfBox, row2Box)
        l.contains(selfBox, footBox)

        #Global Optimizatoin
        l.topOf(headBox, row1Box)
        l.topOf(row1Box, row2Box)
        l.topOf(row2Box, footBox)

        l.sheq([headBox.h, selfBox.h], [1, -0.05], 0)
        l.sheq([footBox.h, selfBox.h], [1, -0.05], 0)
        l.sheq([row1Box.h, row2Box.h], [1, -1.2], 0)

        #l.sheq([row1Box.h, row3Box.h], [1, -1], 0)
        #l.le([row1Box.h, selfBox.h], [1, -0.2])
        #l.le([content.h, selfBox.h], [1, -0.36])
        #l.punish_difference(amplBox.w,amplEBox.w)
        #l.punish_difference(freqBox.w,freqEBox.w)
        #puts "Center Layout Done"

        selfBox
    }
    Widget {
        id: header


        function layout(l)
        {
            selfBox = l.genBox :zynCenterHeader, header
            prev = nil

            total   = 0
            weights = []
            header.children.each do |ch|
                scale = 100
                $vg.font_size scale
                weight   = $vg.text_bounds(0, 0, ch.label.upcase + "  ")
                weights << weight
                total   += weight
            end

            header.children.each_with_index do |ch, idx|
                box = ch.layout(l)
                l.contains(selfBox,box)

                l.sh([box.w, selfBox.w], [1, -(1-1e-4)*weights[idx]/total], 0)

                #add in the aspect constraint
                l.aspect(box, 100, weights[idx])

                print "layout weights "
                puts weights[idx]/total
                if(prev)
                    l.rightOf(prev, box)
                end
                prev = box
            end
            selfBox
        }
        
        function setTab(id)
        {
            N = children.length
            tab_id = 0
            (0..N).each do |ch_id|
                child = children[ch_id]
                if(child.class == Qml::TabButton)
                    child.value = (tab_id == id)
                    tab_id += 1
                    self.root.damage_item child
                end
            end
        }

        Button { label: "<"; layoutOpts: [:no_constraint]}
        Button { label: "4"; layoutOpts: [:no_constraint]}
        Button { label: ">"; layoutOpts: [:no_constraint]}
        TabButton { whenClick: lambda {header.setTab(0)}; label: "voice"}
        TabButton { whenClick: lambda {header.setTab(1)}; label: "global parameters"; value: true}
        TabButton { whenClick: lambda {header.setTab(2)}; label: "voice parameters"}
        TabButton { whenClick: lambda {header.setTab(3)}; label: "oscillators"}
        TabButton { whenClick: lambda {header.setTab(4)}; label: "voice list"}
        TabButton { whenClick: lambda {header.setTab(5)}; label: "resonance"}
        Button { label: "c"; layoutOpts: [:no_constraint]}
        Button { label: "p"; layoutOpts: [:no_constraint]}
    }

    Widget {
        id: row1
        LfoVis {
            id: vis
        }
    }

    Widget {
        id: row2
        function layout(l)
        {
            selfBox  = l.genBox :zynCenterRow2, self
            gen      = amp_gen.layout(l)
            env      = amp_env.layout(l)
            lfo      = amp_lfo.layout(l)
            l.contains(selfBox, gen)
            l.contains(selfBox, env)
            l.contains(selfBox, lfo)
            l.rightOf(gen, env)
            l.rightOf(env, lfo)

            #Making things look nice
            l.sheq([gen.w, selfBox.w], [1, -1/3.0],  0)
            l.sheq([env.w, selfBox.w], [1, -1/3.0],  0)


            selfBox
        }
        ZynAmpGeneral {
            id: amp_gen
        }
        ZynAmpEnv {
            id: amp_env
        }
        ZynLFO {
            id: amp_lfo
        }
    }
    Widget {
        id: footer

        function layout(l)
        {
            selfBox = l.genBox :zynCenterHeader, footer
            prev = nil

            total   = 0
            weights = []
            footer.children.each do |ch|
                scale = 100
                $vg.font_size scale
                weight   = $vg.text_bounds(0, 0, ch.label.upcase)
                weights << weight
                total   += weight
            end

            footer.children.each_with_index do |ch, idx|
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
        }

        function setTab(id)
        {
            (0..2).each do |ch_id|
                children[ch_id].value = (ch_id == id)
                self.root.damage_item children[ch_id]
            end
        }

        TabButton { label: "amplitude"; whenClick: lambda {footer.setTab(0)}; highlight_pos: :top; value: true}
        TabButton { label: "frequency"; whenClick: lambda {footer.setTab(1)}; highlight_pos: :top}
        TabButton { label: "filter";    whenClick: lambda {footer.setTab(2)}; highlight_pos: :top}
    }
}
