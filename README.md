# aws-lambda-cpp-template

[➥日本語版: Japanese Version](README_ja.md)

## Why & What

You might want to write AWS lambda functions with C++ language.  
C++ will help you write code that runs with good performance.  
However, it is less common to use C++ for AWS lambda than Python, node or other script languages and it is somehow hard to setup development environment.  
This is a template project for AWS lambda with C++.  
I hope this would help you setup development environment.

## Spirit

- Simple than perfect.
- It is not that one YAML configuration file produces perfect setup, but that developers have a complete access to every file and they are responsible for all files. I think it is easier for C++ developers to write common files like CMakeLists.txt or makefile than edit strange YAML files.
- Docker image size may become large, it is OK. If you don't like this, edit Dockerfile, yes.

## Required tools

- make: as a task runner.
- docker: for a reproducible development environment.
- aws cli: for simple deploy and test. (It is better to integrate this project to your IaC project. In that case, you don't necessarily require aws cli.)

## The first thing you have to do; Change the project name.

Edit the two lines below.

```
makefile:3 PROJECT_NAME = example-project
```

```
CMakeLists.txt:4 project(example-project LANGUAGES CXX)
```

## Setup build environment

Build the docker image in which C++ code will be built.

```
make setup
```

## Build the project

Build is done in an ephemeral docker container.

```
make
```

`build/${PROJECT_NAME}.zip` will be generated.  
This is the deployable output.

## Deploy the output (first time only)

This template provides a simple deploy command.  
Genrally speaking, this is too simple to use for production.  
For example, this creates an IAM policy which goes against the principle of least privilege by default.  
It is recommended to use these scripts only for just trial and integrate the project to your IaC project at your own risk.

```
make deploy-init
```

The log will be written to `deploy.log`. Check it.

## Test the deployed AWS Lambda function

This command will invoke the deployed Lambda function with the input of `test/test.json` and write the response to `test-response.json` and the log to `test.log`.

```
make test-lambda
```

## Edit the source code

Edit the code in `src/` and reflect the file addition/deletion in `CMakeListst.txt`.  
It is your choice whether to use glob or not.

## Add libraries

Edit `docker/Dockerfile` to install libraries to the build environment, and edit `CMakeListst.txt` to use them.

Do not forget run `make setup` again when you edit Dockerfile.


## Deploy updated AWS Lambda function

```
make deploy-update
```

The log will be written to `deploy.log`. Check it.


## Edit the source code with VSCode

Run the following command, then the container for development will start.  
```
make devenv-init
```

In VSCode, go to Remote Explorer -> containers -> Attach aws-lambda-cpp-[project name]-devenv -> Open `/workspace`.  
You can install C++ extensions in the container.

When you want to stop the container for development,

```
make devenv-down
```

When you want to restart it,

```
make devenv-up
```

When you want to build the C++ project in the container,

```
make build-local
```
