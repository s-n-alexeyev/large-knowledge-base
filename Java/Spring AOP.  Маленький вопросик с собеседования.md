овелось мне тут на днях побывать на очередном собеседовании. И задали мне там вот такой вот вопрос. Что на самом деле выполнится (с точки зрения транзакций), если вызвать method1()?  
  

```java
public class MyServiceImpl {
  
  @Transactional
  public void method1() {
    //do something
    method2();
  }

  @Transactional (propagation=Propagation.REQUIRES_NEW)
  public void method2() {
    //do something
  }
}
```

  
Ну, мы же все умные, документацию читаем или, по крайней мере, видео выступлений Евгения Борисова смотрим. Соответственно и правильный* ответ знаем (правильный* — это такой, который от нас ожидает услышать тот, кто спрашивает). И звучать он должен примерно так.  
  
«_В связи с тем, что для поддержки транзакций через аннотации используется Spring AOP, в момент вызова method1() на самом деле вызывается метод прокси объекта. Создается новая транзакция и далее происходит вызов method1() класса MyServiceImpl. А когда из method1() вызовем method2(), обращения к прокси нет, вызывается уже сразу метод нашего класса и, соответственно, никаких новых транзакций создаваться не будет_».  
  
Но знаете, как это бывает, вроде и ответ правильный уже давно знаешь. И применяешь это знание регулярно. А вдруг раз… и неожиданно задумаешься: «_Подождите-ка, ведь если мы используем Spring AOP, то там могут создаваться прокси и через JDK, а могут и с CGLIB; а еще возможно, что CTW или LTW подключили. И что такой ответ всегда будет верен?_».  
  
Ну что ж: интересно? Надо проверить.  
  
На самом деле меня заинтересовало не то, как будут транзакции создаваться, а само утверждение, что Spring AOP всегда создает прокси-объекты, и эти прокси-объекты имеют описанное выше поведение. Очевидно, что если для создания оберток используется JDK dynamic proxy, то это утверждение должно быть верным. Ведь в этом случае объекты создаются на основе интерфейсов. Такой объект будет полностью соответствовать паттерну Proxy и все выглядит вполне логично. Но CGLib использует другой подход, он создает классы наследники. А тут уже и начинают закрадываться сомнения, будет ли поведение идентичным. Еще интереснее всё становиться, когда мы решаем использовать внешние инструменты для связывания, т.е. CTW (compile-time weaving) и LTW (load-time weaving).  
  
