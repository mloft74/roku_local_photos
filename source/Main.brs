sub Main()
    print "in showChannelSGScreen"
    'Indicate this is a Roku SceneGraph application'
    screen = createObject("roSGScreen")
    m.port = createObject("roMessagePort")
    screen.setMessagePort(m.port)

    scene = screen.createScene("MainMenu")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        endif
    endwhile
endsub
