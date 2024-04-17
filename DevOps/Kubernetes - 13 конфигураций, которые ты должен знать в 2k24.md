[Автор оригинала: DavidW (skyDragon)](https://overcast.blog/13-kubernetes-configurations-you-should-know-in-2024-54eec72f307e)

Поскольку Kubernetes продолжает оставаться краеугольным камнем оркестрации контейнеров, освоение его механизмов и возможностей становится обязательным для специалистов DevOps. В 2024 году некоторые конфигурации Kubernetes выделяются среди прочих благодаря функциональности в части автоматизации и безопасности, а также улучшения производительности в облачных (cloud-native) окружениях. В данной статье рассматриваются 13 ключевых конфигураций Kubernetes – предлагается погружение в каждую из них со сценариями применения, преимуществами и примерами кода.
## 1. Запросы и лимиты ресурсов

Понимание и корректная настройка запросов (requests) и лимитов (limits) на использование ресурсов являются основополагающими в Kubernetes. Запросы и лимиты гарантируют, что ваши приложения получают ресурсы, необходимые им для работы, и в то же время предотвращают утилизацию всех ресурсов кластера каким-нибудь одним приложением.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sample-app
spec:
  containers:
  - name: app-container
    image: nginx
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

- Зачем нужно: увеличение стабильности и производительности как отдельных приложений, так и кластера в целом. Предотвращение конкуренции за ресурсы и гарантия того, что приложения не будут неожиданно завершены (terminated) из-за нехватки ресурсов
- Кому полезно: администраторам и разработчикам Kubernetes, стремящимся оптимизировать производительность приложений и использование ресурсов кластера
- Когда применять: настройка запросов и лимитов требуется для всех приложений, исполняемых в кластере (рабочей нагрузки, workload). Правильная конфигурация обеспечивает предсказуемую производительность и предотвращает потребление одним приложением непропорционально большого количества ресурсов с влиянием на стабильность всего кластера
- Документация: [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
## 2. Проверки живости и готовности

Настройка проверок живости (liveness probe) и готовности (readiness probe) критически важна для управления жизненным циклом ваших приложений в Kubernetes. Они помогают Kubernetes принимать решения о том, когда нужно перезапустить контейнер (определяют живость) и когда контейнер готов начать обрабатывать трафик (определяют готовность).

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 3
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

- Зачем нужно: повышение отказоустойчивости и доступности ваших приложений гарантией, что Kubernetes сможет автоматически управлять состоянием контейнеров на основе фактической работоспособности приложения, а не только состояния среды выполнения контейнера
- Кому полезно: разработчикам и операторам, публикующим критически важные сервисы, для которых обязательны высокая доступность и самовосстановление
- Когда применять: настройка проверки живости требуется приложениям, для которых критичны максимальная доступность и минимальное время простоев. Настройка проверки готовности требуется приложениям, которые должны получать трафик только после полной инициализации и подтверждения готовности обрабатывать запросы
- Документация: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
## 3. Словари конфигурации и секреты

Словари конфигурации (Config Maps) и секреты (Secrets) необходимы для вывода параметров конфигурации и конфиденциальных данных из кода приложения. Словари конфигурации позволяют хранить в формате ключ-значение открытые данные, а секреты – конфиденциальную информацию.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.json: |
    {
        "database": "sql",
        "timeout": "30s",
        "featureFlag": "true"
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=
```

- Зачем нужно: отсоединение параметров конфигурации и секретов от логики приложения, упрощение развертывания приложений и управления ими в различных средах вкупе с повышением уровня безопасности
- Кому полезно: любому пользователю Kubernetes, управляющему приложениями, которым требуются конфигурационные данные или нужно безопасно обрабатывать учетные данные и другую чувствительную информацию
- Когда применять: словари конфигурации используются для задания параметров приложения, которые изменяются в зависимости от среды (dev, staging, production). Секреты используются для учетных данных, токенов и др. чувствительной информации
- Документация: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/), [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
## 4. Горизонтальное автомасштабирование

Горизонтальное автомасштабирование подов (Horizontal Pod Autoscaler, HPA) автоматически регулирует количество реплик подов в развертывании (Deployment), наборе реплик (ReplicaSet) или наборе реплик с сохранением состояния (StatefulSet) на основе утилизации процессора или пользовательских метрик.

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: sample-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sample-app
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

- Зачем нужно: гарантированное горизонтальное масштабирование в зависимости от текущей нагрузки, оптимальное использование ресурсов и обеспечение производительности
- Кому полезно: администраторам и специалистам DevOps, которые стремятся автоматизировать масштабирование приложений в зависимости от потребностей в реальном времени
- Когда применять: настройка горизонтального автомасштабирования идеально подходит для приложений с переменным трафиком. Она обеспечивает динамическое распределение ресурсов для удовлетворения спроса без ручного вмешательства
- Документация: [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
## 5. Сетевые политики

Сетевые политики (Network Policies) – это ресурсы Kubernetes, которые управляют потоком трафика между подами и оконечными точками сети (network endpoints), позволяя реализовать микросегментацию и повысить безопасность ваших приложений Kubernetes.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

- Зачем нужно: обеспечение безопасности обмена данными между подами внутри кластера Kubernetes – между модулями или к внешним сервисам будет передаваться только разрешенный (authorized) трафик
- Кому полезно: администраторам Kubernetes и инженерам ИБ, которым необходимо применять строгие политики сетевой безопасности в своих кластерах
- Когда применять: настройка сетевых политик особенно полезна в многопользовательских (multi-tenant) средах или приложениях с высокими требованиями к безопасности для предотвращения несанкционированного доступа и ограничения потенциальных векторов атак
- Документация: [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
## 6. Учетные записи служб

Учетные записи служб (Service Accounts) в Kubernetes используются для идентификации подов при взаимодействии с Kubernetes API и другими сервисами (_ресурсами – прим. пер._) внутри кластера. Они критичны для управления доступом и обеспечения безопасного межсервисного взаимодействия.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

- Использование учетной записи в поде:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
  serviceAccountName: my-service-account
```

- Зачем нужно: назначение подам учетной записи позволяет осуществлять детализированный контроль доступа и аудит работы. Учетные записи также необходимы для предоставления доступа к Kubernetes API и другим ресурсам кластера
- Кому полезно: администраторам кластера Kubernetes и разработчикам, которым необходимо безопасно управлять доступом к серверу API и ресурсам Kubernetes из подов
- Когда применять: учетные записи используются для развертывания приложений, которым требуется взаимодействовать с Kubernetes API или проходить аутентификацию в других сервисах внутри кластера. Это могут быть задания автоматизации или микросервисы, которым требуются специфические разрешения
- Документация: [Configure Service Accounts for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
## 7. Ingress ресурсы и Ingress контроллеры

Ingress ресурсы и Ingress контроллеры (_простите, я не смог найти адекватную адаптацию слова Ingress – прим. пер._) управляют внешним доступом к сервисам в кластере, обычно с помощью протокола HTTP. Они позволяют определять правила маршрутизации трафика к различным сервисам.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

- Зачем нужно: предоставление централизованного, масштабируемого и безопасного метода управления доступом к вашим сервисам Kubernetes из Интернета (_извне кластера – прим. пер._)
- Кому полезно: специалистам DevOps и администраторам Kubernetes,которые управляют общедоступными (public-facing) приложениями
- Когда применять: Ingress контроллеры и ресурсы Ingress являются обязательными для любого приложения, которое требует контролируемого доступа извне кластера Kubernetes. Особенно актуальны при управлении несколькими сервисами или выполнении маршрутизации на основе URL
- Документация: [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/), [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
## 8. Постоянные тома

Постоянные тома (Persistent Volumes, PV) и заявки на выделение постоянного тома (Persistent Volume Claims, PVC) являются удобными инструментами для управления хранилищем в Kubernetes, которые абстрагируют детали хранения данных и работы с ними.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /path/to/data
    server: nfs-server.example.com
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

- Зачем нужно: постоянное хранение данных для приложений с сохранением состояния (stateful applications) за пределами жизненного цикла пода
- Кому полезно: инженерам, которые работают в Kubernetes с БД, файловым хранилищем и др. приложениями с сохранением состояния
- Когда применять: PV и PVC используются, когда приложению требуется постоянное хранение данных, независимое от жизненного цикла пода. Это обеспечивает долговечность и доступность данных
- Документация: [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
## 9. Управление доступом на основе ролей

Управление доступом на основе ролей (Role-Based Access Control, RBAC) позволяет применять детализированные политики контроля доступа к ресурсам Kubernetes с помощью ролей (roles) и привязок ролей (role binding) для ограничения разрешений внутри кластера.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: "jane"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

- Зачем нужно: соблюдение принципа наименьших привилегий во всем кластере Kubernetes. Данный принцип гарантирует, что пользователи и приложения будут иметь только те разрешения, которые им необходимы
- Кому полезно: администраторам кластера и инженерам, которые заботятся об ИБ и внедряют политики безопасного доступа
- Когда применять: RBAC применяется, когда необходимо обеспечить безопасный доступ к ресурсам Kubernetes, особенно в средах с несколькими пользователями или командами
- Документация: [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
## 10. Пользовательские определения ресурсов

Пользовательские определения ресурсов (Custom Resource Definitions, CRD) позволяют расширять Kubernetes API с помощью самописных дополнительных ресурсов и, таким образом, добавлять новые функциональные возможности, которые необходимы именно вам.

```yaml
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  names:
    kind: CronTab
    listKind: CronTabList
    plural: crontabs
    singular: crontab
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              cronSpec:
                type: string
              image:
                type: string
```

- Зачем нужно: создание собственных объектов и управление ими, простая интеграция с программными интерфейсами Kubernetes и инструментами kubectl
- Кому полезно: разработчикам и операторам, которые хотят внедрить пользовательские операции или ресурсы в свою среду Kubernetes
- Когда применять: CRD позволяют расширять возможности Kubernetes, когда существующие ресурсы не соответствуют специфическим потребностям приложения
- Документация: [Extend the Kubernetes API with CustomResourceDefinitions](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/)
## 11. Ограничения и допуски

Ограничения (Taints) и допуски (Tolerations) работают вместе, чтобы гарантировать, что поды не будут запущены на неподходящих узлах кластера.

```yaml
apiVersion: v1
kind: Node
metadata:
  name: node1
spec:
  taints:
  - key: "key1"
    value: "value1"
    effect: NoSchedule
```

- Зачем нужно: управление размещением подов на узлах с учетом особенностей аппаратного и программного обеспечения, а также иных пользовательских требований
- Кому полезно: администраторам кластеров, которые стремятся оптимизировать распределение рабочей нагрузки и обеспечить разделение пользовательских окружений
- Когда применять: ограничения и допуски используются для предотвращения выполнения некоторых задач на определенных узлах и, таким образом, выделения этих узлов для специфической рабочей нагрузки
- Документация: [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
## 12. Сходство и антисходство

Настройки сходства (affinity) и антисходства (anti-affinity) позволяют вам контролировать, где поды должны (или не должны) размещаться относительно других подов.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: with-pod-affinity
spec:
  selector:
    matchLabels:
      app: with-pod-affinity
  template:
    metadata:
      labels:
        app: with-pod-affinity
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: security
                operator: In
                values:
                - S1
            topologyKey: "kubernetes.io/hostname"
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: security
                  operator: In
                  values:
                  - S2
              topologyKey: "kubernetes.io/hostname"
```

- Зачем нужно: управление распределением подов по кластеру для повышения отказоустойчивости, доступности или удовлетворения других эксплуатационных требований
- Кому полезно: администраторам и разработчикам, которые хотят настроить распределение подов для оптимизации производительности или соответствия нормативным требованиям
- Когда применять: настройки сходства и антисходства обеспечивают высокую доступность и распределение рабочей нагрузки в соответствии с требованиями безопасности или другими условиями
- Документация: [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
## 13. Выполнение заданий по расписанию

Задания (Jobs) управляют задачами, которые должны быть запущены разово, а задания Cron (CronJobs) – задачами, которые необходимо запускать по расписанию.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: example-job
spec:
  template:
    spec:
      containers:
      - name: hello
        image: busybox
        command: ["sh", "-c", "echo Hello Kubernetes! && sleep 30"]
      restartPolicy: Never
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: example-cronjob
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["sh", "-c", "echo Hello Kubernetes! && sleep 30"]
          restartPolicy: OnFailure
```

- Зачем нужно: автоматизация таких задач в Kubernetes, как резервное копирование, техническое обслуживание или пакетное выполнение
- Кому полезно: инженерам, которые автоматизируют рутинные задачи или выполняют пакеты заданий в окружениях Kubernetes
- Когда применять: задания и задания Cron позволяют запускать задания разово или по расписанию  
- Документация: [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/), [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
## Резюме

Перечисленные конфигурации Kubernetes являются основой для создания надежных, эффективных и безопасных облачных приложений. Понимание и практическое применение этих настроек позволит в полной мере использовать возможности Kubernetes, адаптировать развертывания под конкретные задачи и придерживаться оптимальных стандартов эксплуатации.
