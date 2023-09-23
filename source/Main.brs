sub Main()
    print "[Main] Main"
    'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)

    scene = screen.CreateScene("MainMenu")
    screen.Show()

    while true
        msg = Wait(0, m.port)
        if msg <> invalid
            msgType = Type(msg)
            if msgType = "roSGScreenEvent"
                if msg.IsScreenClosed() then return
            end if
        end if
    end while
end sub

sub RunScreensaver()
    print "[Main] RunScreensaver"
    'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    m.global = screen.getGlobalNode()
    m.global.AddField("nextNumberForNextImageTask", "int", true)
    m.global.nextNumberForNextImageTask = 0
    m.global.AddField("nextNumberForCurrentImageTask", "int", true)
    m.global.nextNumberForCurrentImageTask = 0

    scene = screen.CreateScene("Screensaver")
    screen.Show()

    while true
        msg = Wait(0, port)
        if msg <> invalid
            msgType = Type(msg)
            if msgType = "roSGScreenEvent"
                if msg.IsScreenClosed() then return
            end if
        end if
    end while
end sub
