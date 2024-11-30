```table-of-contents
title: Содержание:
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

---

Доброго времени суток уважаемые хабравчане. Уже 3 года я работаю на проекте в котором мы используем Spring. Мне всегда было интересно разобраться с тем, как он устроен внутри. Я поискал статьи про внутреннее устройство Spring, но, к сожалению, ничего не нашел.  
  
Всех, кого интересует внутреннее устройство Spring, прошу под кат.  
  
На схеме изображены основные этапы поднятия ApplicationContext. В этом посте мы остановимся на каждом из этих этапов. Какой-то этап будет рассмотрен подробно, а какой-то будет описан в общих чертах.  
 
![Pic 1|500](/Media/Pictures/Spring_Inside/image_1.png)

#### 1. Парсирование конфигурации и создание BeanDefinition

  
После выхода четвертой версии спринга, у нас появилось четыре способа конфигурирования контекста:  

1. Xml конфигурация — ClassPathXmlApplicationContext(“context.xml”)
2. Конфигурация через аннотации с указанием пакета для сканирования — AnnotationConfigApplicationContext(“package.name”)
3. Конфигурация через аннотации с указанием класса (или массива классов) помеченного аннотацией @Configuration -AnnotationConfigApplicationContext(JavaConfig.class). Этот способ конфигурации называется — JavaConfig.
4. Groovy конфигурация — GenericGroovyApplicationContext(“context.groovy”)

  
Про все четыре способа очень хорошо написано [тут](http://habrahabr.ru/company/codefreeze/blog/218203/).  
  
Цель первого этапа — это создание всех _BeanDefinition_. _BeanDefinition_ — это специальный интерфейс, через который можно получить доступ к метаданным будущего бина. В зависимости от того, какая у вас конфигурация, будет использоваться тот или иной механизм парсирования конфигурации.  
  

##### Xml конфигурация

  
Для Xml конфигурации используется класс — _XmlBeanDefinitionReader_, который реализует интерфейс _BeanDefinitionReader_. Тут все достаточно прозрачно. _XmlBeanDefinitionReader_ получает _InputStream_ и загружает _Document_ через _DefaultDocumentLoader_. Далее обрабатывается каждый элемент документа и если он является бином, то создается _BeanDefinition_ на основе заполненных данных (id, name, class, alias, init-method, destroy-method и др.). Каждый _BeanDefinition_ помещается в Map. Map хранится в классе _DefaultListableBeanFactory_. В коде Map выглядит вот так.  
  

```java
/** Map of bean definition objects, keyed by bean name */
private final Map<String, BeanDefinition> beanDefinitionMap = new ConcurrentHashMap<String, BeanDefinition>(64);
```

  

##### Конфигурация через аннотации с указанием пакета для сканирования или JavaConfig

  
Конфигурация через аннотации с указанием пакета для сканирования или JavaConfig в корне отличается от конфигурации через xml. В обоих случаях используется класс _AnnotationConfigApplicationContext_.  
  

```java
new AnnotationConfigApplicationContext(JavaConfig.class);
```

  
или  
  

```java
new AnnotationConfigApplicationContext(“package.name”);
```

  
Если заглянуть во внутрь AnnotationConfigApplicationContext, то можно увидеть два поля.  
  

```java
private final AnnotatedBeanDefinitionReader reader;
private final ClassPathBeanDefinitionScanner scanner;
```

  
_ClassPathBeanDefinitionScanner_ сканирует указанный пакет на наличие классов помеченных аннотацией _[Component](https://habr.com/ru/users/component/)_ (или любой другой аннотацией которая включает в себя _[Component](https://habr.com/ru/users/component/)_). Найденные классы парсируются и для них создаются _BeanDefinition_.  
Чтобы сканирование было запущено, в конфигурации должен быть указан пакет для сканирования.  
  

```java
@ComponentScan({"package.name"})
```

  
или  
  

```xml
<context:component-scan base-package="package.name"/>
```

  
_AnnotatedBeanDefinitionReader_ работает в несколько этапов.  

1. Первый этап — это регистрация всех _@Configuration_ для дальнейшего парсирования. Если в конфигурации используются _Conditional_, то будут зарегистрированы только те конфигурации, для которых _Condition_ вернет true. Аннотация _Conditional_ появилась в четвертой версии спринга. Она используется в случае, когда на момент поднятия контекста нужно решить, создавать бин/конфигурацию или нет. Причем решение принимает специальный класс, который обязан реализовать интерфейс _Condition_.
2. Второй этап — это регистрация специального _BeanFactoryPostProcessor_, а именно _BeanDefinitionRegistryPostProcessor_, который при помощи класса _ConfigurationClassParser_ парсирует JavaConfig и создает _BeanDefinition_.

  

##### Groovy конфигурация

  
Данная конфигурация очень похожа на конфигурацию через Xml, за исключением того, что в файле не XML, а Groovy. Чтением и парсированием groovy конфигурации занимается класс _GroovyBeanDefinitionReader_.  
  

#### 2. Настройка созданных BeanDefinition

  
После первого этапа у нас имеется Map, в котором хранятся _BeanDefinition_. Архитектура спринга построена таким образом, что у нас есть возможность повлиять на то, какими будут наши бины еще до их фактического создания, иначе говоря мы имеем доступ к метаданным класса. Для этого существует специальный интерфейс _BeanFactoryPostProcessor_, реализовав который, мы получаем доступ к созданным _BeanDefinition_ и можем их изменять. В этом интерфейсе всего один метод.  
  

```java
public interface BeanFactoryPostProcessor {
	void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException;
}
```

  
  
Метод **postProcessBeanFactory** принимает параметром _ConfigurableListableBeanFactory_. Данная фабрика содержит много полезных методов, в том числе **getBeanDefinitionNames**, через который мы можем получить все BeanDefinitionNames, а уже потом по конкретному имени получить _BeanDefinition_ для дальнейшей обработки метаданных.  
  
Давайте разберем одну из родных реализаций интерфейса _BeanFactoryPostProcessor_. Обычно, настройки подключения к базе данных выносятся в отдельный property файл, потом при помощи _PropertySourcesPlaceholderConfigurer_ они загружаются и делается inject этих значений в нужное поле. Так как inject делается по ключу, то до создания экземпляра бина нужно заменить этот ключ на само значение из property файла. Эта замена происходит в классе, который реализует интерфейс _BeanFactoryPostProcessor_. Название этого класса — _PropertySourcesPlaceholderConfigurer_. Весь этот процесс можно увидеть на рисунке ниже.  
  
![Pic 2|800](/Media/Pictures/Spring_Inside/image_2.png)
  
Давайте еще раз разберем что же у нас тут происходит. У нас имеется _BeanDefinition_ для класса ClassName. Код класса приведен ниже.  
  

```java
@Component
public class ClassName {

