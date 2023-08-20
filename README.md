# Roku Local Photos

This is a Roku channel for showing photos from a [server](https://github.com/mloft74/photo-manager-server) in a screensaver

## Deploying

You can deploy by zipping the contents of the root directory and following the deployment instructions in the [Roku documentation](https://developer.roku.com/en-gb/docs/developer-program/getting-started/roku-dev-prog.md).

Alternatively, you could use [BrighterScript](https://github.com/rokucommunity/brighterscript) to deploy.

## Configuration

When the channel is deployed, you will need to provide a uri to the channel for the server hosting the images. You will need to include either http:// or https:// depending on whether you want a secure transport, and the uri cannot end in a /.
