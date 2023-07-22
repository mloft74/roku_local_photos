function Init()
    print "[ScreenSaver] Init"
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0xFF000000"

    m.currentPoster = m.top.FindNode("posterA")
    m.nextPoster = m.top.FindNode("posterB")
    m.animation = m.top.FindNode("animation")
    m.fadeInInterpolator = m.top.FindNode("fadeInInterpolator")
    m.fadeOutInterpolator = m.top.FindNode("fadeOutInterpolator")

    m.timer = m.top.FindNode("timer")
    m.timer.ObserveField("fire", "SwapPosters")

    registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
    m.serverIp = registrySection.Read("serverIp")

    StartNextImageTaskForInit()
end function

function StartNextImageTaskForInit()
    print "[ScreenSaver] StartNextImageTaskForInit"
    m.nextImageTask = CreateObject("roSGNode", "NextImageTask")
    m.nextImageTask.ObserveField("state", "ListenForNextImageDoneForInit")
    m.nextImageTask.control = "run"
end function

function ListenForNextImageDoneForInit()
    print "[ScreenSaver] ListenForNextImageDoneForInit"
    if m.nextImageTask.state <> "done"
        return invalid
    end if
    m.nextImageTask.UnobserveField("state")

    m.currentPoster.ObserveField("loadStatus", "FadeInForInit")
    m.currentPoster.uri = m.serverIp + "/image/" + m.nextImageTask.fileName

    m.nextImageTask = invalid
end function

function FadeInForInit()
    print "[ScreenSaver] FadeInForInit"
    if m.currentPoster.loadStatus <> "ready"
        return invalid
    end if
    m.currentPoster.UnobserveField("loadStatus")
    m.animation.control = "start"
    ' TODO: add listener for when animation is done to start timer
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
    m.nextImageTask.UnobserveField("state")

    m.nextPoster.uri = m.serverIp + "/image/" + m.nextImageTask.fileName

    m.nextImageTask = invalid
end function

function SwapPosters()
    print "[ScreenSaver] SwapPosters"
    ' TODO: impl
end function
