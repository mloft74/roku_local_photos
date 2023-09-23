function Init()
    print "[Screensaver] Init"
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0xFF000000"

    m.currentPoster = m.top.FindNode("posterA")
    m.nextPoster = m.top.FindNode("posterB")

    m.animation = m.top.FindNode("animation")
    m.animation.ObserveField("state", "ListenForFadeAnimationDone")

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
    print "[Screensaver] StartCurrentImageTaskForInit"
    m.currentImageTaskForInit = CreateObject("roSGNode", "CurrentImageTask")
    m.currentImageTaskForInit.ObserveField("state", "ListenForCurrentImageDoneForInit")
    m.currentImageTaskForInit.control = "run"
end function

function ListenForCurrentImageDoneForInit()
    print "[Screensaver] ListenForCurrentImageDoneForInit > state: "; m.currentImageTaskForInit.state
    if m.currentImageTaskForInit.state <> "done"
        return invalid
    end if
    m.currentImageTaskForInit.UnobserveField("state")

    if IsTaskInvalid(m.currentImageTaskForInit)
        ShowTelnetMessage("Could not load image during intialization")
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

    m.fileName = m.currentImageTaskForInit.fileName
    m.currentPoster.ObserveField("loadStatus", "FadeInForInit")
    m.currentPoster.uri = m.serverIp + "/image/" + m.fileName

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
    print "[Screensaver] FadeInForInit > loadStatus: "; m.currentPoster.loadStatus
    if m.currentPoster.loadStatus <> "ready"
        return invalid
    end if
    m.currentPoster.UnobserveField("loadStatus")
    StartFadeAnimation()
end function

function StartFadeAnimation()
    print "[Screensaver] StartFadeAnimation"
    m.animation.control = "start"
end function

function ListenForFadeAnimationDone()
    print "[Screensaver] ListenForFadeAnimationDone > state: "; m.animation.state
    if m.animation.state <> "stopped"
        return invalid
    end if

    StartResolveImageTask()
    m.timer.control = "start"
end function

function StartResolveImageTask()
    print "[Screensaver] StartResolveImageTask > fileName: "; m.fileName
    m.resolveImageTask = CreateObject("roSGNode", "ResolveImageTask")
    m.resolveImageTask.fileName = m.fileName
    m.resolveImageTask.ObserveField("state", "ListenForResolveImageDone")
    m.resolveImageTask.control = "run"
end function

function ListenForResolveImageDone()
    print "[Screensaver] ListenForResolveImageDone > state: "; m.resolveImageTask.state
    if m.resolveImageTask.state <> "done"
        return invalid
    end if
    m.resolveImageTask.UnobserveField("state")

    message = m.resolveImageTask.message
    if message = "resolved" or message = "noImages" or message = "notCurrent"
        print "[Screensaver] ListenForResolveImageDone > resolveStatus: "; message
    else
        ShowTelnetMessage("Error resolving image: " + message)
        return invalid
    end if
    
    m.resolveImageTask = invalid

    StartCurrentImageTask()
end function

function StartCurrentImageTask()
    print "[Screensaver] StartCurrentImageTask"
    m.currentImageTask = CreateObject("roSGNode", "CurrentImageTask")
    m.currentImageTask.ObserveField("state", "ListenForCurrentImageDone")
    m.currentImageTask.control = "run"
end function

function ListenForCurrentImageDone()
    print "[Screensaver] ListenForCurrentImageDone > state: "; m.currentImageTask.state
    if m.currentImageTask.state <> "done"
        return invalid
    end if
    m.currentImageTask.UnobserveField("state")

    if IsTaskInvalid(m.currentImageTask)
        ShowTelnetMessage("Could not load image")
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

    m.fileName = m.currentImageTask.fileName
    m.nextPoster.uri = m.serverIp + "/image/" + m.fileName

    taskNumber = m.currentImageTask.taskNumber
    m.currentImageTask = invalid
end function

function SwapPosters()
    print "[Screensaver] SwapPosters"

    tempPoster = m.currentPoster
    m.currentPoster = m.nextPoster
    m.nextPoster = tempPoster

    print "[Screensaver] SwapPosters | showing "; m.currentPoster.uri

    tempTarget = m.fadeInInterpolator.fieldToInterp
    m.fadeInInterpolator.fieldToInterp = m.fadeOutInterpolator.fieldToInterp
    m.fadeOutInterpolator.fieldToInterp = tempTarget

    StartFadeAnimation()
end function

function IsTaskInvalid(task as object)
    print "[Screensaver] IsTaskInvalid"
    invalidFileName = task.fileName = invalid or task.fileName = ""
    invalidWidth = task.width = invalid or task.width = 0
    invalidHeight = task.height = invalid or task.width = 0
    return invalidFileName or invalidWidth or invalidHeight
end function

function ShowTelnetMessage(error as string)
    print "[ShowTelnetMessage] error > "; error
    m.error.text = error
    m.telnetMsg.text = "Look at logs with telnet to see the error"

    localIps = m.info.GetIPAddrs()
    items = localIps.Items()
    if items.Count() = 0
        return invalid
    end if

    localIp = items[0].value
    m.telnetCmd.text = "telnet " + localIp + " 8087"
end function
