

В этом кратком посте я поделюсь с вами некоторыми примерами кода для отображения нескольких флажков в HTML-форме с помощью Spring MVC и Thymeleaf. Значения флажков сопоставляются с коллекцией, которая является полем класса модели. Например, вы хотите закодировать пользовательскую форму, которая выглядит следующим образом:

![Spring Thymeleaf формирует несколько флажков](/Media/Pictures/Thymeleaf/image_1.png)

Пользователь может иметь одну или несколько (множественных) ролей, поэтому поле Роли в этой форме представлено несколькими флажками, соответствующими именам ролей в базе данных.

В базе данных у нас есть 3 таблицы для реализации отношений "многие ко многим" между пользователями и ролями следующим образом:

![взаимосвязь между пользователями и ролями](/Media/Pictures/Thymeleaf/image_2.png)

В коде Java мы создаем класс entity Пользователь следующим образом (я показываю только соответствующий код в контексте этого поста):

```java
package net.codejava

import java.util.*;
import javax.persistence.*

@Entity
@Table(name = "users")
public class User {
	
	
	@ManyToMany(cascade = CascadeType.PERSIST, fetch = FetchType.EAGER)
	@JoinTable(
			name = "users_roles",
			joinColumns = @JoinColumn(name = "user_id"),
			inverseJoinColumns = @JoinColumn(name = "role_id")
			)
	private Set<Role> roles = new HashSet<>();
	
}
```

Вы видите, что Пользователь класс имеет Установить из Рольs. Вы должны переопределить К строке(), равно() и Хэш - код() В Роль классифицируйте следующим образом:

```java
package net.codejava;

import javax.persistence.*;

@Entity
@Table(name = "roles")
public class Role {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Integer id;
	private String name;

	// getters and setters are not shown
	
	@Override
	public String toString() {
		return this.name;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Role other = (Role) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}	
}
```

Нам нужно переопределить К строке() метод, чтобы имена ролей отображались в форме. И равно() и Хэш - код() должен быть переопределен, чтобы Spring MVC и Thymeleaf правильно отображали флажки, когда форма находится в режиме редактирования.

Для интерфейсов репозитория Spring Data JPA, т.е.. Пользовательское хранилище и Ролевая позиция – ничего особенного. Нам не нужно писать никакого дополнительного кода.

И в классе Spring MVC controller нам нужно закодировать обработчики для создания нового пользователя и редактирования существующего пользователя следующим образом:
```java
package net.codejava;


@Controller
public class UserController {

	@Autowired
	private UserServices service;
	
	@Autowired 
	private RoleRepository roleRepository;
	
	@GetMapping("/users/new")
	public ModelAndView newUser() {
		User user = new User();
		ModelAndView mav = new ModelAndView("user_form");
		mav.addObject("user", user);
		
		List<Role> roles = (List<Role>) roleRepository.findAll();
		
		mav.addObject("allRoles", roles);
		
		return mav;		
	}	
	
	@GetMapping("/users/edit/{id}")
	public ModelAndView editUser(@PathVariable(name = "id") Integer id) {
		User user = service.get(id);
		ModelAndView mav = new ModelAndView("user_form");
		mav.addObject("user", user);
		
		List<Role> roles = (List<Role>) roleRepository.findAll();
		
		mav.addObject("allRoles", roles);
		
		return mav;
	}	
}
```

Ключевым моментом здесь является добавление коллекции Роль объекты для модели:

```java
List<Role> roles = (List<Role>) roleRepository.findAll();
mav.addObject("allRoles", roles);
```

И в представлении с помощью Thymeleaf напишите код для отображения флажков следующим образом:
```html
`<form th:action="@{/users/save}" th:object="${user}" method="post">`
<p>
	<label>Roles: 
		<input type="checkbox" name="roles"
			th:each="role : ${allRoles}" 
			th:text="${role.name}"
			th:value="${role.id}"
			th:field="*{roles}"
		/>
	</label>
</p>
`</form>`
```

Затем, когда вы перейдете в режим создания нового, он покажет флажки с меткой, соответствующей именам ролей в базе данных:

![Spring Thymeleafформирует несколько флажков](/Media/Pictures/Thymeleaf/image_3.png)

Нам не нужно писать какой-либо специальный код для метода save user handler, поскольку Spring MVC, Thymeleaf и Spring Data JPA отлично справляются с автоматической сохранением Пользователь объект и ассоциированный Роль Объекты.

В режиме редактирования флажки будут отображаться корректно в соответствии с ассоциацией между пользователем и ролями, например:

![форма spring thymeleaf с несколькими флажками править](/Media/Pictures/Thymeleaf/image_4.png)

