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

sub RunScreenSaver()
    print "[Main] RunScreenSaver"
    'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    m.global = screen.getGlobalNode()
    m.global.AddField("nextNumberForNextTaskImage", "int", true)
    m.global.nextNumberForNextTaskImage = 0

    scene = screen.CreateScene("ScreenSaver")
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