    @Value("${host}")
    private String host;

    @Value("${user}")
    private String user;

    @Value("${password}")
    private String password;

    @Value("${port}")
    private Integer port;
} 
```

  
  
Если _PropertySourcesPlaceholderConfigurer_ не обработает этот _BeanDefinition_, то после создания экземпляра ClassName, в поле host проинжектится значение — "${host}" (в остальные поля проинжектятся соответствующие значения). Если _PropertySourcesPlaceholderConfigurer_ все таки обработает этот _BeanDefinition_, то после обработки, метаданные этого класса будут выглядеть следующим образом.  
  

```java
@Component
public class ClassName {

    @Value("127.0.0.1")
    private String host;

    @Value("root")
    private String user;

    @Value("root")
    private String password;

    @Value("27017")
    private Integer port;
} 
```

  
  
Соответственно в эти поля проинжектятся правильные значения.  
  
Для того что бы _PropertySourcesPlaceholderConfigurer_ был добавлен в цикл настройки созданных _BeanDefinition_, нужно сделать одно из следующих действий.  
  
Для XML конфигурации.  
  

```xml

<context:property-placeholder location="property.properties" />
```

  
Для JavaConfig.  
  

```java
@Configuration
@PropertySource("classpath:property.properties")
public class DevConfig {
	@Bean
	public static PropertySourcesPlaceholderConfigurer configurer() {
	    return new PropertySourcesPlaceholderConfigurer();
	}
}
```

  
  
_PropertySourcesPlaceholderConfigurer_ обязательно должен быть объявлен как static. Без static у вас все будет работать до тех пор, пока вы не попробуете использовать _@ Value_ внутри класса _@Configuration_.  
  

#### 3. Создание кастомных FactoryBean

  
_FactoryBean_ — это generic интерфейс, которому можно делегировать процесс создания бинов типа . В те времена, когда конфигурация была исключительно в xml, разработчикам был необходим механизм с помощью которого они бы могли управлять процессом создания бинов. Именно для этого и был сделан этот интерфейс. Для того что бы лучше понять проблему, приведу пример xml конфигурации.  
  

```xml

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="redColor" scope="prototype" class="java.awt.Color">
        <constructor-arg name="r" value="255" />
        <constructor-arg name="g" value="0" />
        <constructor-arg name="b" value="0" />
    </bean>
    