Для начала добавлю сюда пару определений из документации по Spring AOP, которые наиболее интересны в контексте того, что мы рассматриваем (собственно все остальные определения можно найти в самой документации, например вот [здесь](https://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/aop.html#aop-understanding-aop-proxies))  

> - AOP proxy: an object created by the AOP framework in order to implement the aspect contracts (advise method executions and so on). In the Spring Framework, an AOP proxy will be a JDK dynamic proxy or a CGLIB proxy.
> - Weaving: linking aspects with other application types or objects to create an advised object. This can be done at compile time (using the AspectJ compiler, for example), load time, or at runtime. Spring AOP, like other pure Java AOP frameworks, performs weaving at runtime.
> 
>   

Теперь создадим простейший проект, на котором и будем проводить эксперименты. Для этого используем Spring Boot. Поскольку для разработки я использую STS, то опишу шаги именно для этой IDE. Но, по большому счету, все будет примерно также и для других инструментов.  
  
Запускаем визард создания Spring Boot проекта: File > New > Spring Starter Project. И заполняем форму:  
  

- **Name**: AOPTest;
- **Type**: Maven;
- **Packaging**: Jar;
- **Java version**: 8;
- **Language**: Java;
- **Group**: com.example.AOPTest;
- **Artifact**: AOPTest;
- **Package**: com.example.AOPTest.

  
Остальное по вкусу. Нажимаем кнопку Next, и снова заполняем:  
  

- **Spring Boot Version**: 2.0.0.M7 (а почему бы и нет? Это последняя доступная версия на момент написания статьи). Чем собственно хорош Spring Boot, так это тем, что в минимальном виде он включает все необходимые зависимости и определения. Нам только надо указать, что именно из Спринга мы будем использовать.
- На этом же шаге, в списке доступных зависимостей, находим Aspects (можно воспользоваться фильтром) и добавляем его.

  
Нажимаем Finish. Наше приложение готово. Созданный pom’ник должен выглядеть примерно так.  
  

```java
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example.AOPTest</groupId>
  <artifactId>AOPTest</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>

  <name>AOPTest</name>
  <description></description>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.0.0.M7</version>
    <relativePath/> <!-- lookup parent from repository -->
  </parent>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <java.version>1.8</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-aop</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
    </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>

</project>
```

  
На самом деле, в связи с тем, что мы используем milestone версию, код будет чуть больше, будут добавлены ссылки на репозитарии.  
  
Также будет сгенерирован класс приложения.  
  

```java
package com.example.AOPTest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AopTestApplication {

  public static void main(String[] args) {
    SpringApplication.run(AopTestApplication.class, args);
  }

}
```

  
Наша аннотация (поскольку, как я уже сказал, нам интересны не транзакции, а то, как будет обрабатываться такая ситуация, то мы создаём свою аннотацию):  
  

```java
package com.example.AOPTest;

import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;

@Retention(RUNTIME)
@Target(METHOD)
public @interface Annotation1 {
}
```

  
И аспект  
  

```java
package com.example.AOPTest;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class MyAspect1 {

  @Pointcut("@annotation(com.example.AOPTest.Annotation1)")
  public void annotated() {}
  
  @Before("annotated()")
  public void printABit() {
    System.out.println("Aspect1");
  }
}
```

  
Собственно создали аспект, который будет привязываться к методам, имеющим аннотацию @Annotation1. Перед исполнением таких методов в консоль будет выводиться текст “Aspect1”.  
Обращу внимание, что сам класс также аннотирован как [Component](https://habrahabr.ru/users/component/). Это необходимо для того, что бы Spring мог найти этот класс и создать на его основе бин.  
  
А теперь уже можно добавить и наш класс.  
  

```java
package com.example.AOPTest;

import org.springframework.stereotype.Service;

@Service
public class MyServiceImpl {

  @Annotation1
  public void method1() {
    System.out.println("method1");
    method2();
  }

  @Annotation1
  public void method2() {
    System.out.println("method2");
  }
}
```

  
С целями, задачами и инструментами определились. Можно приступать к экспериментам.  
  

## JDK dynamic proxy vs CGLib proxy

  
Если обратиться к документации то можно найти там следующий текст.  

> Spring AOP uses either JDK dynamic proxies or CGLIB to create the proxy for a given target object. (JDK dynamic proxies are preferred whenever you have a choice).  
> If the target object to be proxied implements at least one interface then a JDK dynamic proxy will be used. All of the interfaces implemented by the target type will be proxied. If the target object does not implement any interfaces then a CGLIB proxy will be created.  
> If you want to force the use of CGLIB proxying (for example, to proxy every method defined for the target object, not just those implemented by its interfaces) you can do so.  
> To force the use of CGLIB proxies set the value of the proxy-target-class attribute of the <aop:config> element to true  

Т.е., согласно документации, для создания прокси объектов может использоваться как JDK так и CGLib, но предпочтение должно отдаваться JDK. И, если класс имеет хотя бы один интерфейс, то именно JDK dynamic proxy и будет использоваться (хотя это можно изменить, явно задав флаг proxy-target-class). При создании прокси объекта с помощью JDK на вход передаются все интерфейсы класса и метод для имплементации нового поведения. В результате получаем объект, который абсолютно точно реализует паттерн Proxy. Все это происходит на этапе создания бинов, поэтому, когда начинается внедрение зависимостей, то в реальности внедрен будет этот самый прокси-объект. И все обращения будут производиться именно к нему. Но выполнив свою часть функционала, он обратиться к объекту исходного класса и передаст ему управление. Если же этот объект сам обратиться к одному из своих методов, то это будет уже прямой вызов без всяких прокси. Собственно именно это поведение и есть то, которое ожидается согласно правильному* ответу.  
  
С этим вроде все понятно, а что же с CGLib? Ведь он создает на самом деле не прокси объект, а наследника класса. И вот тут мой мозг уже просто кричит: СТОП! Ведь тут мы имеем ну просто пример из учебника по ООП.  
  

```java
public class SampleParent {

  public void method1() {
    System.out.println("SampleParent.method1");
    method2();
  }
  
  public void method2() {
    System.out.println("SampleParent.method2");
  }
  
}
public class SampleChild extends SampleParent {

  @Override
  public void method2() {
    System.out.println("SampleChild.method2");
  }

}
```

  
Где SampleChild – это, по сути, наш прокси-объект. И вот тут я уже начинаю сомневаться даже в ООП (или в своих знаниях о нём). Ведь если мы имеем наследование, то перекрытый метод должен вызываться вместо родительского и тогда поведение будет отличаться от того что мы имеем при использовании JDK dynamic proxy.  
  
Хотя есть еще один вариант, возможно, я неправильно понял, как создаются объекты с помощью CGLib и, на самом деле, они «не совсем наследники», а тоже «какие-будь прокси». И, конечно же, самый простой способ быть уверенным хоть в чем-нибудь – это проверить на простом примере. Вот и создадим еще один маленький проектик.  
  
На этот раз нам Spring уже не нужен, просто создаем простейший maven-проект и добавляем в pom зависимость на CGLib (собственно это и есть всё содержание нашего pom-файла).  
  

```xml
  <dependencies>
  <dependency>
      <groupId>cglib</groupId>
      <artifactId>cglib</artifactId>
      <version>3.2.5</version>
  </dependency>
  </dependencies>
```

  
Добавим в созданный проект наши два Sample-класса (ну так, на всякий случай, что бы убедить себя, что всё-таки принципы ООП незыблемы) и собственно класс с main() методом, в котором и будем выполнять наши тесты.  
  

```java
package com.example.CGLIBTest;


import java.lang.reflect.Method;

import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

public class CGLIBTestApp {

  public static void main(String[] args) {
    new SampleChild().method1();
    
    System.out.println("//------------------------------------------//");
    
    Enhancer enhancer = new Enhancer();
    enhancer.setSuperclass(SampleParent.class);
    enhancer.setCallback(new MethodInterceptor() {
      public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy)
            throws Throwable {
          if(method.getName().equals("method2")) {
            System.out.println("SampleProxy.method2");
            return null;
          } else {
            return proxy.invokeSuper(obj, args);
          }
        }
    });
    ((SampleParent) enhancer.create()).method1();
      
  }

}
```

  
Первой строчкой вызываем method1() у объекта SampleChild класса (как уже сказал, ну просто что бы быть уверенным…) и далее создаем Enchancer. В объекте Enchancer переопределяем поведение метода method2(). После чего, собственно, создается новый объект и уже у него вызываем method1(). И запускаем.  
  

```java
SampleParent.method1
SampleChild.method2
//------------------------------------------//
SampleParent.method1
SampleProxy.method2
```

  
Фух… Можно выдохнуть. Если верить первым двум строкам вывода, то за последние 20 лет в ООП ничего не изменилось.  
  
Последние две строчки говорят, что и с объектами, создаваемыми через CGLib, моё понимание было абсолютно верным. Это действительно наследование. И с этого момента мои сомнения по поводу того, что созданный таким образом объект будет работать абсолютно аналогично JDK dynamic proxy объекту, только усилились. Поэтому больше не откладываем, а запускаем наш проект, который мы создали для экспериментов. Для этого нам в классе приложения надо будет добавить runner, и наш класс приобретет следующий вид.  
  

```java
package com.example.AOPTest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class AopTestApplication {

  @Autowired
  private MyService myService;

  public static void main(String[] args) {
    SpringApplication.run(AopTestApplication.class, args);
  }

  @Bean
  public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
    return args -> {
      myService.method1();
    };
  }
}
```

  
Все-таки нравится мне этот Spring Boot, все, что надо сделать, уже сделано за нас (уж извините за это маленькое лирическое отступление). Аннотация @SpringBootApplication включает в себя множество других аннотаций, которые пришлось бы писать, не используй мы Spring Boot. По умолчанию уже указано, что данный класс содержит конфигурацию, а также что необходимо сканировать пакеты на наличие в них определений бинов.  
  
В тоже время прямо здесь мы создаем новый бин CommandLineRunner, который собственно и выполнит вызов метода method1() у нашего бина myService.  
  

```
Aspect1
method1
method2
```

  
Хм… Такой вывод оказался для меня неожиданным. Да, он полностью соответствует ожиданиям, если Spring AOP использует JDK dynamic proxy. Т.е. при вызове method1() нашего сервиса сперва отработал аспект, после чего управление было передано объекту класса MyServiceImpl и дальнейшие вызовы будут производиться в пределах этого объекта.  
  
Но мы ведь не указали у класса ни одного интерфейса. И я ожидал, что Spring AOP в данном случае будет использовать CGLib. Может Spring сам каким-то образом обходит это ограничение и, как и написано в документации, старается использовать JDK dynamic proxy в качестве основного варианта, если явно не указано обратного?  
  
Немного посидев над стеком вызовов в момент поднятия приложения, т.е. на этапе создания бинов, нашел место, где собственно и производится выбор какую из библиотек использовать. Происходит это в классе DefaultAopProxyFactory, а именно в методе  
  

```java
  @Override
  public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
    if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
      Class<?> targetClass = config.getTargetClass();
      if (targetClass == null) {
        throw new AopConfigException("TargetSource cannot determine target class: " +
            "Either an interface or a target is required for proxy creation.");
      }
      if (targetClass.isInterface() || Proxy.isProxyClass(targetClass)) {
        return new JdkDynamicAopProxy(config);
      }
      return new ObjenesisCglibAopProxy(config);
    }
    else {
      return new JdkDynamicAopProxy(config);
    }
  }
```

  
В Javadocs к данному классу написано  

> `Default AopProxyFactory implementation, creating either a CGLIB proxy or a JDK dynamic proxy.      Creates a CGLIB proxy if one the following is true for a given AdvisedSupport instance:      • the optimize flag is set   • the proxyTargetClass flag is set   • no proxy interfaces have been specified      In general, specify proxyTargetClass to enforce a CGLIB proxy, or specify one or more interfaces to use a JDK dynamic proxy.`

И для того что бы нам убедиться, что никаких интерфейсов к нашему классу не появилось достаточно проверить условие hasNoUserSuppliedProxyInterfaces(config). В нашем случае оно возвращает true. И, как результат, вызывается создание прокси через CGLib.  
  
Другими словами, Spring AOP не просто использует CGLib для создания наследников от классов бинов, а реализует на этом этапе полноценный прокси объект (т.е. объект соответствующий паттерну Proxy). Как именно он это делает, каждый желающий может сам посмотреть, пройдясь по шагам под отладкой в данном приложении. Куда более важным для меня был вывод, что абсолютно без разницы, какую библиотеку под капотом использует Spring. В любом случае поведение его будет одинаковым. В любом случае для организации сквозного программирования будет создан прокси объект, который собственно и обеспечит вызовы методов объекта реального класса. С другой стороны, если какие-либо методы вызываются из методов этого же класса, то перехватить (перекрыть) средствами Spring AOP их уже не получиться.  
  
На этом можно было бы остановиться с поисками отличий в поведении прокси созданных через JDK и CGLib. Но мой пытливый ум продолжал свои попытки найти хоть какое-то несоответствие. И я решил добиться того, что прокси объект будет создан через JDK. Теоретически это должно быть просто и не занять много времени. Возвращаясь к документации можно вспомнить, что именно этот вариант должен использоваться по умолчанию, с единственной оговоркой: у объекта должны быть интерфейсы. Также флаг ProxyTargetClass должен быть сброшен (т.е. false).  
  
Первое условие выполняется путём добавления в проект соответствующего интерфейса (не буду уже приводить этот код, думаю достаточно очевидно, как он будет выглядеть). Второе – путём добавления в конфигурацию соответствующей аннотации, т.е. как-то так  
  

```
@SpringBootApplication
@EnableAspectJAutoProxy(proxyTargetClass = false)
public class AopTestApplication {
```

  
Но на деле всё оказалось не так просто. Обе проверки — config.isProxyTargetClass() и hasNoUserSuppliedProxyInterfaces(config) по-прежнему возвращали true. На этом я всё-таки решил остановиться. Я получил ответ на свой вопрос, а также сделал отметку в памяти, что (как минимум при использовании Spring 5), несмотря на утверждения документации, прокси объекты с большей вероятностью будут создаваться с помощью CGLib.  
  
Кстати, если кто-то знает, как принудить Spring AOP использовать JDK, буду ждать ваших комментариев.  
  

## Compile-time weaving и AspectJ

  
Ну что ж, наша гипотеза, что поведение кода под аспектами будет зависеть от того, какая библиотека используется под капотом, потерпела неудачу. Тем не менее, это еще не все возможности, которые предоставляет Spring в плане АОП. Одной из самых интересных (по моему мнению) возможностей, которые Spring AOP нам предоставляет, это возможность использовать компилятор AspectJ. Т.е. фреймворк написан так, что если мы для описания аспектов используем аннотации @AspectJ, то нам не придется вносить никаких изменений, что бы перейти от runtime weaving к compile-time weaving. Кроме того (очередное достоинство Spring Boot) все необходимые зависимости уже включены. Нам остается только подключить плагин, который и выполнит компиляцию.  
  
Для этого внесем изменения в наш pom’ник. Теперь секция build будет выглядеть следующим образом.  
  

```xml

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>aspectj-maven-plugin</artifactId>
        <version>1.10</version>
        <configuration>
          <complianceLevel>1.8</complianceLevel>
          <source>${maven.compiler.source}</source>
          <target>${maven.compiler.target}</target>
          <showWeaveInfo>true</showWeaveInfo>
          <verbose>true</verbose>
          <Xlint>ignore</Xlint>
          <encoding>UTF-8 </encoding>
          <weaveDirectories>
            <weaveDirectory>${project.build.directory}/classes</weaveDirectory>
          </weaveDirectories>
          <forceAjcCompile>true</forceAjcCompile>
        </configuration>
        <executions>
          <execution>
            <goals>
              <goal>compile</goal>
              <!-- <goal>test-compile</goal> -->
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
```

  
Я не буду останавливаться на параметрах конфигурации данного плагина, лишь поясню, почему закомментировал цель test-compile. При сборке проекта maven падал с ошибкой на этапе запуска тестов. Порывшись по интернету, я видел, что эта проблема известная, и есть способы ее решения. Но, поскольку, в нашем тестовом приложении тесты как бы и отсутствуют, то самым простым решением было просто отключить их вызов совсем (а заодно и вызов плагина на этапе их компиляции).  
  
Собственно это все изменения, которые нам надо было сделать. Можем запускать наше приложение  
  

```
Aspect1
Aspect1
method1
Aspect1
Aspect1
method2
```

  
В этот момент я осознал всю глубину своего непонимания аспектов. Я перепроверил весь код несколько раз. Попытался прокрутить в уме, где и что я сделал не так. Но так и не осознал, почему получил такой результат (нет, ну честно, ведь не очевидно, почему код аспекта вызывается дважды перед каждым вызовом метода нашего класса).  
  
В конце концов, я все-таки догадался посмотреть логи, полученные на этапе сборки проекта и обнаружил там следующие 4 строки.  
  

```
[INFO] Join point 'method-call(void com.example.AOPTest.MyServiceImpl.method1())' in Type 'com.example.AOPTest.AopTestApplication' (AopTestApplication.java:32) advised by before advice from 'com.example.AOPTest.MyAspect1' (MyAspect1.class:19(from MyAspect1.java))
[INFO] Join point 'method-call(void com.example.AOPTest.MyServiceImpl.method2())' in Type 'com.example.AOPTest.MyServiceImpl' (MyServiceImpl.java:12) advised by before advice from 'com.example.AOPTest.MyAspect1' (MyAspect1.class:19(from MyAspect1.java))
[INFO] Join point 'method-execution(void com.example.AOPTest.MyServiceImpl.method1())' in Type 'com.example.AOPTest.MyServiceImpl' (MyServiceImpl.java:10) advised by before advice from 'com.example.AOPTest.MyAspect1' (MyAspect1.class:19(from MyAspect1.java))
[INFO] Join point 'method-execution(void com.example.AOPTest.MyServiceImpl.method2())' in Type 'com.example.AOPTest.MyServiceImpl' (MyServiceImpl.java:17) advised by before advice from 'com.example.AOPTest.MyAspect1' (MyAspect1.class:19(from MyAspect1.java))
```

  
Всё встало на свои места. Связывание кода произошло не только в месте исполнения методов, но и в месте их вызовов. Дело в том, что Spring AOP имеет ограничение, которое позволяет связывать код только по месту исполнения. Возможности AspectJ в этом плане значительно шире. Убрать лишние вызовы аспектов достаточно просто, например можно вот так модифицировать код аспекта.  
  

```java
package com.example.AOPTest;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class MyAspect1 {

  @Pointcut("execution(public * *(..))")
  public void publicMethod() {}  
  
  @Pointcut("@annotation(com.example.AOPTest.Annotation1)")
  public void annotated() {}
  
  @Before("annotated() && publicMethod()")
  public void printABit() {
    System.out.println("Aspect1");
  }
}
```

  
После чего наш вывод примет ожидаемый вид.  
  

```
Aspect1
method1
Aspect1
method2
```

  
Ну что ж, здесь мы уже можем сказать, что наш правильный* ответ все-таки требует уточнения. Как минимум, если у вас на собеседовании спросят про ожидаемое поведение приведенного в начале кода, стоит уточнить: «А не используем ли мы компайл-тайм связывания? Ведь в коде класса это никак не отражается, а pom’ник нам не предоставили».  
  
Что еще тут хотелось бы отметить. В документации по Spring AOP описывается, что все было сделано, что бы можно было легким движением руки (с) переключится с рантайм связывания на компайл-тайм связывание. И как мы видели, это действительно так. Код для обоих случаев использовался один и тот же (на самом деле работа, которая была сделана значительно больше, чем просто создание обработчиков для одинаковых аннотаций, но останавливаться на этом не буду, желающие могут почитать документацию и впечатлиться самостоятельно).  
  
При всем при этом, в зависимости от выбранного варианта связывания, поведение может оказаться разным (и даже неожиданным). Кроме тех случаев, что уже рассмотрены, хочу обратить внимание, что для компилятора AspectJ не нужна аннотация [Component](https://habrahabr.ru/users/component/). Т.е. если мы ее уберем, то Spring AOP не найдет такого бина и аспект не будет задействован. В то же время, если мы решим переключиться на AspectJ компиляцию, то этот аспект будет действующим, а вот поведение приложения – непредсказуемым.  
  

## Load-time weaving

  
Воодушевленный полученным результатом предыдущего этапа, я уже мысленно потирал руки. Ведь если при связывании кода во время компиляции мы получили поведение отличное, того которое мы имели для связывания во время исполнения, то вероятно примерно такой же результат стоит ожидать и в случае связывания во время загрузки (ну, я так думал). Быстренько ознакомившись с документацией по этому поводу, выяснил, что LTW в Spring доступно из коробки. Все что надо – просто в классе конфигурации добавить еще одну аннотацию: @EnableLoadTimeWeaving.  
  

```java
@SpringBootApplication
@EnableLoadTimeWeaving
public class AopTestApplication {
```

  
Ах, да. Не забываем удалить aspectj-maven-plugin из pom’ника, который мы чуть раньше добавили. Он нам больше не нужен.  
  
И теперь можно запускать… Нет, на самом деле есть еще один нюанс.  

> #### Generic Java applications
> 
>   
> When class instrumentation is required in environments that do not support or are not supported by the existing LoadTimeWeaver implementations, a JDK agent can be the only solution. For such cases, Spring provides InstrumentationLoadTimeWeaver, which requires a Spring-specific (but very general) VM agent,org.springframework.instrument-{version}.jar (previously named spring-agent.jar).  
> To use it, you must start the virtual machine with the Spring agent, by supplying the following JVM options:  
> -javaagent:/path/to/org.springframework.instrument-{version}.jar

  
Здесь в документации есть небольшая неточность, название библиотеки: spring-instrument-{version}.jar. И эта библиотека уже на вашем компьютере (спасибо Spring Boot и Maven). В моем случае путь к ней выглядит вот так: _c:\Users\{MyUserName}\.m2\repository\org\springframework\spring-instrument\5.0.2.RELEASE\spring-instrument-5.0.2.RELEASE.jar_. Если вы, как и я пользуетесь STS для разработки, выполняем следующие шаги. Открываем меню Run > Run Configurations… Находим там Spring Boot App и в нем конфигурацию запуска нашего приложения. Открываем закладочку Arguments. В поле VM arguments: добавляем параметр _-javaagent:c:\Users\\{MyUserName}\.m2\repository\org\springframework\spring-instrument\5.0.2.RELEASE\spring-instrument-5.0.2.RELEASE.jar_. И теперь запускаем.  
  

```
Aspect1
method1
method2
```

  
Ну вот, опять. Не такой я результат ожидал. Может все-таки не так просто подключить LTW, может еще что-то надо где-то настроить? И опять же самый простой способ убедиться, что наши настройки работают, запустить приложение под отладкой и посмотреть какой код исполняется. В приведенном выше фрагменте документации сказано, что в нашем случае должен использоваться класс InstrumentationLoadTimeWeaver. И есть в нем метод, который точно должен вызываться на этапе создания бинов.  
  

```java
public void addTransformer(ClassFileTransformer transformer)
```

  
Именно здесь и поставим точку прерывания.  
  
Стартуем… Останавливаемся… DefaultAopProxyFactory.createAopProxy(). Сработала точка останова которую мы поставили ранее, когда разбирались JDK vs CGLib. Снова запускаем, и на этот раз уже останавливается именно там, где ожидали. Сомнений больше не осталось.  
Ну что ж, и в этом случае Spring AOP создает все те же прокси объекты, что мы видели ранее. С тем лишь отличием, что связывание теперь будет производиться не на этапе исполнения, а уже на этапе загрузки классов. За деталями этого процесса прошу в код.  
  

## Заключение

  
Ну что ж, похоже, что наш правильный* ответ действительно является правильным, хоть и с оговоркой (см. главу «Compile-time weaving и AspectJ»).  
  
Зависит ли поведение от того какой механизм проксирования выбран: JDK или CGLib? Фреймворк написан так, что бы то, что там под капотом никак не влияло на то, какой результат мы получим. И даже подключение LTW не должно никак на это влиять. И в рамках рассмотренного нами примера мы этих различий не наблюдали. И всё же в документации можно найти упоминание, что различия есть. JDK dynamic proxy могут перекрывать только public методы. CGLib proxy – кроме public, также и protected методы и package-visible. Соответственно, если мы явно не указали для среза (pointcut) ограничение «только для public методов», то потенциально можем получить неожиданное поведение. Ну а если есть какие-либо сомнения, можно принудительно включить использование CGLib для генерации прокси-объектов (похоже, в последних версиях Spring это уже сделали за нас).  
  
Spring AOP является proxy-based фреймворком. Это значит, что всегда будут создаваться прокси-объекты на любой наш бин подпадающий под действие аспекта. И тот момент, что вызов одного метода класса другим не может быть перехвачен средствами Spring AOP – это не ошибка или недоработка разработчиков, а особенность паттерна положенного в основу реализации фреймворка. С другой стороны, если нам все-таки надо добиться, что бы в рассматриваемом случае код аспекта выполнялся, то надо учесть этот факт и писать код, так что бы обращения проходили через прокси-объект. В документации есть пример как это можно сделать, но даже там прямо написано, что это нерекомендуемое решение. Другой вариант – это «заинжектить» сервис сам в себя. В последних версиях Spring вот такое решение будет рабочим.  
  

```java
@Service
public class MyServiceImpl{

  @Autowired
  private MyServiceImpl myService;

  @Annotation1
  public void method1() {
    System.out.println("method1");
    myService.method2();
  }

  @Annotation1
  public void method2() {
    System.out.println("method2");
  }
```

  
Правда, этот вариант применим только для бинов со scope равным «singleton». Если же поменять scope на «prototype», то приложение не сможет подняться из-за попытки бесконечного внедрения сервиса в самого себя. Выглядеть это будет так  
  

```
***************************
APPLICATION FAILED TO START
***************************

Description:

The dependencies of some of the beans in the application context form a cycle:

   aopTestApplication (field private com.example.AOPTest.MyServiceImpl com.example.AOPTest.AopTestApplication.myService)
┌─────┐
|  myServiceImpl (field private com.example.AOPTest.MyServiceImpl com.example.AOPTest.MyServiceImpl.myService)
└─────┘
```

  
На что еще хотелось бы обратить внимание, так это на тот оверхэд, который сопровождает нас при использовании Spring AOP. Повторюсь, что всегда будут создаваться прокси-объекты на любой наш бин подпадающий под действие аспекта. Причем их будет ровно столько, сколько инстансов бинов будет создано. В примере мы рассматривали singleton бин, соответственно только один прокси-объект был создан. Используем prototype – и количество прокси-объектов будет соответствовать количеству внедрений. Сам прокси объект не выполняет вызовов методов целевого объекта, он содержит цепочку интерсепторов, которые делают это. Не зависимо от того, попадает или нет каждый конкретный метод целевого объекта под действие аспекта, его вызов проходит через прокси-объект. Ну и плюс к этому будет создан как минимум один инстанс класса аспекта (в нашем примере он будет только один, но этим можно управлять).  
  

## Послесловие

  
Чувство когнитивного диссонанса меня так и не покинуло. Что-то в этом примере с транзакциями все-таки не так. Продублирую его код.  
  

```java
public class MyServiceImpl {
  
  @Transactional
  public void method1() {
    //do something
    method2();
  }

  @Transactional (propagation=Propagation.REQUIRES_NEW)
  public void method2() {
    //do something
  }
}
```

  
Хотя нет, кажется, понял. И дело не только и даже не столько в АОП. Мне не очевидно, зачем может понадобиться посередине одной транзакции создавать другую (исходя из того, что изначально предполагалось получить именно такой результат).  
  
Если кто-то может привести пример с реальных проектов, когда это было необходимо, буду признателен увидеть это в комментариях.  
  
Я же здесь вижу только проблемы.