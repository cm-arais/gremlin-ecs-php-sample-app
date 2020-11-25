docker-run-gremlin:
	docker run -d --rm --net=host \
		--name gremlin-deamon \
		--cap-add=NET_ADMIN --cap-add=SYS_BOOT --cap-add=SYS_TIME \
		--cap-add=KILL \
		-v /tmp/gremlin/var/lib/gremlin:/var/lib/gremlin \
		-v /tmp/gremlin/var/log/gremlin:/var/log/gremlin \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e GREMLIN_TEAM_ID="${GREMLIN_TEAM_ID}" \
		-e GREMLIN_TEAM_SECRET="${GREMLIN_TEAM_SECRET}" \
		gremlin/gremlin daemon

docker-stop-gremlin:
	docker stop gremlin-deamon

docker-push:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
	docker-compose build nginx php
	docker tag arai-nginx:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/nginx:latest
	docker tag arai-php:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/php:latest
	docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/nginx:latest
	docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/php:latest

docker-push-nginx:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
	docker-compose build nginx
	docker tag arai-nginx:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/nginx:latest
	docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/nginx:latest

docker-push-php:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
	docker-compose build php
	docker tag arai-php:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/php:latest
	docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/php-app-repo/php:latest


deploy-repo:
	aws cloudformation deploy \
		--template-file cloudformation/template-for-ecr.yml \
		--stack-name php-repo-stack

deploy-infra:
	@aws cloudformation deploy \
		--template-file cloudformation/template.yml \
		--stack-name php-app-stack \
		--parameter-overrides \
			GremlinTeamId=${GREMLIN_TEAM_ID} \
			GremlinTeamSecret=${GREMLIN_TEAM_SECRET} \
		--capabilities CAPABILITY_NAMED_IAM
