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
    m.nextImageTaskForInit = CreateObject("roSGNode", "NextImageTask")
    m.nextImageTaskForInit.ObserveField("state", "ListenForNextImageDoneForInit")
    m.nextImageTaskForInit.control = "run"
end function

function ListenForNextImageDoneForInit()
    print "[ScreenSaver] ListenForNextImageDoneForInit > state:"; m.nextImageTaskForInit.state
    if m.nextImageTaskForInit.state <> "done"
        return invalid
    end if
    m.nextImageTaskForInit.UnobserveField("state")

    m.currentPoster.ObserveField("loadStatus", "FadeInForInit")
    m.currentPoster.uri = m.serverIp + "/image/" + m.nextImageTaskForInit.fileName

    m.nextImageTaskForInit = invalid
end function

function FadeInForInit()
    print "[ScreenSaver] FadeInForInit"
    if m.currentPoster.loadStatus <> "ready"
        return invalid
    end if
    m.currentPoster.UnobserveField("loadStatus")
    StartSwapAnimation()
end function

function StartSwapAnimation()
    print "[ScreenSaver] StartSwapAnimation"
    m.animation.ObserveField("state", "ListenForSwapAnimationDone")
    m.animation.control = "start"
end function

function ListenForSwapAnimationDone()
    print "[ScreenSaver] ListenForSwapAnimationDone > state:"; m.animation.state
    if m.animation.state <> "stopped"
        return invalid
    end if
    m.animation.UnobserveField("state")

    StartNextImageTask()
    m.timer.control = "start"
end function

function StartNextImageTask()
    print "[ScreenSaver] StartNextImageTask"
    m.nextImageTask = CreateObject("roSGNode", "NextImageTask")
    m.nextImageTask.ObserveField("state", "ListenForNextImageDone")
    m.nextImageTask.control = "run"
end function

function ListenForNextImageDone()
    print "[ScreenSaver] ListenForNextImageDone > state:"; m.nextImageTask.state
    if m.nextImageTask.state <> "done"
        return invalid
    end if
    m.nextImageTask.UnobserveField("state")

    m.nextPoster.uri = m.serverIp + "/image/" + m.nextImageTask.fileName

    taskNumber = m.nextImageTask.taskNumber
    m.nextImageTask = invalid
end function

function SwapPosters()
    print "[ScreenSaver] SwapPosters"

    tempPoster = m.currentPoster
    m.currentPoster = m.nextPoster
    m.nextPoster = tempPoster

    tempTarget = m.fadeInInterpolator.fieldToInterp
    m.fadeInInterpolator.fieldToInterp = m.fadeOutInterpolator.fieldToInterp
    m.fadeOutInterpolator.fieldToInterp = tempTarget

    StartSwapAnimation()
end function
