.PHONY: setup build build-in-container build-local clean deploy-init deploy-update deploy-remove test-lambda devenv-init devenv-up devenv-down devenv-remove

PROJECT_NAME = example-project
IMAGE_NAME = ${PROJECT_NAME}-image
DEVENV_CONTAINER_NAME = ${PROJECT_NAME}-devenv
TASK_NAME = aws-lambda-package-${PROJECT_NAME}
ZIP_FILE_PATH = build/${PROJECT_NAME}.zip
LAMBDA_FUNCTION_NAME = ${PROJECT_NAME}-function
LAMBDA_FUNCTION_EXECUTION_POLICY = ${PROJECT_NAME}-policy
LAMBDA_FUNCTION_EXECUTION_ROLE = ${PROJECT_NAME}-role
LAMBDA_FUNCTION_REGION = ap-northeast-1
LAMBDA_FUNCTION_MEMORY_SIZE = 128 

build: build-in-container

build-in-container:
	docker run --rm \
	-v $(shell pwd):/workspace \
	-v /etc/group:/etc/group:ro \
	-v /etc/passwd:/etc/passwd:ro \
	-u $(shell id -u ${USER}):$(shell id -g ${USER}) \
	${IMAGE_NAME} make build-local

build-local:
	mkdir -p build
	cd build && \
	cmake -G "Unix Makefiles" \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_SHARED_LIBS=ON \
		.. && \
	$(MAKE) -j && \
	$(MAKE) -j ${TASK_NAME}

setup:
	cd docker && docker build . -t ${IMAGE_NAME}

devenv-init:
	docker run \
	-v $(shell pwd):/workspace \
	-v /etc/group:/etc/group:ro \
	-v /etc/passwd:/etc/passwd:ro \
	-u $(shell id -u ${USER}):$(shell id -g ${USER}) \
	--name ${DEVENV_CONTAINER_NAME} \
	-itd \
	${IMAGE_NAME} /bin/sh
	docker container exec -u root ${DEVENV_CONTAINER_NAME} /bin/sh -c "mkdir -p /home/${USER} && chown ${USER}:${USER} /home/${USER}"

devenv-up:
	docker start ${DEVENV_CONTAINER_NAME}

devenv-down:
	docker stop ${DEVENV_CONTAINER_NAME}

devenv-remove:
	docker container rm ${DEVENV_CONTAINER_NAME}

clean:
	rm -r build

deploy-init:
	aws iam create-policy --policy-name ${LAMBDA_FUNCTION_EXECUTION_POLICY} --policy-document file://deploy/policy.json >> deploy.log
	aws iam create-role --role-name ${LAMBDA_FUNCTION_EXECUTION_ROLE} --assume-role-policy-document file://deploy/role.json >> deploy.log
	aws iam attach-role-policy --role-name ${LAMBDA_FUNCTION_EXECUTION_ROLE} --policy-arn arn:aws:iam::$(shell aws sts get-caller-identity --query 'Account' | tr -d '"'):policy/${LAMBDA_FUNCTION_EXECUTION_POLICY} >> deploy.log
	sleep 10
	aws lambda create-function \
		--region ${LAMBDA_FUNCTION_REGION} \
		--function-name ${LAMBDA_FUNCTION_NAME} \
		--zip-file fileb://${ZIP_FILE_PATH} \
		--role arn:aws:iam::$(shell aws sts get-caller-identity --query 'Account' | tr -d '"'):role/${LAMBDA_FUNCTION_EXECUTION_ROLE} \
		--handler main \
		--runtime provided.al2 \
		--memory-size ${LAMBDA_FUNCTION_MEMORY_SIZE} \
		>> deploy.log

deploy-update:
	aws lambda update-function-code \
		--function-name ${LAMBDA_FUNCTION_NAME} \
		--zip-file fileb://${ZIP_FILE_PATH} \
		>> deploy.log

deploy-remove:
	aws lambda delete-function \
		--function-name ${LAMBDA_FUNCTION_NAME} \
		>> deploy.log
	aws iam detach-role-policy --role-name ${LAMBDA_FUNCTION_EXECUTION_ROLE} --policy-arn arn:aws:iam::$(shell aws sts get-caller-identity --query 'Account' | tr -d '"'):policy/${LAMBDA_FUNCTION_EXECUTION_POLICY} >> deploy.log
	aws iam delete-role --role-name ${LAMBDA_FUNCTION_EXECUTION_ROLE} >> deploy.log
	aws iam delete-policy --policy-arn arn:aws:iam::$(shell aws sts get-caller-identity --query 'Account' | tr -d '"'):policy/${LAMBDA_FUNCTION_EXECUTION_POLICY} >> deploy.log

test-lambda:
	aws lambda invoke \
		--function-name ${LAMBDA_FUNCTION_NAME} \
		--payload fileb://test/test.json \
		--log-type Tail \
		--region ${LAMBDA_FUNCTION_REGION} \
		test-response.json \
		--query 'LogResult' | tr -d '"' | base64 -d > test.log