</beans>
```

  
  
На первый взгляд, тут все нормально и нет никаких проблем. А что делать если нужен другой цвет? Создать еще один бин? Не вопрос.  
  

```xml

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="redColor" scope="prototype" class="java.awt.Color">
        <constructor-arg name="r" value="255" />
        <constructor-arg name="g" value="0" />
        <constructor-arg name="b" value="0" />
    </bean>

    <bean id="green" scope="prototype" class="java.awt.Color">
        <constructor-arg name="r" value="0" />
        <constructor-arg name="g" value="255" />
        <constructor-arg name="b" value="0" />
    </bean>
    
</beans>
```

  
  
А что делать если я хочу каждый раз случайный цвет? Вот тут то и приходит на помощь интерфейс _FactoryBean_.  
  
Создадим фабрику которая будет отвечать за создание всех бинов типа — _Color_.  
  

```java
package com.malahov.factorybean;

import org.springframework.beans.factory.FactoryBean;
import org.springframework.stereotype.Component;

import java.awt.*;
import java.util.Random;

/**
 * User: malahov
 * Date: 18.04.14
 * Time: 15:59
 */
public class ColorFactory implements FactoryBean<Color> {
    @Override
    public Color getObject() throws Exception {
        Random random = new Random();
        Color color = new Color(random.nextInt(255), random.nextInt(255), random.nextInt(255));
        return color;
    }

    @Override 
    public Class<?> getObjectType() {
        return Color.class;
    }

    @Override
    public boolean isSingleton() {
        return false;
    }
}
```

  
  
Добавим ее в xml и удалим объявленные до этого бины типа — _Color_.  
  

```xml

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">
	
	<bean id="colorFactory" class="com.malahov.temp.ColorFactory"></bean>

