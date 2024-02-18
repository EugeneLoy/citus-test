```
curl https://install.citusdata.com/community/deb.sh | sudo bash
sudo apt-get -y install postgresql-16-citus-12.1
```

```
sudo su - postgres
export PATH=$PATH:/usr/lib/postgresql/16/bin
```

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

```
pg_ctl -D coordinator -o "-p 9700" -l coordinator_logfile start
pg_ctl -D worker1 -o "-p 9701" -l worker1_logfile start
pg_ctl -D worker2 -o "-p 9702" -l worker2_logfile start
```

```
psql -h 127.0.0.1 -p 9700 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9701 -U postgres -c "CREATE EXTENSION citus;"
psql -h 127.0.0.1 -p 9702 -U postgres -c "CREATE EXTENSION citus;"
```

```
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT citus_set_coordinator_host('127.0.0.1', 9700);"
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * from citus_add_node('127.0.0.1', 9701);"
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * from citus_add_node('127.0.0.1', 9702);"
```

```
psql -h 127.0.0.1 -p 9700 -U postgres -c "SELECT * FROM citus_get_active_worker_nodes();"
```
