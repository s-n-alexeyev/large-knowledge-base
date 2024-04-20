При работе с Kubernetes очень важно знать хотя бы основные команды. В этой статье вы найдете команды, которые чаще всего нужны при работе с кластером.

В этой статье вы увидите не только команды для получения подробной информации об объектах, но и для создания объектов. Эта статья посвящена только командам, а не их описанию. Если вы хотите подробно ознакомиться с каждой командой, вы можете посетить официальную документацию [здесь](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply).

Эта статья станет для вас шпаргалкой по основным объектам кластера Kubernetes.

## Важные команды

### Информация о кластере

>Вывод информации о версии клиента и сервера
```shell
kubectl version
```

>Вывод поддерживаемых ресурсов API на сервере
```shell
kubectl api-resources
```

>Вывод поддерживаемых версий API на сервере, в виде «group/version»
```shell
kubectl api-versions
```

>Получение информации о кластере
```shell
kubectl cluster-info
```

>Получение списка узлов в кластере
```shell
kubectl get nodes
```

>Получение информации о главном узле
```shell
kubectl get nodes master -o wide
```

>Получение подробной информации о главных узлах
```shell
kubectl describe nodes master
```
### Информация о конфигурации

>Отображать всех настроек kubeconfig
```shell
kubectl config view
```

>Просмотр текущего контекста
```shell
kubectl config current-context
```

>Показать кластеры, определенные в kubeconfig
```shell
kubectl config get-clusters
```

>Описать один или много контекстов
```shell
kubectl config get-contexts
```

### Пространства имен

>Показать все пространства имен
```shell
kubectl get namespaces
```

>Показать информацию о пространстве имен в формате yaml
```shell
kubectl get namespaces -...o yaml
```

>Описать пространство имен по умолчанию
```shell
kubectl describe namespace default
```

>Создать новое пространство имен
```shell
kubectl create namespace my-namespace
```

>Удалить пространство имен
```shell
kubectl delete namespace my-namespace
```

### Модули

>Показать модули из текущего пространства имен
```shell
kubectl get pods
```

>Получать модули из всех пространств имен
```shell
kubectl get pods --all-namespaces
```

>Получите pods из указанного пространства имен
```shell
kubectl get pods -namespace=my-namespace
```

>Создать модуль
```shell
kubectl run my-pod-1 --image=nginx:latest --dry-run
```

>Посмотреть, как будет обрабатываться pod
```shell
kubectl run my-pod-1 --image=nginx:latest --dry-run=client
```

>Создать pod в указанном пространстве имен
```shell
kubectl run my-pod-2 --image=nginx:latest --namespace=my-namespace
```

>Создать pod с меткой к нему
```shell
kubectl run nginx --image=nginx -l --labels=app=test
```

>Показать все pod с выводом меток
```shell
kubectl get pods...-show-labels
```

>Показать pods с расширенным/широким выводом
```shell
kubectl get pods -o wide
```

>Перечислить pods в отсортированном порядке
```shell
kubectl get pods --sort-by=.metadata.name
```

>Получение журналов pod
```shell
kubectl logs my-pod-1
```

>Получение pods в указанном пространстве имен с расширенным/широким выводом
```shell
kubectl get pods my-pod-2 --namespace=my-namespace -o wide
```

>Получение журналов pod в указанном пространстве имен
```shell
kubectl logs my-pod-2 --namespace=my-namespace
```

>Описание pod
```shell
kubectl describe pod my-pod-1
```

>Описание pod в указанном пространстве имен
```shell
kubectl describe pods my-pod-1 --namespace=my-namespace
```

>Удалить pod из текущего пространства имен
```shell
kubectl delete pod my-pod-1
```

>Удалить pod из указанного пространства имен
```shell
kubectl delete pods my-pod-1 --namespace=my-namespace
```

### Развертывания

>Получение списка развертываний из текущего пространства имен
```shell
kubectl get deployments
```

>Получение списка развертываний из указанного пространства имен
```shell
kubectl get deployments --namespace=my-пространство имен
```

>Создать развертывание
```shell
kubectl create deployment my-deployment-1 --image=nginx
```

>Показать указанное развертывание
```shell
kubectl get deployment my-deployment-1
```

>Показать указанное развертывание с его метками
```shell
kubectl get deployment my-deployment-1 --show-labels
```

>Описание указанного развертывания
```shell
kubectl describe deployments my-deployment-1
```

>Получите подробную информацию о развертывании в формате yaml
```shell
kubectl get deployment my-deployment-1 -o yaml
```

>Изменение образа в существующем развертывании
```shell
kubectl set image deployment my-deployment-1 nginx=nginx:1.16.1
```

>Просмотр истории развертывания
```shell
kubectl rollout history deployment my-deployment-1
```

>Отмена предыдущего развертывания
```shell
kubectl rollout undo deployment my-deployment-1
```

>Возврат к определенной версии истории развертывания
```shell
kubectl rollout undo deployment my-deployment-1 --to-revision=2
```

>Показать статус развертывания
```shell
kubectl rollout status deployment my-deployment-1
```

>Перезапустить ресурс
```shell
kubectl rollout restart deployment my-deployment-1
```

>Масштабировать развертывание до 3
```shell
kubectl scale --replicas=3 deployment my-deployment-1
```

>Масштабировать с текущего количества до нужного
```shell
kubectl scale --current-replicas=3 --replicas=5 deployment my-deployment-1
```

>Это создаст HPA (Horizontal Pod Aotuscaler)
```shell
kubectl autoscale deployment my-deployment-1 --min=2 --max=10
```

### Services

Сначала создайте pod с меткой app=myapp.

Затем:

>Создаем pod с меткой
```shell
kubectl run my-pod --image=nginx --labels=app=myapp
```

>Создаем сервис типа NodePort, который будет использовать метки pod для селектора, но нам нужно указать тип, поэтому сначала создайте файл определения, а затем создайте сервис
```shell
kubectl expose pod my-pod --port=80 --name nginx-service --type=NodePort --dry-run=client -o yaml
```

>Создайте сервис, который будет иметь тип NodePort, но у него не будет селектора как у my-app
```shell
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml
```

>Показать службы из текущего контекста
```shell
kubectl get service
```

>Показать подробную информацию о службах
```shell
kubectl get service -o wide
```

>Показать службы с метками на них
```shell
kubectl get service --show-labels
```

>Получите сервисы из всех пространств имен
```shell
kubectl get services --all-namespaces
```

>Описание сервис, чтобы узнать о нем больше
```shell
kubectl describe service nginx-service
```

>Получите конкретный сервис
```shell
kubectl get service nginx-service
```

Удаление сервиса
```shell
kubectl delete service nginx-service
```
### Управление объектами из файлов .yaml/.yml

Сначала создайте файл определения для pod

>Создайте файл определения для pod
```shell
kubectl run mypod --image=nginx --dry-run=client -o yaml > my-pod.yml
```

>Создайте объект
```shell
kubectl create -f my-pod.yml
```

>Удаление объекта
```shell
kubectl delete -f my-pod.yml
```
## Заключение

В этой статье мы рассмотрели важные команды, которые необходимы при работе с Kubernetes.
