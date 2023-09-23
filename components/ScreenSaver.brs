function Init()
    print "[ScreenSaver] Init"
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0xFF000000"

    m.currentPoster = m.top.FindNode("posterA")
    m.nextPoster = m.top.FindNode("posterB")

    m.animation = m.top.FindNode("animation")
    m.animation.ObserveField("state", "ListenForSwapAnimationDone")

    m.fadeInInterpolator = m.top.FindNode("fadeInInterpolator")
    m.fadeOutInterpolator = m.top.FindNode("fadeOutInterpolator")

    m.timer = m.top.FindNode("timer")
    m.timer.ObserveField("fire", "SwapPosters")

    m.error = m.top.FindNode("error")
    m.telnetMsg = m.top.FindNode("telnetMsg")
    m.telnetCmd = m.top.FindNode("telnetCmd")

    ' TODO: show error message if server isn't defined
    registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
    m.serverIp = registrySection.Read("serverIp")

    m.info = CreateObject("roDeviceInfo")

    if m.serverIp = invalid or m.serverIp = ""
        m.error.text = "Server not selected"
    else
        StartCurrentImageTaskForInit()
    end if
end function

function StartCurrentImageTaskForInit()
    print "[ScreenSaver] StartCurrentImageTaskForInit"
    m.currentImageTaskForInit = CreateObject("roSGNode", "CurrentImageTask")
    m.currentImageTaskForInit.ObserveField("state", "ListenForCurrentImageDoneForInit")
    m.currentImageTaskForInit.control = "run"
end function

function ListenForCurrentImageDoneForInit()
    print "[ScreenSaver] ListenForCurrentImageDoneForInit > state: "; m.currentImageTaskForInit.state
    if m.currentImageTaskForInit.state <> "done"
        return invalid
    end if
    m.currentImageTaskForInit.UnobserveField("state")

    if IsTaskInvalid(m.currentImageTaskForInit)
        m.error.text = "Could not load image during intialization"
        ShowTelnetMessage()
        return invalid
    end if

    width = m.currentImageTaskForInit.width
    height = m.currentImageTaskForInit.height
    screenAspectRatio = 16 / 9
    imageAspectRatio = width / height
    if imageAspectRatio > screenAspectRatio
        x = 0
        y = ComputeLocation(width, height, 1920, 1080)
        m.currentPoster.translation = [x, y]
    else
        y = 0
        x = ComputeLocation(height, width, 1080, 1920)
        m.currentPoster.translation = [x, y]
    end if

    m.currentPoster.ObserveField("loadStatus", "FadeInForInit")
    m.currentPoster.uri = m.serverIp + "/image/" + m.currentImageTaskForInit.fileName

    m.currentImageTaskForInit = invalid
end function

function ComputeLocation(fullImgDim as integer, otherImgDim, fullScreenDim as integer, otherScreenDim as integer) as integer
    scale = fullScreenDim / fullImgDim
    scaledOtherImgDim = otherImgDim * scale
    remainingOtherScreenDim = otherScreenDim - scaledOtherImgDim
    location = remainingOtherScreenDim / 2
    return location
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
    m.animation.control = "start"
end function

function ListenForSwapAnimationDone()
    print "[ScreenSaver] ListenForSwapAnimationDone > state: "; m.animation.state
    if m.animation.state <> "stopped"
        return invalid
    end if

    StartCurrentImageTask()
    m.timer.control = "start"
end function

function StartCurrentImageTask()
    print "[ScreenSaver] StartCurrentImageTask"
    m.currentImageTask = CreateObject("roSGNode", "CurrentImageTask")
    m.currentImageTask.ObserveField("state", "ListenForCurrentImageDone")
    m.currentImageTask.control = "run"
end function

function ListenForCurrentImageDone()
    print "[ScreenSaver] ListenForCurrentImageDone > state: "; m.currentImageTask.state
    if m.currentImageTask.state <> "done"
        return invalid
    end if
    m.currentImageTask.UnobserveField("state")

    if IsTaskInvalid(m.currentImageTask)
        m.error.text = "Could not load image"
        ShowTelnetMessage()
        return invalid
    end if

    width = m.currentImageTask.width
    height = m.currentImageTask.height
    screenAspectRatio = 16 / 9
    imageAspectRatio = width / height
    if imageAspectRatio > screenAspectRatio
        x = 0
        y = ComputeLocation(width, height, 1920, 1080)
        m.nextPoster.translation = [x, y]
    else
        y = 0
        x = ComputeLocation(height, width, 1080, 1920)
        m.nextPoster.translation = [x, y]
    end if

    m.nextPoster.uri = m.serverIp + "/image/" + m.currentImageTask.fileName

    taskNumber = m.currentImageTask.taskNumber
    m.currentImageTask = invalid
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

function IsTaskInvalid(task as object)
    print "[IsTaskInvalid]"
    invalidFileName = task.fileName = invalid or task.fileName = ""
    invalidWidth = task.width = invalid or task.width = 0
    invalidHeight = task.height = invalid or task.width = 0
    return invalidFileName or invalidWidth or invalidHeight
end function

function ShowTelnetMessage()
    print "[ShowTelnetMessage]"
    m.telnetMsg.text = "Look at logs with telnet to see the error"

    localIps = m.info.GetIPAddrs()
    items = localIps.Items()
    if items.Count() = 0
        return invalid
    end if

    localIp = items[0].value
    m.telnetCmd.text = "telnet " + localIp + " 8087"
end function
