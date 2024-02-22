# Створення робочого простору Gitpod

Створіть або увійдіть у обліковий запис [Github](https://github.com/) та перейдіть на сторінку репозиторія: https://github.com/EugeneLoy/citus-test [TODO]

Створіть "fork" репозиторія.

Створіть або увійдіть у обліковий запис [Gitpod](https://gitpod.io/). Використайте ваш обліковий запис Github для авторизації в Gitpod.

Створіть новий робочій простір:
* натисніть `New Workspace`
* оберіть репозиторій `<ваш Github аккаунт>/citus-test` [TODO]
* оберіть редактор `Terminal`
* оберіть клас `Standard`
* натисніть `Continue`

Після створення робочого простору вам буде доступно вікно команд віддаленої машини (термінал).

Перейдіть на [сторінку робочіх просторів](https://gitpod.io/workspaces) та закріпіть новостворенний робочий простір:
* натисніть три крапки
* натисніть `Pin`

[TODO] розписати особливості gitpod

# Початковоа конфігурація Citus кластера

У терміналі робочого простору виконайте наступні дії:

[TODO] це можна пропустити:

```
curl https://install.citusdata.com/community/deb.sh | sudo bash
sudo apt-get -y install postgresql-16-citus-12.1
```

Створіть директорію для екземплярів PostgreSQL:
```
mkdir /workspace/nodes
sudo chmod a+rwx /workspace/nodes
```

Переключітся на користувача `postgres`:
```
sudo su - postgres
export PATH=$PATH:/usr/lib/postgresql/16/bin
```

Створіть 3 екземпряри PostgreSQL для кластера Citus (1 координатор та 2 робочих):

[TODO] розписати детальніше
```
cd /workspace/nodes

mkdir coordinator
initdb -D coordinator
echo "shared_preload_libraries = 'citus'" >> coordinator/postgresql.conf

mkdir worker1
initdb -D worker1
echo "shared_preload_libraries = 'citus'" >> worker1/postgresql.conf

mkdir worker2
initdb -D worker2
echo "shared_preload_libraries = 'citus'" >> worker2/postgresql.conf
```

Запустіть екземпляри PostgreSQL (координатор на порту `9700`, робочі на портах `9701` та `9702`):
```
cd /workspace/nodes
pg_ctl -D coordinator -o "-p 9700" -l coordinator_logfile start
pg_ctl -D worker1 -o "-p 9701" -l worker1_logfile start
pg_ctl -D worker2 -o "-p 9702" -l worker2_logfile start
```

Виконайте конфігурацію кластера:

[TODO] розписати детальніше
```
psql -h 127.0.0.1 -p 9700 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9701 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9702 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT citus_set_coordinator_host('127.0.0.1', 9700);"
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * from citus_add_node('127.0.0.1', 9701);"
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * from citus_add_node('127.0.0.1', 9702);"
```

Перевірте роботу кластера:

[TODO] розписати детальніше
```
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * FROM citus_get_active_worker_nodes();"
```

# Запуск Citus кластера після перезапуску робочого простору

У терміналі робочого простору виконайте наступні дії:

Переключітся на користувача `postgres`:
```
sudo su - postgres
export PATH=$PATH:/usr/lib/postgresql/16/bin
```

Запустіть екземпляри PostgreSQL (координатор на порту `9700`, робочі на портах `9701` та `9702`):
```
cd /workspace/nodes
pg_ctl -D coordinator -o "-p 9700" -l coordinator_logfile start
pg_ctl -D worker1 -o "-p 9701" -l worker1_logfile start
pg_ctl -D worker2 -o "-p 9702" -l worker2_logfile start
```
