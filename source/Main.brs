sub Main()
    print "[Main] Main"
    'Indicate this is a Roku SceneGraph application'
    screen = createObject("roSGScreen")
    m.port = createObject("roMessagePort")
    screen.setMessagePort(m.port)

    scene = screen.createScene("MainMenu")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        end if
    end while
end sub

sub RunScreenSaver()
    print "[Main] RunScreenSaver"
    'Indicate this is a Roku SceneGraph application'
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    scene = screen.createScene("ScreenSaver")
    screen.show()

    while(true)
        msg = wait(0, port)
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        end if
    end while
end sub
