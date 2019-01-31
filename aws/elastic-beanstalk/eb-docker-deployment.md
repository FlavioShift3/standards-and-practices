# EB Docker Deployment Steps with the EB Cli

## Environment Configuration Steps

Docker saves us a lot of time when configuring the environment, but there are still a few pieces we need to make sure we get right.

1. **Be sure you have an EXPOSE line in your Dockerfile**

This part is a something the cli should warn you about during deployment, but sometimes it can be overlooked. The expose line will tell your elastic beanstalk instance to forward all traffic from port `80` to the exposed port in the docker container. For reference here is an example of a Dockerfile for a nodejs environment.

```
FROM node:10

ARG NODE_ENV=development
ENV NODE_ENV $NODE_ENV

RUN npm i npm@latest -g

WORKDIR /opt
COPY package.json ./
RUN npm install --no-optional && npm cache clean --force
ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/app

COPY . /opt/app

EXPOSE 3000

CMD ["node", "./dist/server.js"]
```

Here we are exposing port `3000` which is the port our server runs on. This allows for us to hit the application url to access our docker container!

2. **Setup your environment variables in the configuration section**

Whatever environment variables you need for production should be included in the elastic beanstalk configuration. This will mount them to your container without you having to worry about keeping an environment file up to date, or someone pushing invalid environment settings.

[EB Environment Configuration](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-cfg-console.html)

Your EB environment will automatically map any environment variables inserted in the bashboard to your application.

## Setting up your Dockerrun.aws.json

When you're ready to deploy your container to production, you will want to create a file called `Dockerrun.aws.json` in the root of your project. We can use this file to only deploy our built docker container from a saved repository. If you dont have a repository, I recommend using the aws ECR to store your built images. Here is an example json file:

```
{
  "AWSEBDockerrunVersion": 1,
  "Image": {
    "Name": "0123456789.some.url.to.repo/your-image:v1",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": 3000
    }
  ],
  "Volumes": [
    {
      "HostDirectory": "/home/ec2-user/dirToMount",
      "ContainerDirectory": "/dir/inContainer"
    }
  ]
}
```

This file is for a single docker container configuration. There a few things to note here:

1. The `AWSEBDockerrunVersion` is 1 for single container configuration.
2. `"Update": true` Tells your configuration to pull the image again even if the version doesn't change. This can be useful if you arn't version controlling your built iages properly!
3. `"Ports"` Here we list the ports our container uses, this needs to make the `EXPOSE` line in your Dockerfile.
4. `"Volumes"` If you need any folders or files to persist during a new deployment, they need to be included here. If you do not include any volumes, all data on the instance when EB is updated  **WILL BE DESTROYED**

Here is the aws documentation for single docker container configuration:

[AWS Single Docker Container EB Configuration](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/single-container-docker-configuration.html)

## Modifying your eb config.yml for deployment

In order for eb to only deploy our container and not the entire folder directory like we normally do, we need to adjust our `config.yml`. This file should be in the `.elasticbeanstalk` folder in the root of your project. It should look something like:

```
branch-defaults:
  deployment-setup:
    environment: SomeEnv-env
environment-defaults:
  TextATruck-env:
    branch: null
    repository: null
deploy:
  artifact: Dockerrun.aws.json
global:
  application_name: Some-Env
  default_ec2_keyname: null
  default_platform: arn:aws:elasticbeanstalk:us-west-2::platform/Docker running on
    64bit Amazon Linux/2.12.6
  default_region: us-west-2
  include_git_submodules: true
  instance_profile: null
  platform_name: null
  platform_version: null
  profile: null
  sc: git
  workspace_type: Application
```

The part that you will need to add is the section

```
deploy:
  artifact: Dockerrun.aws.json
```

This tells eb that when you run `eb deploy`, you only want to deploy the json configuration file. Since we use a built docker container, EB will read the config file, pull and build the image and expose what we need to run!

## Deployment

After you have the environment configured properly, it's time to deploy the application! Navigate to the root of your project and type:

`eb deploy <EnvironmentName>`

If you have deployed from your current branch before, the cli will use the last environment you deployed to. In this case, you can just type:

`eb deploy`

In order to save an environment to the current branch, you can use the following command:

`eb use <EnvironmentName>`

This saves the default environment to the project and current branch, allowing for easy deployment from staging and production branches. If you have any issues don't be afraid to reach out to your fellow developers, or read the docs for more info.

[EB Cli Documentation](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-getting-started.html#ebcli3-basics-deploy)