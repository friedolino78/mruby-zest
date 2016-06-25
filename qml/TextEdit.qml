Widget {
    id: text
    property signal action: nil;
    property Color textColor: Theme::TextColor
    property Float height: 0.5

    function class_name()
    {
        "Text"
    }

    function draw(vg)
    {
        background Theme::VisualBackground
        input  = "This is some random text which is hopefully "
        input += "is long enough to span a few different lines"
        input += ". I need it to in order to test multi-line "
        input += "rendering."

        vg.font_face("bold")
        vg.font_size 0.07*h
        vg.text_align NVG::ALIGN_CENTER | NVG::ALIGN_MIDDLE
        vg.fill_color(textColor)
        vg.text_box(0,0.07*h,w, input)
    }
}