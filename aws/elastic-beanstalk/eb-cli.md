# EB Cli Setup Steps

## Installing the elastic beanstalk cli

- [EB Cli MacOS](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-osx.html)
- [EB Cli Linux](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-linux.html)
- [EB Cli Windows](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-windows.html)

Installing the cli can be harder on Linux and Windows, be sure to reach out to others if you're having issues. After you have the cli installed, navigate to the root of your project and run:

`eb --version`

You should get an output similar to `EB CLI 3.14.1 (Python 2.7.1)`, this will confirm that the eb cli is installed correctly. Next you will want to run:

`eb init`

This will take you through the steps to initialize your project for elastic beanstalk cli commands. It will look something like [eb init prompt](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb3-init.html). Enter the application name (if you're creating a new one) followed by the type of project and the pem key. If you need to generate a new pem key(you should if it is a new project) then the aws cli will create one for you labled with the project name, and insert both public and private keys in your `.ssh` folder. Be sure you have the aws configured properly in order to push the new instance to the correct account!

## Next Steps

If you have everything configured properly, click one of the following links for deployment steps:

[EB Deployment with Docker](eb-docker-deployment.md)

[EB Deployment without Docker](eb-deployment.md)