# EB Deployment Steps with the EB Cli

## Environment Configuration Steps



## Deployment

After you have the environment configured properly, it's time to deploy the application! Navigate to the root of your project and type:

`eb deploy <EnvironmentName>`

If you have deployed from your current branch before, the cli will use the last environment you deployed to. In this case, you can just type:

`eb deploy`

In order to save an environment to the current branch, you can use the following command:

`eb use <EnvironmentName>`

This saves the default environment to the project and current branch, allowing for easy deployment from staging and production branches. If you have any issues don't be afraid to reach out to your fellow developers, or read the docs for more info.

[EB Cli Documentation](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-getting-started.html#ebcli3-basics-deploy)