Widget {
    id: kitbuttons
    property Int rows: 4
    property Symbol sym: nil
    property Array  valueRef: []
    function onSetup(old=nil)
    {
        return if children.length > 0
        v = []
        (0...rows).each do |r|
            [0,1,2,3].each do |c|
                ii         = (1+c + 4*r)
                but        = Qml::KitButton.new(db)
                but.label  = ii.to_s
                but.action = lambda {kitbuttons.change_active(ii-1)}
                Qml::add_child(self, but)

                path = ""
                path = "/part0/kit#{ii-1}/Penabled" if self.sym == :kit
                path = "/part#{ii-1}/Penabled" if self.sym == :part
                path = "/part0/kit0/adpars/VoicePar#{ii-1}/Enabled" if self.sym == :voice

                rr = OSC::RemoteParam.new($remote, path)
                rr.callback = lambda {|vv| but.set_enable(vv)}
                v << rr
            end
        end
        self.valueRef = v
    }

    function set_kit_enable(ii, val)
    {
        return if ii < 0
        return if ii >= children.length
        puts "set_kit_enable #{self.sym}"
        children[ii].set_enable(val)
    }

    function change_active(ii)
    {
        root.set_view_pos(self.sym,ii) if self.sym
        root.change_view               if self.sym

        children.each_with_index do |ch, i|
            n = (i == ii)
            if(n != ch.value)
                ch.value = n
                ch.damage_self
            end
        end
    }

    function layout(l)
    {
        selfBox = l.genBox :kitButtons, self
        b = 0
        cols = 4
        ch = self.children
        (0...rows).each do |r|
            (0...cols).each do |c|
                bb = ch[b].layout(l)
                b += 1
                l.fixed(bb, selfBox, c/4, r/self.rows, 0.25, 1/self.rows)
            end
        end
        l.aspect(selfBox, rows, cols)
        selfBox
    }

    function animate()
    {
        return if !self.sym
        vv = root.get_view_pos self.sym
        children.each_with_index do |ch, i|
            n = (i == vv)
            if(n != ch.value)
                ch.value = n
                ch.damage_self
            end
        end
    }
}
