# Створення робочого простору Gitpod

Gitpod це сервіс, що дозволяє створювати, поширювати та використовувати "робочі простори".

Робочий простір в Gitpod це середовище, яке створюється на основі репозиторія (GitHub/GitLab/Bitbucket) та може містити заздалегідь налаштовані залежності (наприклад, встановлені пакети).
Робочі простори виконуються на стороні Gitpod, з ними можна взаємодіяти за допомогою браузера або інтеграції з Visual Studio Code.

Git репозиторій, на основі якого будло створено робочий простір, буде доступний в директорії `/workspace/<ім'я репозиторія>`, а вміст директорії `/workspace` буде зберігатися під час перезапусків робочого простору (зміни за межами цієї директорії, наприклад встановлення пакетів, збережені не будуть).

Створіть або увійдіть в обліковий запис [Github](https://github.com/) та перейдіть на сторінку репозиторія: https://github.com/EugeneLoy/citus-test

Створіть "fork" репозиторія.

Створіть або увійдіть в обліковий запис [Gitpod](https://gitpod.io/). Використайте ваш обліковий запис Github для авторизації в Gitpod.

Створіть новий робочій простір:
* натисніть `New Workspace`
* оберіть репозиторій `<ваш Github аккаунт>/citus-test`
* оберіть редактор `Terminal`
* оберіть клас `Standard`
* натисніть `Continue`

Після створення робочого простору вам буде доступно вікно команд віддаленої машини (термінал).

Gitpod періодично видаляє робочі простори, які не використовуються певний час. Для запобіганя цьому перейдіть на [сторінку робочіх просторів](https://gitpod.io/workspaces) та закріпіть новостворенний робочий простір:
* натисніть меню створенного робочого простору (`⋮`)
* натисніть `Pin`

Gitpod безкоштовно надає 50 годин використання робочих просторів (стандартного класу) на місяць. Перевірити баланс можна на [сторінці біллінгу](https://gitpod.io/billing).


# Створення та початкова конфігурація Citus кластера

Створіть директорію `/workspace/nodes` для екземплярів PostgreSQL:
```
mkdir /workspace/nodes
sudo chmod a+rw /workspace/nodes
```

Переключітся на користувача `postgres`:
```
sudo su - postgres
```

Для використання утиліт PostgreSQL, додайте іх до `PATH`:
```
export PATH=$PATH:/usr/lib/postgresql/16/bin
```

Створіть 3 екземпряри PostgreSQL для кластера Citus (1 координатор та 2 робочих).
Спочатку перейдіть в директорію `/workspace/nodes`.
Використайте утиліту `initdb` для створення екземплярів PostgreSQL.
Також, для кожного екземпляра потрібно додати можливість використання Citus:
```
cd /workspace/nodes

initdb -D coordinator
echo "shared_preload_libraries = 'citus'" >> coordinator/postgresql.conf

initdb -D worker1
echo "shared_preload_libraries = 'citus'" >> worker1/postgresql.conf

initdb -D worker2
echo "shared_preload_libraries = 'citus'" >> worker2/postgresql.conf
```

Запустіть екземпляри PostgreSQL (координатор на порті `9700`, робочі вузли на портах `9701` та `9702`):
```
cd /workspace/nodes
pg_ctl -D coordinator -o "-p 9700" -l coordinator_logfile start
pg_ctl -D worker1 -o "-p 9701" -l worker1_logfile start
pg_ctl -D worker2 -o "-p 9702" -l worker2_logfile start
```

В запущених екземплярах PostgreSQL, увімкніть розширення Citus:
```
psql -h 127.0.0.1 -p 9700 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9701 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9702 -U postgres -c "CREATE EXTENSION citus;"
```

Поєднайте запущені екземпляри PostgreSQL у Citus кластер (конфігурація виконується на координаторі).
```
psql -h 127.0.0.1 -p 9700 -U postgres -c "\
    SELECT citus_set_coordinator_host('127.0.0.1', 9700); \
    SELECT * from citus_add_node('127.0.0.1', 9701); \
    SELECT * from citus_add_node('127.0.0.1', 9702);"
```

Перевірте роботу кластера підключившись до координатора та переглянувши активні робочі вузли:
```
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * FROM citus_get_active_worker_nodes();"
```

# Запуск Citus кластера після перезапуску робочого простору

У терміналі робочого простору виконайте наступні дії:

Переключітся на користувача `postgres`:
```
sudo su - postgres
```
```
export PATH=$PATH:/usr/lib/postgresql/16/bin
```

Запустіть екземпляри PostgreSQL (координатор на порті `9700`, робочі вузли на портах `9701` та `9702`):
```
cd /workspace/nodes
pg_ctl -D coordinator -o "-p 9700" -l coordinator_logfile start
pg_ctl -D worker1 -o "-p 9701" -l worker1_logfile start
pg_ctl -D worker2 -o "-p 9702" -l worker2_logfile start
```
