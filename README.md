aws ecs execute-command --cluster my-app-cluster-dev \
--task d1b5eed287114c3bb26639746f955507 \
--container my-app-container-frontend \
--interactive \
--command "ls -al /data" 