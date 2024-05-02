# Докерфайл для образу "eugeneloy/citus-gitpod-lab". Образ базується на образі робочого простору Gitpod та встановлює необхідні залежності

FROM gitpod/workspace-full:2024-02-16-14-23-15

# Встановлення Citus (https://docs.citusdata.com/en/v12.1/installation/multi_node_debian.html)
RUN curl https://install.citusdata.com/community/deb.sh | sudo bash
RUN sudo apt-get -y install postgresql-16-citus-12.1