</beans>
```

  
  
Теперь создание бина типа _Color.class_ будет делегироваться ColorFactory, у которого при каждом создании нового бина будет вызываться метод **getObject**.  
  
Для тех кто пользуется JavaConfig, этот интерфейс будет абсолютно бесполезен.  
  

#### 4. Создание экземпляров бинов

  
Созданием экземпляров бинов занимается _BeanFactory_ при этом, если нужно, делегирует это кастомным _FactoryBean_. Экземпляры бинов создаются на основе ранее созданных _BeanDefinition_.  
  
![Pic 3|600](/Media/Pictures/Spring_Inside/image_3.png)  
  

#### 5. Настройка созданных бинов

  
Интерфейс _BeanPostProcessor_ позволяет вклиниться в процесс настройки ваших бинов до того, как они попадут в контейнер. Интерфейс несет в себе несколько методов.  
  

```java
public interface BeanPostProcessor {
	Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
	Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
}
```

  
  
Оба метода вызываются для каждого бина. У обоих методов параметры абсолютно одинаковые. Разница только в порядке их вызова. Первый вызывается до init-метода, второй, после. Важно понимать, что на данном этапе экземпляр бина уже создан и идет его донастройка. Тут есть два важных момента:  

1. Оба метода в итоге должны вернуть бин. Если в методе вы вернете null, то при получении этого бина из контекста вы получите null, а поскольку через бинпостпроцессор проходят все бины, после поднятия контекста, при запросе любого бина вы будете получать фиг, в смысле null.
2. Если вы хотите сделать прокси над вашим объектом, то имейте ввиду, что это принято делать после вызова init метода, иначе говоря это нужно делать в методе **postProcessAfterInitialization**.

  
  
Процесс донастройки показан на рисунке ниже. Порядок в котором будут вызваны _BeanPostProcessor_ не известен, но мы точно знаем что выполнены они будут последовательно.  
  
![Pic 4|700](/Media/Pictures/Spring_Inside/image_4.png)
  
Для того, что бы лучше понять для чего это нужно, давайте разберемся на каком-нибудь примере.  
  
При разработке больших проектов, как правило, команда делится на несколько групп. Например первая группа разработчиков занимается написанием инфраструктуры проекта, а вторая группа, используя наработки первой группы, занимается написанием бизнес логики. Допустим второй группе понадобился функционал, который позволит в их бины инжектить некоторые значения, например случайные числа.  
  
На первом этапе будет создана аннотация, которой будут помечаться поля класса, в которые нужно проинжектить значение.  
  

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
public @interface InjectRandomInt {
    int min() default 0;
    int max() default 10;
}
```

  
  
По умолчанию, диапазон случайных числе будет от 0 до 10.  
  
Затем, нужно создать обработчик этой аннотации, а именно реализацию _BeanPostProcessor_ для обработки аннотации _InjectRandomInt_.  
  

```java
@Component
public class InjectRandomIntBeanPostProcessor implements BeanPostProcessor {

    private static final Logger LOGGER = LoggerFactory.getLogger(InjectRandomIntBeanPostProcessor.class);

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {

        LOGGER.info("postProcessBeforeInitialization::beanName = {}, beanClass = {}", beanName, bean.getClass().getSimpleName());

        Field[] fields = bean.getClass().getDeclaredFields();

        for (Field field : fields) {
            if (field.isAnnotationPresent(InjectRandomInt.class)) {
                field.setAccessible(true);
                InjectRandomInt annotation = field.getAnnotation(InjectRandomInt.class);
                ReflectionUtils.setField(field, bean, getRandomIntInRange(annotation.min(), annotation.max()));
            }
        }

        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        return bean;
    }

    private int getRandomIntInRange(int min, int max) {
        return min + (int)(Math.random() * ((max - min) + 1));
    }
}
```

  
  
Код данного _BeanPostProcessor_ достаточно прозрачен, поэтому мы не будем на нем останавливаться, но тут есть один важный момент.  
  
_BeanPostProcessor_ обязательно должен быть бином, поэтому мы его либо помечаем аннотацией _[Component](https://habr.com/ru/users/component/)_, либо регестрируем его в xml конфигурации как обычный бин.  
  
Первая группа разработчиков свою задачу выполнила. Теперь вторая группа может использовать эти наработки.  
  

```java
@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class MyBean {

    @InjectRandomInt
    private int value1;

    @InjectRandomInt(min = 100, max = 200)
    private int value2;

    private int value3;

    @Override
    public String toString() {
        return "MyBean{" +
                "value1=" + value1 +
                ", value2=" + value2 +
                ", value3=" + value3 +
                '}';
    }
}
```

  
  
В итоге, все бины типа _MyBean_, получаемые из контекста, будут создаваться с уже проинициализированными полями value1 и value2. Также тут стоить отметить, этап на котором будет происходить инжект значений в эти поля будет зависеть от того какой _@ Scope_ у вашего бина. _SCOPE_SINGLETON_ — инициализация произойдет один раз на этапе поднятия контекста. _SCOPE_PROTOTYPE_ — инициализация будет выполняться каждый раз по запросу. Причем во втором случае ваш бин будет проходить через все BeanPostProcessor-ы что может значительно ударить по производительности.  
