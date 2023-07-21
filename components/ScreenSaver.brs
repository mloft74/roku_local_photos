function Init()
    print "[ScreenSaver] Init"
    m.poster = m.top.FindNode("poster")
    print(m.poster.loadDisplayMode)

    registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
    m.serverIp = registrySection.Read("serverIp")

    StartNextImageTask()
end function

function StartNextImageTask()
    print "[ScreenSaver] StartNextImageTask"
    m.nextImageTask = CreateObject("roSGNode", "NextImageTask")
    m.nextImageTask.ObserveField("state", "ListenForNextImageDone")
    m.nextImageTask.control = "run"
end function

function ListenForNextImageDone()
    print "[ScreenSaver] ListenForNextImageDone"
    if m.nextImageTask.state <> "done"
        return invalid
    end if
    m.poster.uri = m.serverIp + "/image/" + m.nextImageTask.fileName
    m.nextImageTask.UnobserveField("state")
    m.nextImageTask = invalid
end function
